# Zsh Reference Card: http://www.bash2zsh.com/zsh_refcard/refcard.pdf
export LC_ALL=ru_RU.UTF-8
export LANG=ru_RU.UTF-8

#== Respect your history, dude! ===============================================
HISTFILE=~/.histfile           # history file location
HISTSIZE=1000000               # number of history lines kept internally
SAVEHIST=1000000               # max number of history lines saved
setopt APPEND_HISTORY          # history appends to existing file
setopt HIST_EXPIRE_DUPS_FIRST  # duplicate history entries lost first
setopt HIST_FIND_NO_DUPS       # history search finds once only
setopt HIST_IGNORE_ALL_DUPS    # remove all earlier duplicate lines
setopt HIST_IGNORE_SPACE       # don’t store lines starting with space
setopt HIST_REDUCE_BLANKS      # trim multiple insgnificant blanks in history


#== Base settings =============================================================
autoload -U colors && colors  # enable colors names
setopt EMACS                  # emacs shortcuts (same as 'bindkey -e')
setopt NO_BEEP                # do not beep on errors
setopt COMPLETE_ALIASES       # completion uses unexpanded aliases
# this is not for me:
#setopt AUTO_CD                # directory as command does cd
#setopt CORRECT_ALL            # correct spelling of all arguments


#== Prompt settings ===========================================================
setopt PROMPT_CR     # prompt always at start of line
setopt PROMPT_SUBST  # '$' expansion in prompts

# show git info in prompt
function __prompt_git_status {
	# check git is installed
	GIT_BIN=$(which git 2>/dev/null)
	[[ -z $GIT_BIN ]] && return

	# check we are in git repo
	CUR_DIR=$(pwd)
	while [ ! -d .git ] && [ ! $(pwd) = "/" ]; do cd ..; done
	[[ ! -d .git ]] && return

	# dotfiles in git fix: show git status only in home dir
	[[ $(pwd) == $HOME ]] && [[ $CUR_DIR != $(pwd) ]] && return

	# get git branch
	GIT_BRANCH=$($GIT_BIN symbolic-ref HEAD 2>/dev/null)
	[[ -z $GIT_BRANCH ]] && return
	GIT_BRANCH=${GIT_BRANCH#refs/heads/}

	# get git status
	GIT_STATUS=$($GIT_BIN status --porcelain 2>/dev/null)

	# get git state
	if [[ -z $GIT_STATUS ]]; then
		echo -ne "%{%F{green}%}${GIT_BRANCH}%{%f%}"
	else
		echo -ne "%{%F{red}%}${GIT_BRANCH}%{%f%}"
	fi
}

function __prompt_virtualenv {
	[ ! -z "$VIRTUAL_ENV" ] && echo -ne "%{%F{blue}%}${VIRTUAL_ENV#$WORKON_HOME}%{%f%}"
}

function __prompt_right {
	PROMPT_GIT=$(__prompt_git_status)
	PROMPT_VENV=$(__prompt_virtualenv)
	[ -z $PROMPT_GIT ] && [ -z $PROMPT_VENV ] && return
	[ ! -z $PROMPT_GIT ] && [ ! -z $PROMPT_VENV ] && echo -ne "${PROMPT_GIT} | ${PROMPT_VENV}" && return
	echo -ne "${PROMPT_GIT}${PROMPT_VENV}"
}

case `id -u` in
	0) PROMPT_USER_COLOR="%{%F{red}%}";;    # set color for root user in prompt
	*) PROMPT_USER_COLOR="%{%F{green}%}";;  # set color for regular user in prompt
esac
# set prompt
export PROMPT="${PROMPT_USER_COLOR}%n%{%f%}@%{%F{yellow}%}%m%{%f%}:%{%F{white}%}%~%{%f%} "
export RPROMPT="\$(__prompt_right)"
unset PROMPT_USER_COLOR


#== Setup system variables ====================================================
# let the system know how cool we are
set TERM xterm-256color; export TERM

