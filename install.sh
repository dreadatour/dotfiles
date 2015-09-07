#!/bin/sh

if [ ! -d "$HOME/.git" ]; then
    echo "Installing dotfiles:"
    tmpdir=`mktemp -d -t dotfiles.XXXXXXXX`
    git clone --depth=1 https://github.com/dreadatour/dotfiles.git "$tmpdir"
    ls -1A "$tmpdir" | while read fd; do
    	mv "$tmpdir/$fd" $HOME/
    	echo "- $fd"
    done
else
    echo "Dotfiles are already installed"
fi
