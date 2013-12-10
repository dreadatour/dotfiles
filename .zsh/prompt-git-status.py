#!/usr/bin/env python
# coding: utf-8
"""
Copy-pasted from 'Informative git prompt for zsh' with small changes
Original: https://github.com/olivierverdier/zsh-git-prompt
"""
from __future__ import print_function
from subprocess import Popen, PIPE


def git_commit():
    """
    Get git HEAD commit hash.
    """
    git_cmd = ['git', 'rev-parse', '--short', 'HEAD']
    return Popen(git_cmd, stdout=PIPE).communicate()[0][:-1].decode('utf-8')


def parse_git_branch(line):
    """
    Parse 'git status -b --porcelain' command branch info output.

    Possible strings:
    - simple: "## dev"
    - detached: "## HEAD (no branch)"
    - ahead/behind: "## master...origin/master [ahead 1, behind 2]"

    Ahead/behind format:
    - [ahead 1]
    - [behind 1]
    - [ahead 1, behind 1]
    """
    branch = remote_branch = ''
    ahead = behind = 0

    if line == 'HEAD (no branch)':  # detached state
        branch = '#' + git_commit()
    elif '...' in line:  # ahead of or behind remote branch
        if ' ' in line:
            branches, ahead_behind = line.split(' ', 1)
        else:
            branches, ahead_behind = line, None
        branch, remote_branch = branches.split('...')

        if ahead_behind and ahead_behind[0] == '[' and ahead_behind[-1] == ']':
            ahead_behind = ahead_behind[1:-1]
            for state in ahead_behind.split(', '):
                if state.startswith('ahead '):
                    ahead = state[6:]
                elif state.startswith('behind '):
                    behind = state[7:]
    else:
        branch = line

    return branch, remote_branch, ahead, behind


def git_status():
    """
    Get git status.
    """
    git_cmd = ['git', 'status', '-b', '--porcelain']
    result, __ = Popen(git_cmd, stdout=PIPE).communicate()

    branch = remote_branch = ''
    staged = changed = untracked = unmerged = ahead = behind = 0
    for line in result.splitlines():
        line = line.decode('utf-8')
        prefix = line[0:2]
        line = line[3:]

        if prefix == '##':  # branch name + ahead & behind info
            branch, remote_branch, ahead, behind = parse_git_branch(line)
        elif prefix == '??':  # untracked file
            untracked += 1
        elif prefix in ('DD', 'AU', 'UD', 'UA', 'DU', 'AA', 'UU'):  # unmerged
            unmerged += 1
        else:
            if prefix[0] in ('M', 'A', 'D', 'R', 'C'):  # changes in index
                staged += 1
            if prefix[1] in ('M', 'D'):  # changes in work tree
                changed += 1

    return (branch, remote_branch, staged, changed, untracked, unmerged,
            ahead, behind)


if __name__ == '__main__':
    print('\n'.join(str(param) for param in git_status()))
