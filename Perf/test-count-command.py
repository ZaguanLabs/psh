#!/usr/bin/env python3
"""Check hardware counting, fork inheritance, child output and exit-status forwarding."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

WORKER = r'''
#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
static void work(void) { volatile unsigned long x=0; for(unsigned long i=0;i<2000000;i++) x+=i; }
int main(int argc,char **argv) {
 if(argc!=2) return 2;
 if(!strcmp(argv[1],"failure")) return 7;
 if(strcmp(argv[1],"child")) work();
 if(strcmp(argv[1],"own")) {
  pid_t p=fork(); if(p<0) return 3;
  if(!p){ work(); _exit(0); }
  int s; if(waitpid(p,&s,0)!=p || !WIFEXITED(s) || WEXITSTATUS(s)) return 4;
 }
 puts("worker-ok"); return 0;
}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cpu", type=int, default=2)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    folder = args.output.resolve().parent / ("counter-selftest-" + args.output.stem)
    folder.mkdir(exist_ok=True, parents=True)
    source = folder / "worker.c"
    source.write_text(WORKER)
    launcher, worker = folder / "count-command", folder / "worker"
    for input_file, output_file in [(root / "Perf/count-command.c", launcher), (source, worker)]:
        subprocess.run(["cc", "-O2", "-g", "-Wall", "-Wextra", "-Werror", str(input_file), "-o", str(output_file)], check=True)
    os.sched_setaffinity(0, {args.cpu})
    rows = {}
    for mode in ["own", "child", "twice", "failure"]:
        report = folder / (mode + ".json")
        r = subprocess.run([str(launcher), str(report), str(worker), mode], capture_output=True)
        assert r.returncode == (7 if mode == "failure" else 0) and not r.stderr
        assert r.stdout == (b"" if mode == "failure" else b"worker-ok\n")
        row = json.loads(report.read_text())
        assert row["exit_status"] == r.returncode
        assert all(e["value"] > 0 and e["running_ns"] / e["enabled_ns"] > .95 for e in row["events"])
        rows[mode] = row
    instructions = lambda mode: next(e["value"] for e in rows[mode]["events"] if e["name"] == "instructions")
    assert .9 < instructions("child") / instructions("own") < 1.1
    assert 1.8 < instructions("twice") / instructions("own") < 2.2
    args.output.write_text(json.dumps({"passed": True, "cpu": args.cpu,
        "launcher_source_sha256": hashlib.sha256((root / "Perf/count-command.c").read_bytes()).hexdigest(),
        "worker_source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(), "cases": rows}, indent=2) + "\n")
    print("Hardware-counter self-test passed, including inherited child instructions")


if __name__ == "__main__":
    main()
