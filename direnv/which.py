import os
import sys

executable, home = sys.executable, os.environ.get("HOME")
if home is not None and executable.startswith(home):
    executable = executable.replace(home, "~")
ver = sys.version.replace(" \n", " ")

print(f'\033[1m\033[94m>> {executable} \033[93m{ver} <<\033[0m\n')
