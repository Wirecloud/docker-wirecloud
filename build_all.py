#!/usr/bin/env python
from __future__ import print_function
import os
import sys
import time
from os.path import join
from subprocess import Popen
from shutil import copy2

# DATA
PY2 = sys.version_info < (3, 0)
input = raw_input if PY2 else input

BASEDIR = '.'
BASE = "wirecloud/fiware-wirecloud:{tag}"
FILESDIR = join(BASEDIR, 'files')

STATICFILESNAMES = [[x.replace('./', '') for x in z] for x,y,z in os.walk(FILESDIR)]
STATICFILESNAMES = [] if len(STATICFILESNAMES) == 0 else STATICFILESNAMES[0]

ALLSTATICFILES = [join(FILESDIR, x).replace('./', '') for x in STATICFILESNAMES]

copy_files = lambda p: [copy2(x, p) for x in ALLSTATICFILES]
remove_files = lambda p: [os.remove(join(p,x)) for x in STATICFILESNAMES]

alias = {
    '0.7': 'latest',
    '0.7-composable': 'latest-composable'
}

ignored = ["hub-docs", "files"]

# Function to generate a line
line = lambda: "\033[93m" + "-" * 20 + "\033[0m"

# Generate directories and aliases
directories = [x.replace("./", "") for x,y,z in os.walk(BASEDIR)
 if not x.startswith('./.')
 and x != "."
 and not any([True for i in ignored if i in x])]

aliases = [(x, alias.get(x)) for x in directories if alias.get(x)]

# LOG
print(line())
print("\033[92mBuilding directories:\033[95m", ", ".join(directories), "\033[0m")
print("\033[92mBuilding aliases:\033[95m", ", ".join(["{} -> {}".format(x, y) for x,y in aliases]), "\033[0m")
print(line())
t = input("\033[93mEnter \"y\" if you want to continue the build (default \"y\"): ").lower()
if t and t  not in ["y"]:
    exit(0)

print("\033[92mCopying static files:\033[95m", ", ".join(ALLSTATICFILES), "\033[0m")
copied = [copy_files(tag) for tag in directories]

# Change the color of the output :)
print("\033[94m")

# Let's build them in parallel
popen_tag = lambda tag, src: Popen(['docker', 'build', '-t', BASE.format(tag=tag), join(BASEDIR, src)])


processes = [popen_tag(tag, tag) for tag in directories]
processes.extend([popen_tag(tag, d) for d, tag in aliases])

# Wait "asynchronously" and get the pids
while any(proc.poll() is None for proc in processes):
    time.sleep(0.2)
pids = [x.returncode for x in processes]

# Reset the color
print("\033[0m")

removed = [remove_files(tag) for tag in directories]

# Some pretty log :)
ok = True

print(line())

# Let's check if some build failed and say it
sum_dirs = directories + [x for _, x in aliases] # helper to print the name
for i in [i for i, pid in enumerate(pids) if pid != 0]:
    ok = False
    print("\033[91mBuild \"{}\" failed!\033[0m".format(sum_dirs[i]))
    print(line())

# Summary
prefix = "\033[92mBuilded" if ok else "\033[91mTried to build"
print(prefix, "directories:\033[95m", ", ".join(directories), "\033[0m")
print(prefix, "aliases:\033[95m", ", ".join(["{} -> {}".format(x, y) for x,y in aliases]), "\033[0m")
print(line())