# add some directories to my PATH
[ -d $HOME/.bin ] && PATH=$HOME/.bin:$PATH
[ -d /usr/local/bin ] && PATH=/usr/local/bin:$PATH
[ -d /usr/local/sbin ] && PATH=/usr/local/sbin:$PATH
[ -d /usr/local/mysql/bin ] && PATH=/usr/local/mysql/bin:$PATH
[ -d /usr/local/Cellar/gettext/0.18.1.1/bin ] && PATH=/usr/local/Cellar/gettext/0.18.1.1/bin:$PATH

# setup python virtualenv
export PROJECT_HOME=~/work/
export WORKON_HOME=~/work/.venv/
export VIRTUAL_ENV_DISABLE_PROMPT=1
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

# set permissions for files: 0644, for directories: 0755
umask 0022

# cycling through the history with the Up/Down keys
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward


#== Completions ===============================================================
# load the completion module
zstyle :compinstall filename "${ZDOTDIR:-~}/.zshrc"
autoload -Uz compinit && compinit

# insert next character of first match automatically
setopt menu_complete  # TODO: check this is usable

# The zsh/complist module offers three extensions to completion
# listings: the ability to highlight matches in such a list, the ability
# to scroll through long lists and a different style of menu completion.
# http://www.cims.nyu.edu/cgi-systems/info2html?(zsh)The%2520zsh%2Fcomplist%2520Module
zmodload zsh/complist  # TODO: is this important?

# graphical menu for completion list (autoselect first completion on open)
zstyle ':completion:*' menu yes select

# colorize files completions
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# list of directories to get commands from for sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# predictive typing using history search and auto-completion
# http://peadrop.com/blog/2007/04/07/welcome-to-mr-crystal-ball/
# TODO: check this is usable in future (disabled until checked)
#autoload -U predict-on
#zle -N predict-on
#bindkey '^Z'   predict-on
#bindkey '^X^Z' predict-off
#zstyle ':predict' verbose true


#== Aliases ===================================================================
# turn on colorize if needed
if [ "$TERM" != "dumb" ]; then
	if [ -x /usr/bin/dircolors ]; then
		eval "`dircolors -b`"
	else
		export LS_COLORS='no=00:fi=00:di=00;34:ln=00;36:pi=40;33:so=00;35:do=00;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=00;32:*.tar=00;31:*.tgz=00;31:*.svgz=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.bz2=00;31:*.bz=00;31:*.tbz2=00;31:*.tz=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.rar=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.jpg=00;35:*.jpeg=00;35:*.gif=00;35:*.bmp=00;35:*.pbm=00;35:*.pgm=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.tiff=00;35:*.png=00;35:*.svg=00;35:*.mng=00;35:*.pcx=00;35:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:';
	fi
	# fucking standarts (TODO: maybe we need to use `uname` here)
	case $OSTYPE in
		linux*)
			export LS_OPTIONS='--color=auto'
			export GREP_OPTIONS='--color=auto'
		;;
		darwin*)
			export LS_OPTIONS='-G'
			export GREP_OPTIONS='--color=auto'
		;;
	esac
fi

# ls aliases
alias ls='ls -G $LS_OPTIONS'
alias ll='ls -l $LS_OPTIONS'
alias la='ls -lA $LS_OPTIONS'

# grep aliases
alias grep='grep $GREP_OPTIONS'
alias fgrep='fgrep $GREP_OPTIONS'
alias egrep='egrep $GREP_OPTIONS'

# tree alias ('tree' will always colorize output)
alias tree='tree -AC --dirsfirst'

# pwd and cd aliases
alias .='pwd'
alias ..='cd ..'
alias ...='cd ../..'

# exit
alias :q='exit'

# colorize some stuff
GRC=`which grc`
if [ "$TERM" != dumb ] && [ -n GRC ]; then
	alias colourify="$GRC -es --colour=auto"
	alias configure='colourify ./configure'
	alias diff='colourify diff'
	alias make='colourify make'
	alias gcc='colourify gcc'
	alias g++='colourify g++'
	alias as='colourify as'
	alias gas='colourify gas'
	alias ld='colourify ld'
	alias netstat='colourify netstat'
	alias ping='colourify ping'
	alias traceroute='colourify /usr/sbin/traceroute'
fi

