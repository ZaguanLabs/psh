#!/usr/bin/env python3
"""Compare private shells at real prompt boundaries; separate memory and timing modes."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import pty
import select
import tempfile
import termios
import time

MARK = b'\x1eR74READY\x1f'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


class Shell:
    def __init__(self, shell, home):
        self.pid, self.fd = pty.fork()
        if not self.pid:
            os.execve(str(shell), [str(shell), '-dfi', '+Z'],
                      {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C.UTF-8',
                       'TERM': 'xterm', 'HOME': str(home), 'ZDOTDIR': str(home)})
        self.buffer = b''
        self.closed = False
        self.reaped = False
        attrs = termios.tcgetattr(self.fd)
        attrs[3] &= ~termios.ECHO
        termios.tcsetattr(self.fd, termios.TCSANOW, attrs)
        self.command("unsetopt promptsp; PROMPT=$'\\x1eR74READY\\x1f'; RPROMPT=''", check=False)

    def command(self, code, check=True):
        start = time.perf_counter_ns()
        os.write(self.fd, code.encode() + b'\n')
        deadline = time.monotonic() + 30
        while MARK not in self.buffer:
            if time.monotonic() > deadline:
                raise RuntimeError(('prompt timeout', self.buffer[-1000:]))
            if select.select([self.fd], [], [], .1)[0]:
                chunk = os.read(self.fd, 65536)
                if not chunk:
                    raise RuntimeError('shell closed')
                self.buffer += chunk
        output, self.buffer = self.buffer.split(MARK, 1)
        elapsed = (time.perf_counter_ns() - start) / 1e6
        if check and output.strip() != b'RESULT:0':
            raise RuntimeError(('unexpected state', output))
        return elapsed

    def memory(self):
        values = {}
        for line in Path(f'/proc/{self.pid}/smaps_rollup').read_text().splitlines():
            bits = line.split()
            if len(bits) == 3 and bits[2] == 'kB':
                values[bits[0].rstrip(':')] = int(bits[1])
        return values

    def close(self):
        if self.closed:
            return
        try:
            os.write(self.fd, b'exit\n')
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                pid, status = os.waitpid(self.pid, os.WNOHANG)
                if pid:
                    self.reaped = True
                    if status != 0:
                        raise RuntimeError(('shell exit', status))
                    return
                if select.select([self.fd], [], [], .02)[0]:
                    try:
                        os.read(self.fd, 65536)
                    except OSError:
                        pass
            raise RuntimeError('exit timeout')
        finally:
            try:
                if not self.reaped:
                    os.kill(self.pid, 9)
                    os.waitpid(self.pid, 0)
            except ProcessLookupError:
                pass
            os.close(self.fd)
            self.closed = True


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('baseline', type=Path)
    p.add_argument('candidate', type=Path)
    p.add_argument('--mode', choices=['memory', 'timing'], required=True)
    p.add_argument('--samples', type=int, default=7)
    p.add_argument('--cpu', type=int, default=13)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    if a.samples < 1:
        p.error('samples must be positive')
    os.sched_setaffinity(0, {a.cpu})
    shells = [s.resolve(strict=True) for s in [a.baseline, a.candidate]]
    hashes = [sha(s) for s in shells]
    rows = []
    for case, count in [('small', 2000), ('large', 20000), ('sparse', 20000), ('live', 20000), ('noop', 0)]:
        row = dict(case=case, strings=count, string_bytes=1024, runs=[])
        for sample in range(a.samples):
            for host in ([0, 1] if sample % 2 == 0 else [1, 0]):
                with tempfile.TemporaryDirectory(prefix='psh-prompt-memory-') as tmp:
                    term = Shell(shells[host], Path(tmp))
                    try:
                        declaration = 'typeset -ga payload=()' if case == 'live' else 'local -a payload'
                        if case == 'sparse':
                            declaration += '; typeset -ga kept=()'
                        keep = 'if (( i % 1000 == 0 )); then kept+=("$text"); fi; ' if case == 'sparse' else ''
                        setup = (f'burst() {{ {declaration}; local text=${{(l:1024::x:)}}; local -i i; '
                                 f'for ((i=0;i<{count};++i)); do payload+=("$text"); {keep}done; '
                                 f'(( ${{#payload}} == {count} && ${{#payload[-1]}} == 1024 )); }}; '
                                 'print -r -- "RESULT:$?"')
                        term.command(setup)
                        points = []
                        if a.mode == 'memory':
                            points.append(dict(phase='before', memory=term.memory()))
                        for cycle in range(30 if case == 'noop' else 3):
                            operation = ':' if case == 'noop' else 'burst'
                            # Each live allocation replaces the preceding one and must remain readable.
                            if case == 'sparse':
                                operation += '; (( ${#kept} == 20 && ${#kept[1]} == 1024 && ${#kept[-1]} == 1024 ))'
                            if case == 'live':
                                operation += f'; (( ${{#payload}} == {count} && ${{#payload[1]}} == 1024 ))'
                            elapsed = term.command(operation + '; print -r -- "RESULT:$?"')
                            point = dict(phase=f'cycle-{cycle + 1}')
                            if a.mode == 'memory':
                                point['memory'] = term.memory()
                            else:
                                point['elapsed_ms'] = elapsed
                            points.append(point)
                        # Measure unchanged prompts after the allocation history above.
                        for idle in range(30):
                            elapsed = term.command(':; print -r -- "RESULT:$?"')
                            point = dict(phase=f'idle-{idle + 1}')
                            if a.mode == 'memory':
                                point['memory'] = term.memory()
                            else:
                                point['elapsed_ms'] = elapsed
                            points.append(point)
                        if case in ('live', 'sparse'):
                            array = 'payload' if case == 'live' else 'kept'
                            term.command('verify_content() { local item; for item in "${' + array + '[@]}"; do '
                                         '[[ $item == ${(l:1024::x:)} ]] || return 1; done; }; '
                                         'verify_content; print -r -- "RESULT:$?"')
                        if case == 'live':
                            term.command(f'(( ${{#payload}} == {count} && ${{#payload[-1]}} == 1024 )); print -r -- "RESULT:$?"')
                        row['runs'].append(dict(sample=sample, host=host, points=points))
                    finally:
                        term.close()
        rows.append(row)
        print(case, 'passed', flush=True)
    assert hashes == [sha(s) for s in shells]
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(dict(shells=list(map(str, shells)), binary_sha256=hashes,
        driver_sha256=sha(Path(__file__)), mode=a.mode, cpu=a.cpu, samples=a.samples,
        scope='PTY with ZLE disabled; command through next prompt; separate unchanged OMZ gate covers ZLE',
        cases=rows), indent=2) + '\n')


if __name__ == '__main__':
    main()
