###############################################################################
# Set zsh options
###############################################################################

autoload -U colors && colors    # initialize colors

autoload -U select-word-style
select-word-style bash          # word characters are alphanumeric characters only

autoload -U add-zsh-hook        # we will use zsh hooks in config later

#== Base ======================================================================
setopt EMACS                    # emacs shortcuts (same as 'bindkey -e')
setopt NO_BEEP                  # do not beep on errors
setopt MULTIOS                  # allows multiple input and output redirections
setopt NO_FLOW_CONTROL          # disable stupid annoying keys
setopt INTERACTIVE_COMMENTS     # allow comments even in interactive shells

#== Commands cd & pushd =======================================================
setopt AUTO_PUSHD               # this makes cd=pushd
setopt PUSHD_TO_HOME            # blank pushd goes to home

#== Completion ================================================================
setopt COMPLETE_ALIASES         # completion uses unexpanded aliases
setopt COMPLETE_IN_WORD         # allow completion from within a word/phrase
setopt ALWAYS_TO_END            # when completing from the middle of a word, move the cursor to the end of the word

#== Prompt ====================================================================
setopt PROMPT_CR                # prompt always at start of line
setopt PROMPT_SUBST             # enable parameter expansion, command substitution, and arithmetic expansion in the prompt

#== History ===================================================================
setopt APPEND_HISTORY           # history appends to existing file
setopt HIST_EXPIRE_DUPS_FIRST   # duplicate history entries lost first
setopt HIST_FIND_NO_DUPS        # history search finds once only
setopt HIST_IGNORE_ALL_DUPS     # remove all earlier duplicate lines
setopt HIST_IGNORE_SPACE        # don’t store lines starting with space
setopt HIST_REDUCE_BLANKS       # trim multiple insgnificant blanks in history
setopt EXTENDED_HISTORY         # save the time and how long a command ran
setopt HIST_IGNORE_SPACE        # lines which begin with a space don't go into the history
setopt HIST_NO_STORE            # not to store history or fc commands

HISTFILE=~/.histfile    # history file location
HISTSIZE=1000000        # number of history lines kept internally
SAVEHIST=1000000        # max number of history lines saved


###############################################################################
# Completion
###############################################################################

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

# show menu but don't select first completion
zstyle ':completion:*' menu select=1
setopt auto_menu
unsetopt menu_complete

# load additional completions
[ -f /usr/local/include/php/arcanist/resources/shell/bash-completion ] && source /usr/local/include/php/arcanist/resources/shell/bash-completion
[ -f /usr/local/share/zsh/site-functions/go ] && source /usr/local/share/zsh/site-functions/go


###############################################################################
# Exports
###############################################################################

set TERM xterm-256color; export TERM    # let the system know how cool we are

export LC_ALL=ru_RU.UTF-8               # utf-8 only
export LANG=ru_RU.UTF-8                 # it's 21st century now
export LC_COLLATE=C                     # CTAGS Sorting in VIM/Emacs is better behaved with this in place

umask 0022                              # set permissions for files: 0644, for directories: 0755

export EDITOR="vim"                     # default editor
export PAGER=less                       # default pager

export PGHOST=/tmp                      # postgres won't work without this

# add some directories to my PATH
[ -d $HOME/.bin ] && PATH=$HOME/.bin:$PATH
[ -d /usr/local/bin ] && PATH=/usr/local/bin:$PATH
[ -d /usr/local/sbin ] && PATH=/usr/local/sbin:$PATH

# setup Google Cloud SDK
# On Mac OS X:
#   brew tap caskroom/cask
#   brew cask install google-cloud-sdk
if [[ -d /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk ]]; then
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
fi

# setup python virtualenv
export PROJECT_HOME=~/work/
export WORKON_HOME=~/work/.venv/
export VIRTUAL_ENV_DISABLE_PROMPT=1
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad

# Enable color in grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='3;33'

# Go paths
export GOPATH=$HOME/work/go
export PATH=$PATH:$GOBIN:$GOPATH/bin


###############################################################################
# Helpful hooks and functions for prompt
###############################################################################

[ -e /usr/local/bin/growlnotify ] && export LONG_CMD_GROWL_NOTIFY_ENABLED=1

