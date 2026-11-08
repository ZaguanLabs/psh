#!/usr/bin/env python3
"""Verify unqueued [[ -v ]] calls leave private array cache metadata unchanged."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("shell", type=Path, help="shell with debugger symbols available")
    parser.add_argument("--expect-writes", action="store_true",
                        help="negative control for the rejected unguarded prototype")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    shell = args.shell.resolve(strict=True)
    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.unlink(missing_ok=True)
    # The expansion between the second and third condition populates a cache
    # entry inside prefork's existing queue boundary. Neither cold nor warm
    # unqueued probes may publish metadata or change signal queueing policy.
    script = "a=({1..1024}); [[ -v 'a[500]' ]]; [[ -v 'a[600]' ]]; : \"${a[500]}\"; [[ -v 'a[700]' ]]"
    with tempfile.TemporaryDirectory(prefix="psh-cache-signals-") as scratch:
        driver = Path(scratch) / "check.gdb"
        inner = f'''import gdb, json
rows = []
bp = gdb.Breakpoint("issetvar")
gdb.execute("run")
while gdb.selected_inferior().pid:
    level = int(gdb.parse_and_eval("queueing_enabled"))
    before = str(gdb.parse_and_eval("array_lengths"))
    bp.enabled = False
    gdb.execute("finish")
    after = str(gdb.parse_and_eval("array_lengths"))
    rows.append(dict(queue_level=level, cache_unchanged=(before == after)))
    bp.enabled = True
    gdb.execute("continue")
expected_writes = {args.expect_writes!r}
observed_writes = any(not row["cache_unchanged"] for row in rows)
passed = len(rows) == 3 and all(row["queue_level"] == 0 for row in rows) and observed_writes == expected_writes
report = dict(passed=passed, shell={str(shell)!r}, binary_sha256={hashlib.sha256(shell.read_bytes()).hexdigest()!r},
              expected_writes=expected_writes, observed_writes=observed_writes, calls=rows)
with open({str(output)!r}, "w") as out:
    json.dump(report, out, indent=2)
    out.write("\\n")
if not passed:
    raise gdb.GdbError("array cache signal-boundary check failed")
'''
        driver.write_text("set pagination off\nset confirm off\npython\n" + inner + "end\n")
        command = ["gdb", "--batch", "--nx", "--quiet", "-x", str(driver),
                   "--args", str(shell), "-dfc", script]
        result = subprocess.run(command, env={"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"},
                                capture_output=True, timeout=60)
        output.with_suffix(".gdb.log").write_bytes(result.stdout + result.stderr)
        if result.returncode or not output.exists() or not json.loads(output.read_text())["passed"]:
            raise RuntimeError("signal-boundary check failed: " + str(output.with_suffix(".gdb.log")))
    print("Unqueued cache-write expectation verified:", args.expect_writes)


if __name__ == "__main__":
    main()
