"""Conservative host startup defaults; never replace an existing configuration."""
import hashlib
import os
from pathlib import Path
import shlex
import tempfile

ETC = Path('/usr/local/psh/etc')
NAMES = ('zshenv', 'zprofile', 'zshrc', 'zlogin', 'zlogout')


def distribution(path=Path('/etc/os-release')):
    for line in path.read_text().splitlines():
        if line.startswith('ID='):
            values = shlex.split(line[3:])
            return values[0] if len(values) == 1 else ''
    return ''


def defaults(identity):
    if identity == 'mageia':
        return {'zshrc': '''# psh: match Mageia's interactive Zsh environment initialization.
path=($path $HOME/bin)
export PATH
if [[ -r /etc/profile.d/lang.sh ]]; then
    emulate -R sh -c 'source /etc/profile.d/lang.sh'
fi
'''}
    if identity == 'almalinux':
        locale = '''() {
    emulate -L ksh
    if [ -r /etc/profile.d/lang.sh ]; then
        . /etc/profile.d/lang.sh
    fi
}
'''
        return {
            'zprofile': '# psh: match AlmaLinux Zsh login PATH and locale initialization.\n'
                        'PATH="$PATH:$HOME/bin"\nexport PATH\n' + locale,
            'zshrc': '# psh: AlmaLinux initializes non-login interactive locales here.\n'
                     'if [[ ! -o login ]]; then\n' + locale + 'fi\n'}
    return {}


def plan(identity, directory=ETC):
    return {name: {'action': 'preserve' if os.path.lexists(directory / name) else 'create',
                   'content': text} for name, text in defaults(identity).items()}


def apply(plan, directory=ETC):
    # Each file is published complete, with exclusive creation. Existing files
    # (including dangling symlinks) always belong to the administrator.
    directory.mkdir(mode=0o755, parents=True, exist_ok=True)
    if directory.is_symlink() or directory.stat().st_mode & 0o022:
        raise RuntimeError('startup directory must be a non-writable real directory: ' + str(directory))
    for name, entry in plan.items():
        if name not in NAMES:
            raise RuntimeError('unexpected startup filename')
        if entry['action'] != 'create':
            continue
        fd, temporary = tempfile.mkstemp(prefix='.psh-startup-', dir=directory)
        try:
            with os.fdopen(fd, 'w') as stream:
                stream.write(entry['content'])
                stream.flush()
                os.fsync(stream.fileno())
            os.chmod(temporary, 0o644)
            os.link(temporary, directory / name)  # fails if destination appeared
        finally:
            os.unlink(temporary)


def snapshot(directory=ETC):
    paths = [directory / name for name in NAMES]
    paths += [Path(p) for p in ('/etc/os-release', '/etc/profile.d/lang.sh',
                               '/etc/locale.conf', '/etc/sysconfig/i18n',
                               '/etc/zshenv', '/etc/zprofile', '/etc/zshrc')]
    result = {}
    for path in paths:
        if not os.path.lexists(path):
            result[str(path)] = None
        else:
            result[str(path)] = {'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                                 'symlink': os.readlink(path) if path.is_symlink() else None}
    return result
