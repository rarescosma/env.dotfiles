#!/usr/bin/env python3
import os
from glob import glob
from typing import List
import re
from pprint import pprint as log
from unittest import TestCase
import time
from shutil import rmtree
import sys


_seedbox_dir = '/mnt/seedbox'
_resume_dir = '{}/resume'.format(_seedbox_dir)
_fresh_dir = '{}/fresh'.format(_seedbox_dir)
_non_alpha_re = re.compile('[^0-9a-zA-Z]+')

def get_torrents(from_dir: str ='.') -> List[str]:
    torrents = map(os.path.basename, glob('{}/**/*.torrent'.format(from_dir)))
    return list(torrents)

def torrent_to_parts(torrent: str) -> List[str]:
    # Remove extension
    torrent = os.path.splitext(torrent)[0]

    # Ignore [[0-9]+]
    torrent = re.sub("^\[[0-9]+\]", '', torrent)

    # Split by '-', '.' or '_' and select the highest count
    max_parts, the_parts = 0, []
    for sep in ['-', '.', '_']:
        parts = list(filter(None, torrent.split(sep)))
        if len(parts) > max_parts:
            max_parts, the_parts = len(parts), parts

    return list(filter(None, map(remove_non_alpha, the_parts)))

def parts_to_matcher(torrent_parts: List[str]) -> str:
    parts = list(map(re.escape, torrent_parts))
    for i, p in enumerate(parts):
        if p.endswith('s'):
            parts[i] = '{}?'.format(p)
    return '.*'.join(parts)


def torrent_to_matcher(torrent: str) -> str:
    return parts_to_matcher(torrent_to_parts(torrent))

def remove_non_alpha(input_str: str) -> str:
    return _non_alpha_re.sub('', input_str)

def get_undesirables(nodes: List[str], torrents: List[str]) -> List[str]:
    matchers = map(torrent_to_matcher, torrents)
    bigass_re = re.compile('^.*({}).*$'.format('|'.join(matchers)), re.IGNORECASE)
    return [node for node in nodes if bigass_re.match(remove_non_alpha(node)) is None]

def nuke_it(path: str):
    try:
        rmtree(path)
    except FileNotFoundError:
        pass
    except NotADirectoryError:
        try:
            os.remove(path)
        except Exception:
            pass

tests = [
    (
        ["Asimov - Robot, Empire and Foundation Series"],
        ["[220870]_Asimovs_Robot,_Empire,_and_Foundation_Series.torrent"]
    )
]

def run_tests():
    tc = TestCase()
    for args in tests:
        tc.assertEquals(get_undesirables(*args), [])


if __name__ == '__main__':
    # run_tests()
    really_nuke = (sys.argv[-1] == '-y')
    now = time.time()

    nodes = [os.path.basename(x) for x in glob(_fresh_dir + '/*')
             if not x.endswith('.meta')]

    undesirables = get_undesirables(
        nodes,
        get_torrents(_resume_dir)
    )

    # Delete older than 3 days
    for x in sorted(undesirables):
        full_path = os.path.join(_fresh_dir, x)
        if (os.stat(full_path).st_mtime < now - 3 * 86400):
            print("Deleting {}".format(full_path))
            really_nuke and nuke_it(full_path)
        else:
            print("Skipping {}".format(full_path))