# check elapsed time after command execution
ELAPSED_TIME=
ELAPSED_TIME_PLAIN=
ELAPSED_TIME_TOOLONG=
ELAPSED_TIME_NEED_BELL=
function __calc_elapsed_time {
    local timer_result
    ELAPSED_TIME=
    ELAPSED_TIME_PLAIN=
    ELAPSED_TIME_TOOLONG=
    ELAPSED_TIME_NEED_BELL=

    [[ -z $__PREVIOUS_COMMAND_LINE ]] && return

    timer_result=$(($SECONDS-$__CMD_START_TIME))
    if [[ $timer_result -ge 1 ]]; then
        ELAPSED_TIME_NEED_BELL=1  # 1 sec is enough for bell =)
    fi
    if [[ $timer_result -gt 10 ]]; then
        if [[ $timer_result -ge 600 ]]; then
            ELAPSED_TIME_TOOLONG=1  # 10 min is too long =)
        fi
        if [[ $timer_result -ge 3600 ]]; then
            let "timer_hours = $timer_result / 3600"
            let "remainder = $timer_result % 3600"
            let "timer_minutes = $remainder / 60"
            let "timer_seconds = $remainder % 60"
            ELAPSED_TIME_PLAIN="${timer_hours}h ${timer_minutes}m ${timer_seconds}s"
            ELAPSED_TIME="%F{red}$ELAPSED_TIME_PLAIN%f"
        elif [[ $timer_result -ge 60 ]]; then
            let "timer_minutes = $timer_result / 60"
            let "timer_seconds = $timer_result % 60"
            ELAPSED_TIME_PLAIN="${timer_minutes}m ${timer_seconds}s"
            ELAPSED_TIME="%F{yellow}$ELAPSED_TIME_PLAIN%f"
        elif [[ $timer_result -ge 10 ]]; then
            ELAPSED_TIME_PLAIN="${timer_result}s"
            ELAPSED_TIME="%F{green}$ELAPSED_TIME_PLAIN%f"
        fi
    fi
    __reset_cmd_start_time
}

# notify user about elapsed time
function __growl_notify_elapsed_time {
    local sticky

    if [ $__PREVIOUS_COMMAND_LINE ] && [ $ELAPSED_TIME ]; then
        [ $ELAPSED_TIME_TOOLONG ] && sticky='-s'
        echo $__PREVIOUS_COMMAND_LINE | /usr/local/bin/growlnotify $sticky -t "Finished for $ELAPSED_TIME_PLAIN:" -m -
    fi
}

# visual bell to be catched by iTerm2 and trigger Dock icon bounce
function __bell_elapsed_time {
    [ $ELAPSED_TIME_NEED_BELL ] && echo -ne '\a'
}

