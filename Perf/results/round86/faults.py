"""Count minor and major page faults in fresh, state-checked paste workloads."""
import argparse
import hashlib
import json
import resource
import subprocess
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--shell", action="append", required=True, type=Path)
    parser.add_argument("--labs", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    shells = [shell.resolve(strict=True) for shell in args.shell]
    worker = Path(__file__).resolve().parents[2] / "customer-workload.zsh"
    env = {"PATH": "/usr/bin:/bin", "LC_ALL": "C.UTF-8"}
    report = {"binary_sha256": {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in shells},
              "worker_sha256": hashlib.sha256(worker.read_bytes()).hexdigest(),
              "environment": env, "runs": []}
    for name in ("chat", "coder"):
        project = args.labs.resolve(strict=True) / ("z" + name + ".zsh")
        case = name + "-paste"
        expected = None
        for sample in range(5):
            for shell in (reversed(shells) if sample % 2 else shells):
                command = [str(shell), "-df", str(worker), case, str(project), "1"]
                before = resource.getrusage(resource.RUSAGE_CHILDREN)
                run = subprocess.run(command, env=env, capture_output=True, check=True, timeout=120)
                after = resource.getrusage(resource.RUSAGE_CHILDREN)
                state = run.stdout.partition(b"\n")[2]
                if run.stderr or not state or (expected is not None and expected != state):
                    raise ValueError(f"{case}: unexpected result from {shell}")
                expected = state
                report["runs"].append({"case": case, "sample": sample, "command": command,
                                       "state_sha256": hashlib.sha256(state).hexdigest(),
                                       "minor_faults": after.ru_minflt - before.ru_minflt,
                                       "major_faults": after.ru_majflt - before.ru_majflt})
    args.output.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
