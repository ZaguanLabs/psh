"""Check split-symbol packaging without changing any allocated ELF section."""
import hashlib
from pathlib import Path
import struct
import subprocess


def allocated_sections(path):
    """Fingerprint ELF64 little-endian runtime sections, including NOBITS sizes."""
    data = Path(path).read_bytes()
    if data[:6] != b"\x7fELF\x02\x01":
        raise ValueError("split symbols require ELF64 little endian; use --symbols embedded otherwise")
    header = struct.unpack_from("<16sHHIQQQIHHHHHH", data)
    offset, stride, count, strings_index = header[6], header[11], header[12], header[13]
    if stride < 64 or offset + stride > len(data):
        raise ValueError("invalid ELF section table")

    def section(index):
        return struct.unpack_from("<IIQQQQIIQQ", data, offset + index * stride)

    first = section(0)
    count = count or first[5]
    strings_index = first[6] if strings_index == 0xffff else strings_index
    if count * stride > len(data) - offset or strings_index >= count:
        raise ValueError("invalid ELF section count")
    strings = section(strings_index)

    def span(start, size):
        if start > len(data) or size > len(data) - start:
            raise ValueError("ELF section exceeds the file")
        return data[start:start + size]

    names = span(strings[4], strings[5])
    result = {"type": header[1], "machine": header[2], "entry": header[4],
              "flags": header[7], "sections": {}}
    for index in range(count):
        row = section(index)
        if not row[2] & 2:  # SHF_ALLOC
            continue
        end = names.find(b"\0", row[0])
        if row[0] >= len(names) or end < 0:
            raise ValueError("invalid ELF section name")
        name = names[row[0]:end].decode("ascii")
        if name in result["sections"]:
            raise ValueError("duplicate allocated section name")
        result["sections"][name] = {
            "type": row[1], "flags": row[2], "address": row[3], "size": row[5],
            "sha256": None if row[1] == 8 else hashlib.sha256(span(row[4], row[5])).hexdigest()}
    return result


def dynamic_exports(path):
    output = subprocess.check_output(["nm", "-D", "--defined-only", str(path)], text=True)
    return sorted(" ".join(line.split()[1:]) for line in output.splitlines())


def split_symbols(executable, debug_file):
    executable, debug_file = Path(executable), Path(debug_file)
    before, exports = allocated_sections(executable), dynamic_exports(executable)
    debug_file.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["objcopy", "--only-keep-debug", str(executable), str(debug_file)], check=True)
    subprocess.run(["strip", "--strip-unneeded", str(executable)], check=True)
    subprocess.run(["objcopy", "--add-gnu-debuglink=" + str(debug_file), str(executable)], check=True)
    debug_file.chmod(0o644)
    if allocated_sections(executable) != before or dynamic_exports(executable) != exports:
        raise RuntimeError("split-symbol packaging changed runtime sections or exported symbols")
    return before
