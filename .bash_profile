# ~/.bashrc: executed by bash(1) for non-login shells. see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# add local bin path
PATH=$HOME/.bin:$PATH
PATH=/usr/local/bin:$PATH
PATH=/usr/local/sbin:$PATH
PATH=/usr/local/mysql/bin:$PATH

# don't put duplicate lines in the history
export HISTCONTROL=ignoreboth,erasedups
# set history length
HISTFILESIZE=1000000000
HISTSIZE=1000000

# append to the history file, don't overwrite it
shopt -s histappend
# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize
# correct minor errors in the spelling of a directory component in a cd command
shopt -s cdspell
# save all lines of a multiple-line command in the same history entry (allows easy re-editing of multi-line commands)
shopt -s cmdhist

# setup color variables
color_is_on=
color_red=
color_green=
color_yellow=
color_blue=
color_white=
color_gray=
color_off=
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_is_on=true
	color_red=$(/usr/bin/tput setaf 1)
	color_green=$(/usr/bin/tput setaf 2)
	color_yellow=$(/usr/bin/tput setaf 3)
	color_blue=$(/usr/bin/tput setaf 6)
	color_white=$(/usr/bin/tput setaf 7)
	color_gray=$(/usr/bin/tput setaf 8)
	color_off=$(/usr/bin/tput sgr0)
fi

# get git status
function parse_git_status {
	# clear git variables
	GIT_BRANCH=
	GIT_DIRTY=

	# exit if no git found in system
	local GIT_BIN=$(which git 2>/dev/null)
	[[ -z $GIT_BIN ]] && return

	# check we are in git repo
	local CUR_DIR=$PWD
	while [ ! -d ${CUR_DIR}/.git ] && [ ! $CUR_DIR = "/" ]; do CUR_DIR=${CUR_DIR%/*}; done
	[[ ! -d ${CUR_DIR}/.git ]] && return

	# 'git repo for dotfiles' fix: show git status only in home dir and other git repos
	[[ $CUR_DIR == $HOME ]] && [[ $PWD != $HOME ]] && return

	# get git branch
	GIT_BRANCH=$($GIT_BIN symbolic-ref HEAD 2>/dev/null)
	[[ -z $GIT_BRANCH ]] && return
	GIT_BRANCH=${GIT_BRANCH#refs/heads/}

	# get git status
	local GIT_STATUS=$($GIT_BIN status --porcelain 2>/dev/null)
	[[ -n $GIT_STATUS ]] && GIT_DIRTY=1
}

function prompt_command {
	local PS1_GIT=
	local PS1_VENV=

	# beautify working firectory name
	if [ ${HOME} == ${PWD} ]; then
		local PWDNAME="~"
	elif [ ${HOME} ==  ${PWD:0:${#HOME}} ]; then
		local PWDNAME="~${PWD:${#HOME}}"
	else
		local PWDNAME=${PWD}
	fi

	# parse git status and get git variables
	parse_git_status

	# build b/w prompt for git and vertial env
	[[ ! -z $GIT_BRANCH ]] && PS1_GIT=" (git: ${GIT_BRANCH})"
	[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${VIRTUAL_ENV#$WORKON_HOME})"

	# calculate fillsize
	local fillsize=$(($COLUMNS-$(printf "${USER}@${HOSTNAME}:${PWDNAME}${PS1_GIT}${PS1_VENV} " | wc -c | tr -d " ")))

	local FILL=$color_gray
	while [ $fillsize -gt 0 ]; do
		FILL="${FILL}-"
		fillsize=$(($fillsize-1))
	done
	FILL="${FILL}${color_off}"

	local color_user=
	if $color_is_on; then
		# set user color
		case `id -u` in
			0) color_user=$color_red ;;
			*) color_user=$color_green ;;
		esac

		# build git status for prompt
		if [ ! -z $GIT_BRANCH ]; then
			if [ -z $GIT_DIRTY ]; then
				PS1_GIT=" (git: ${color_green}${GIT_BRANCH}${color_off})"
			else
				PS1_GIT=" (git: ${color_red}${GIT_BRANCH}${color_off})"
			fi
		fi

		# build python venv status for prompt
		[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${color_blue}${VIRTUAL_ENV#$WORKON_HOME}${color_off})"
	fi

	# set new color prompt
	PS1="${color_user}${USER}${color_off}@${color_yellow}${HOSTNAME}${color_off}:${color_white}${PWDNAME}${color_off}${PS1_GIT}${PS1_VENV} ${FILL}\n➜ "

	# get cursor position and add new line if we're not in first column
	echo -en "\E[6n" && read -sdR CURPOS
	CURPOS=${CURPOS#*[}
	CURPOS=${CURPOS/*;/}
	[[ $CURPOS -gt 1 ]] && echo "$(/usr/bin/tput setab 1)$(/usr/bin/tput setaf 7)↵${color_off}"

	# set title
	echo -ne "\033]0;${USER}@${HOSTNAME}:${PWDNAME}"; echo -ne "\007"
}

# set prompt command (title update and color prompt)
PROMPT_COMMAND=prompt_command
# set new b/w prompt (will be overwritten in 'prompt_command' later for color prompt)
PS1='\u@\h:\w\$ '

# python virtualenv
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
	export PROJECT_HOME=~/work/
	export WORKON_HOME=~/work/.venv/
	export VIRTUAL_ENV_DISABLE_PROMPT=1
	source /usr/local/bin/virtualenvwrapper.sh
fi

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