# update terminal tab title
function __update_title {
    local title=${PWD/${HOME}/\~}
    echo -ne "\e]2;${title}\a"
    if [ $#title -gt 26 ]; then
        echo -ne "\e]1;…${title: -24}\a"
    else
        echo -ne "\e]1;${title}\a"
    fi
}

# save start time to variable before command execution
function __reset_cmd_start_time {
    __CMD_START_TIME=$SECONDS
}
__reset_cmd_start_time  # reset command start time right now

# save previous command line
__PREVIOUS_COMMAND_LINE=
function save-previous-command-line {
    __PREVIOUS_COMMAND_LINE=$BUFFER
    zle accept-line
}

# save exit status code
EXIT_CODE=
function __save_exit_status {
    if [ -n $? ]; then
        if [ "$?" -eq "0" ]; then
            EXIT_CODE=
        else
            EXIT_CODE="%F{red}$?%f"
        fi
    fi
}

# preexec hook
function __prompt_preexec {
    __reset_cmd_start_time
}

# precmd hook
function __prompt_precmd {
    __save_exit_status
    __calc_elapsed_time
    __bell_elapsed_time
    [ $LONG_CMD_GROWL_NOTIFY_ENABLED ] && __growl_notify_elapsed_time
    __update_title
}

# setup zsh hooks
zle -N save-previous-command-line
bindkey '^M' save-previous-command-line
add-zsh-hook preexec __prompt_preexec
add-zsh-hook precmd __prompt_precmd

# clear scrollback
function cls() {
    clear

    if [[ -n "${TMUX}" ]]; then
        if [[ -f /usr/local/bin/tmux ]]; then
            /usr/local/bin/tmux clearhist
        elif [[ -f /usr/bin/tmux ]]; then
            /usr/bin/tmux clearhist
        fi
    elif [[ "${TERM_PROGRAM}" == "iTerm.app" ]]; then
        printf '\e]50;ClearScrollback\a'
    else
        tput reset
    fi
}
# clear screen and clear scrollback
bindkey -s '^L' '^qcls\n'


###############################################################################
# Prompt
###############################################################################

if [ -f ~/.hostname ]; then
    LOCAL_HOSTNAME=`cat ~/.hostname`
else
    LOCAL_HOSTNAME=$(hostname)
fi

# print git status for cwd (if we're in git repo)
function __prompt_git_status {
    local cur_dir git_status git_vars
    local git_branch git_staged git_conflicts git_changed git_untracked git_ahead git_behind

    local cur_dir=$PWD
    while [[ ! -d "$cur_dir/.git" ]] && [[ ! "$cur_dir" == "/" ]] && [[ ! "$cur_dir" == "~" ]] && [[ ! "$cur_dir" == "" ]]; do cur_dir=${cur_dir%/*}; done
    if [[ -d "$cur_dir/.git" ]]; then
        # 'git repo for dotfiles' fix: show git status only in home dir and other git repos
        if [[ "$cur_dir" != "${HOME}" ]] || [[ "${PWD}" == "${HOME}" ]]; then
            git_status=`python ~/.zsh/prompt-git-status.py`
            git_vars=("${(@f)git_status}")

            if [ -n "$git_vars" ]; then
                git_branch=$git_vars[1]
                git_staged=$git_vars[3]
                git_changed=$git_vars[4]
                git_untracked=$git_vars[5]
                git_conflicts=$git_vars[6]
                git_ahead=$git_vars[7]
                git_behind=$git_vars[8]

                git_status="%F{cyan}$git_branch%f"
                if [[ "$git_ahead" -ne "0" ]] || [[ "$git_behind" -ne "0" ]]; then
                    git_status="$git_status "
                    [ "$git_behind" -ne "0" ] && git_status="$git_status%f↓$git_behind"
                    [ "$git_ahead" -ne "0" ]  && git_status="$git_status%f↑$git_ahead"
                fi
                if [[ "$git_conflicts" -eq "0" ]] && [ "$git_staged" -eq "0" ] && [ "$git_changed" -eq "0" ] && [ "$git_untracked" -eq "0" ]; then
                    git_status="$git_status %F{green}✔%f"
                else
                    [ "$git_conflicts" -ne "0" ]  && git_status="$git_status %F{red}✖$git_conflicts%f"
                    [ "$git_staged" -ne "0" ]     && git_status="$git_status %F{green}✚$git_staged%f"
                    [ "$git_changed" -ne "0" ]    && git_status="$git_status %F{blue}*$git_changed%f"
                    [ "$git_untracked" -ne "0" ]  && git_status="$git_status %F{yellow}…$git_untracked%f"
                fi
                echo -ne $git_status
            fi
        fi
    fi
}

function __build_prompt {
    local color_bg color_fg divider
    local prompt_git prompt_venv

    color_bg='7'
    color_fg='245'
    divider=" %F{15}║%f "

    # reset colors
    echo -n "%f%b%k%K{$color_bg}"

    # username and hostname
    # current working directory
    echo -n "%(!.%F{red}.%F{green})%n%F{$color_fg}@%F{yellow}${LOCAL_HOSTNAME}%F{$color_fg}:%F{240}%~%f"

    # git status
    prompt_git=$(__prompt_git_status)
    [ ! -z "$prompt_git" ] && echo -n "$divider%F{$color_fg}git:%f $prompt_git"

    # vitrualenv
    [ ! -z "$VIRTUAL_ENV" ] && echo -n "$divider%F{$color_fg}venv:%f %F{cyan}${VIRTUAL_ENV#$WORKON_HOME}%f"

    # goenv
    [ ! -z "$GOENV_PATH" ] && echo -n "$divider%F{$color_fg}go:%f %F{cyan}${GOENV_PATH}%f"

    # elapsed time
    [ ! -z "$ELAPSED_TIME" ] && echo -n "$divider%F{$color_fg}elapsed time:%f $ELAPSED_TIME"
    ELAPSED_TIME=

    # exit status
    [ ! -z "$EXIT_CODE" ] && echo -n "$divider%F{$color_fg}exit code:%f $EXIT_CODE"
    EXIT_CODE=

    # newline and command arrow
    echo -n "%E%f%k\n%F{black}➜%f "
}

# set prompt
export PROMPT=$'$(__build_prompt)'


###############################################################################
# Command line
###############################################################################

# set command line color
function command-line-colored {
    region_highlight=("0 $(( $CURSOR + $#RBUFFER )) fg=0")
}

function self-insert-colored { zle .self-insert; command-line-colored }
function magic-space-colored { zle .magic-space; command-line-colored }
function backward-delete-char-colored { zle .backward-delete-char; command-line-colored }
function accept-line-colored { zle .accept-line; command-line-colored }

zle -N self-insert self-insert-colored
zle -N magic-space magic-space-colored
zle -N backward-delete-char backward-delete-char-colored
zle -N accept-line accept-line-colored


###############################################################################
# Aliases
###############################################################################

if [ "$TERM" != "dumb" ]; then
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


###############################################################################
# Bind keys
###############################################################################

autoload -U history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# cycling through the history with the Up/Down keys
bindkey "\e[A" history-beginning-search-backward-end
bindkey "\e[B" history-beginning-search-forward-end

# move words by keys
bindkey '[C' forward-word
bindkey '[D' backward-word


###############################################################################
# Functions
###############################################################################

# cd & ls
function cdl {
    cd $1 && ls -lA
}

# mkdir & cd
function mkcd {
    mkdir -p "$@" && cd $_
}

# delete '*.pyc' files
function delpyc {
    find . -name '*.pyc' -delete
}

# OS X Quick Look alias
function show {
    qlmanage -p $1
}

# global pip commands
function syspip {
    PIP_REQUIRE_VIRTUALENV= sudo -H pip "$@"
}
function syspip3 {
    PIP_REQUIRE_VIRTUALENV= sudo -H pip3 "$@"
}


###############################################################################
# Other stuff
###############################################################################

# Load local zsh config
[ -e ~/.lzshrc ] && source ~/.lzshrc
