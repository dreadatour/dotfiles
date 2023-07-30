# ~/.bashrc: executed by bash(1) for non-login shells. see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# unset this because of nasty OS X bug with annoying message:
# "dyld: DYLD_ environment variables being ignored because main executable (/usr/bin/sudo) is setuid or setgid"
# this is not correct, but Apple is too lazy to fix this
unset DYLD_LIBRARY_PATH

# add local bin path
PATH=$HOME/.bin:$PATH
PATH=/usr/local/bin:$PATH
PATH=/usr/local/sbin:$PATH
[ -d /usr/local/mysql/bin ] && PATH=/usr/local/mysql/bin:$PATH
[ -d /usr/local/share/npm/bin ] && PATH=/usr/local/share/npm/bin:$PATH

# don't put duplicate lines in the history
export HISTCONTROL=ignoreboth:erasedups
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
color_bg_red=
color_off=
color_user=
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_is_on=true
	color_black="\[$(/usr/bin/tput setaf 0)\]"
	color_red="\[$(/usr/bin/tput setaf 1)\]"
	color_green="\[$(/usr/bin/tput setaf 2)\]"
	color_yellow="\[$(/usr/bin/tput setaf 3)\]"
	color_blue="\[$(/usr/bin/tput setaf 6)\]"
	color_white="\[$(/usr/bin/tput setaf 7)\]"
	color_gray="\[$(/usr/bin/tput setaf 8)\]"
	color_off="\[$(/usr/bin/tput sgr0)\]"

	color_error="$(/usr/bin/tput setab 1)$(/usr/bin/tput setaf 7)"
	color_error_off="$(/usr/bin/tput sgr0)"

	# set user color
	case `id -u` in
		0) color_user=$color_red ;;
		*) color_user=$color_green ;;
	esac
fi

# some kind of optimization - check if git installed only on config load
PS1_GIT_BIN=$(which git 2>/dev/null)

if [ -f ~/.hostname ]; then
	LOCAL_HOSTNAME=`cat ~/.hostname`
else
	LOCAL_HOSTNAME=$HOSTNAME
fi

function prompt_command {
	local PS1_GIT=
	local PS1_VENV=
	local GIT_BRANCH=
	local GIT_DIRTY=
	local PWDNAME=$PWD

	# beautify working directory name
	if [[ "${HOME}" == "${PWD}" ]]; then
		PWDNAME="~"
	elif [[ "${HOME}" == "${PWD:0:${#HOME}}" ]]; then
		PWDNAME="~${PWD:${#HOME}}"
	fi

	# parse git status and get git variables
	if [[ ! -z $PS1_GIT_BIN ]]; then
		# check we are in git repo
		local CUR_DIR=$PWD
		while [[ ! -d "${CUR_DIR}/.git" ]] && [[ ! "${CUR_DIR}" == "/" ]] && [[ ! "${CUR_DIR}" == "~" ]] && [[ ! "${CUR_DIR}" == "" ]]; do CUR_DIR=${CUR_DIR%/*}; done
		if [[ -d "${CUR_DIR}/.git" ]]; then
			# 'git repo for dotfiles' fix: show git status only in home dir and other git repos
			if [[ "${CUR_DIR}" != "${HOME}" ]] || [[ "${PWD}" == "${HOME}" ]]; then
				# get git branch
				GIT_BRANCH=$($PS1_GIT_BIN symbolic-ref HEAD 2>/dev/null)
				if [[ ! -z $GIT_BRANCH ]]; then
					GIT_BRANCH=${GIT_BRANCH#refs/heads/}

					# get git status
					local GIT_STATUS=$($PS1_GIT_BIN status --porcelain 2>/dev/null)
					[[ -n $GIT_STATUS ]] && GIT_DIRTY=1
				fi
			fi
		fi
	fi

	# build b/w prompt for git and virtual env
	[[ ! -z $GIT_BRANCH ]] && PS1_GIT=" (git: ${GIT_BRANCH})"
	[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${VIRTUAL_ENV#$WORKON_HOME})"

	# calculate prompt length
	local PS1_length=$((${#USER}+${#LOCAL_HOSTNAME}+${#PWDNAME}+${#PS1_GIT}+${#PS1_VENV}+3))
	local FILL=

	# if length is greater, than terminal width
	if [[ $PS1_length -gt $COLUMNS ]]; then
		# strip working directory name
		PWDNAME="...${PWDNAME:$(($PS1_length-$COLUMNS+3))}"
	else
		# else calculate fillsize
		local fillsize=$(($COLUMNS-$PS1_length))
		FILL=$color_white
		while [[ $fillsize -gt 0 ]]; do FILL="${FILL}-"; fillsize=$(($fillsize-1)); done
		FILL="${FILL}${color_off}"
	fi

	if $color_is_on; then
		# build git status for prompt
		if [[ ! -z $GIT_BRANCH ]]; then
			if [[ -z $GIT_DIRTY ]]; then
				PS1_GIT=" (git: ${color_green}${GIT_BRANCH}${color_off})"
			else
				PS1_GIT=" (git: ${color_red}${GIT_BRANCH}${color_off})"
			fi
		fi

		# build python venv status for prompt
		[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${color_blue}${VIRTUAL_ENV#$WORKON_HOME}${color_off})"
	fi

	# set new color prompt
	PS1="${color_user}${USER}${color_off}@${color_yellow}${LOCAL_HOSTNAME}${color_off}:${color_black}${PWDNAME}${color_off}${PS1_GIT}${PS1_VENV} ${FILL}\n➜ "

	# get cursor position and add new line if we're not in first column
	# cool'n'dirty trick (http://stackoverflow.com/a/2575525/1164595)
	# XXX FIXME: this hack broke ssh =(
#	exec < /dev/tty
#	local OLDSTTY=$(stty -g)
#	stty raw -echo min 0
#	echo -en "\033[6n" > /dev/tty && read -sdR CURPOS
#	stty $OLDSTTY
	echo -en "\033[6n" && read -sdR CURPOS
	[[ ${CURPOS##*;} -gt 1 ]] && echo "${color_error}↵${color_error_off}"

	# set title
	echo -ne "\033]0;${USER}@${LOCAL_HOSTNAME}:${PWDNAME}"; echo -ne "\007"
}

# set prompt command (title update and color prompt)
PROMPT_COMMAND=prompt_command
# set new b/w prompt (will be overwritten in 'prompt_command' later for color prompt)
PS1='\u@${LOCAL_HOSTNAME}:\w\$ '

# python virtualenv
if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
	export PROJECT_HOME=~/work/
	export WORKON_HOME=~/work/.venv/
	export VIRTUAL_ENV_DISABLE_PROMPT=1
	source /usr/local/bin/virtualenvwrapper.sh
fi

# Update python path
# XXX: this is necessary only for local machine
#[[ -d "/usr/local/lib/python2.7/site-packages" ]] && export PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"

# Postgres won't work without this
export PGHOST=/tmp

# grep colorize
export GREP_OPTIONS="--color=auto"

# bash completion
if [ -f /usr/local/bin/brew ]; then
	if [ -f `/usr/local/bin/brew --prefix`/etc/bash_completion ]; then
		. `/usr/local/bin/brew --prefix`/etc/bash_completion
	fi
fi

# bash aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# this is for delete words by ^W
tty -s && stty werase ^- 2>/dev/null

source "$HOME/.cargo/env"

