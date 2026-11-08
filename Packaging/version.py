"""Read the separate project and upstream identities from their source files."""
from pathlib import Path
import re


def versions(root):
    root = Path(root)
    project = re.search(r'^#define PSH_VERSION "([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?)"$',
                        (root / "Src/psh_version.h").read_text(), re.M)
    upstream = re.search(r'^VERSION=([0-9]+\.[0-9]+(?:\.[0-9]+)?)$',
                         (root / "Config/version.mk").read_text(), re.M)
    if not project or not upstream:
        raise ValueError("invalid project or upstream version")
    return project[1], upstream[1]
