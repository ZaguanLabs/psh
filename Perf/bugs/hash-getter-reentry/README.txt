Nested associative getter bug report
===================================

Paste report.txt into a new message to zsh-workers@zsh.org and attach this
directory's source/log archive. Nothing in this bundle sends a message.

Files:
  report.txt       Mail-ready report, including direct compiler/run commands.
  hash_reentry.c   Minimal native module; no psh-specific interface.
  reproduce.zsh   Creates the two hashes, loads/runs/unloads the test module.
  reproduce.py    Optional Python 3 driver for recording both locales/modes.
  evidence/       Recorded output, statuses, build provenance and Memcheck logs.
  SHA256SUMS      Hashes of the other files in this bundle.

The source and build directories supplied to the compiler must belong to the
tested executable. Recompile the module when changing Zsh versions. Do not
reuse a module compiled against a different version's headers.

Optional recording driver, from this directory:

  python3 reproduce.py --source /absolute/path/to/zsh-source \
    --build /absolute/path/to/zsh-build \
    --shell /absolute/path/to/zsh-build/Src/zsh \
    --output /absolute/path/to/new-evidence

The driver records the tested shell's exit status in evidence.json. Its own
successful exit means recording completed, not that the shell passed.
The tested script returns 0 for correct A/B results, 1 for the demonstrated
wrong result, and 2 for fixture setup/load/unload failure. Valgrind uses 97
for a detected memory error. The supplied release and upstream results are
status 1 with zero Memcheck errors; the separate fixed control is status 0.

No installation, root access, external service or psh checkout is needed.
The archive intentionally contains source and text evidence, not compiled
shells or modules. Linux shared-module compiler flags are used in the report;
other operating systems have not been tested.
