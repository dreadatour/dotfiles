# ~/.bashrc: executed by bash(1) for non-login shells. see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# add local bin path
PATH=$HOME/.bin:$PATH
PATH=/usr/local/bin:$PATH
PATH=/usr/local/sbin:$PATH
PATH=/usr/local/mysql/bin:$PATH
PATH=/usr/local/Cellar/gettext/0.18.1.1/bin:$PATH

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoreboth,erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTFILESIZE=1000000000
HISTSIZE=1000000

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# correct minor errors in the spelling of a directory component in a cd command
shopt -s cdspell

# save all lines of a multiple-line command in the same history entry (allows easy re-editing of multi-line commands)
shopt -s cmdhist

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# show git info in prompt
function ps1_git_status {
	local branch_color=$'\e[01;36m'
	local index_color=$'\e[01;32m'
	local modified_color=$'\e[01;31m'
	local untracked_color=$'\e[01;33m'
	local no_color=$'\e[0m'

	[[ -z $(which git 2>/dev/null) ]] && return

	local GIT_STATUS=$(/usr/bin/git status 2>/dev/null)
	[[ -z $GIT_STATUS ]] && return

	local GIT_BRANCH="$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
	if [[ "$GIT_BRANCH" == *'(no branch)'* ]]; then
		GIT_BRANCH='no branch'
	fi

	local GIT_STATE=''
	if [[ "$GIT_STATUS" != *'working directory clean'* ]]; then
		GIT_STATE=':'
		if [[ "$GIT_STATUS" == *'Changes to be committed:'* ]]; then
			GIT_STATE=$GIT_STATE"${index_color}I${no_color}"
		fi
		if [[ "$GIT_STATUS" == *'Changes not staged for commit:'* ]]; then
			GIT_STATE=$GIT_STATE"${modified_color}M${no_color}"
		fi
		if [[ "$GIT_STATUS" == *'Untracked files:'* ]]; then
			GIT_STATE=$GIT_STATE"${untracked_color}U${no_color}"
		fi
	fi

	echo -ne " (${branch_color}${GIT_BRANCH}${no_color}${GIT_STATE})"
}

# setup prompt: colorized or not
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# set colors
	case `id -u` in
		0)  ucolor='\[\e[01;31m\]';;
		*)  ucolor='\[\e[01;32m\]';;
	esac
	hcolor='\[\e[01;33m\]'
	ncolor='\[\e[0m\]'

	# set new color prompt
	PS1="${ucolor}\u${ncolor}@${hcolor}\h${ncolor}:\w\$(ps1_git_status)\n\$ "
else
	# set new b/w prompt
	PS1='\u@\h:\w\$ '
fi

# set title
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOST}:${PWD/#$HOME/~}"; echo -ne "\007"'

# python virtualenv
export PROJECT_HOME=~/work/
export WORKON_HOME=~/work/.venv/
source /usr/local/bin/virtualenvwrapper.sh

# grep colorize
export GREP_OPTIONS="--color=auto"

# bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
	. `brew --prefix`/etc/bash_completion
fi

# bash aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# this is for delete words by ^W
tty -s && stty werase ^- 2>/dev/null

