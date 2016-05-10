#!/bin/sh

if [ ! -d "$HOME/.git" ]; then
    echo "Installing dotfiles:"
    tmpdir=`mktemp -d -t dotfiles.XXXXXXXX`
    git clone -q --recursive https://github.com/dreadatour/dotfiles.git $tmpdir
    ls -1A $tmpdir | while read fd; do
    	cp -r $tmpdir/$fd $HOME/
    	echo "- $fd"
    done
    rm -rf $tmpdir

	echo "Insalling Vim plugins"
	vim +PluginInstall +qall
else
    echo "Dotfiles are already installed"
fi
