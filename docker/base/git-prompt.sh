#!/bin/bash

# Git-friendly prompt functions
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* //'
}

parse_git_status() {
    local git_status=$(git status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
        echo " *"
    else
        echo ""
    fi
}

# Set git-aware PS1 prompt
export PS1='\[\033[01;34m\]\w\[\033[00m\]$(parse_git_branch | sed "s/.*/ (\033[01;33m&\033[00m)/")$(parse_git_status)\$ '