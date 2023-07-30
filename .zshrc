###############################################################################
# Set zsh options
###############################################################################

# initialize colors
autoload -U colors && colors

# word characters are alphanumeric characters only
autoload -U select-word-style && select-word-style bash

#== Base ======================================================================
setopt EMACS                    # emacs shortcuts (same as 'bindkey -e')
setopt NO_BEEP                  # do not beep on errors
setopt MULTIOS                  # allows multiple input and output redirections
setopt NO_FLOW_CONTROL          # disable stupid annoying keys
setopt INTERACTIVE_COMMENTS     # allow comments even in interactive shells

#== Commands cd & pushd =======================================================
setopt AUTO_PUSHD               # this makes cd=pushd
setopt PUSHD_IGNORE_DUPS        # don’t push multiple copies of the same directory onto the directory stack
setopt PUSHD_SILENT             # do not print the directory stack after pushd or popd
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

HISTFILE=~/.histfile            # history file location
HISTSIZE=1000000                # number of history lines kept internally
SAVEHIST=1000000                # max number of history lines saved


###############################################################################
# Completion
###############################################################################

# load the completion module
zstyle :compinstall filename "${ZDOTDIR:-~}/.zshrc"
autoload -Uz compinit && compinit

# insert next character of first match automatically
setopt menu_complete

# The zsh/complist module offers three extensions to completion
# listings: the ability to highlight matches in such a list, the ability
# to scroll through long lists and a different style of menu completion.
# http://www.cims.nyu.edu/cgi-systems/info2html?(zsh)The%2520zsh%2Fcomplist%2520Module
zmodload zsh/complist

# graphical menu for completion list (autoselect first completion on open)
zstyle ':completion:*' menu yes select

# colorize files completions
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# list of directories to get commands from for sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# list of directories to complete cd and pushd commands
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories'

# show menu but don't select first completion
zstyle ':completion:*' menu select=1
setopt auto_menu
unsetopt menu_complete

# load additional completions
[ -f /usr/local/share/zsh/site-functions/go ] && source /usr/local/share/zsh/site-functions/go


###############################################################################
# Exports
###############################################################################

set TERM xterm-256color; export TERM    # let the system know how cool we are

export LC_ALL=en_US.UTF-8               # utf-8 only
export LANG=en_US.UTF-8                 # it's 21st century now
export LC_COLLATE=C                     # CTAGS Sorting in VIM/Emacs is better behaved with this in place

umask 0022                              # set permissions for files: 0644, for directories: 0755

export PAGER=less                       # default pager

export PGHOST=/tmp                      # postgres won't work without this

# add some directories to my PATH
[ -d $HOME/.bin ] && PATH=$HOME/.bin:$PATH
[ -d /usr/local/bin ] && PATH=/usr/local/bin:$PATH

# setup Google Cloud SDK
# On Mac OS X:
#   brew tap caskroom/cask
#   brew cask install google-cloud-sdk
if [[ -d /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk ]]; then
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
fi

# work with projects
source $HOME/.zsh/proj.zsh

# Go paths
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
export GREP_COLOR='3;33'

if [ "$TERM" != "dumb" ]; then
    case $OSTYPE in
        linux*)
            export LS_OPTIONS='--color=auto'
        ;;
        darwin*)
            export LS_OPTIONS='-G'
        ;;
    esac
fi


###############################################################################
# Aliases
###############################################################################

# ls aliases
alias ls='ls -G $LS_OPTIONS'
alias ll='ls -l $LS_OPTIONS'
alias la='ls -lA $LS_OPTIONS'

# grep aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ag aliaces
alias ag='/usr/local/bin/ag -s --color-match="1;33" --color-path=32 --color-line-number=32'
alias agpy='ag --python'
alias agjs='ag --js'

# tree alias ('tree' will always colorize output)
alias tree='tree -AC --dirsfirst'

# pwd and cd aliases
alias .='pwd'
alias ..='cd ..'
alias ...='cd ../..'

# exit
alias :q='exit'

# brew update, upgrade and cleanup
alias bubu='brew update && brew upgrade && brew cleanup'


###############################################################################
# Editor
###############################################################################
export EDITOR="vim"
alias e=$EDITOR


# Plugins
###############################################################################

# set prompt
source ~/.zsh/prompt.zsh
export PROMPT=$'$(__build_prompt)'
export RPROMPT=$'$(__build_rprompt)'

# clear screen and scrollback
source ~/.zsh/cls.zsh

# command line helpful tools
source ~/.zsh/command-line.zsh


###############################################################################
# Bind keys
###############################################################################

# save previous line on command execute with "Enter" key
bindkey "^M" save-previous-command-line

# clear screen and scrollback with "Ctrl+L" shortcut
# needs Key Mapping in iTerm: "Cmd+L" -> "Send Hex Codes: 0xc"
bindkey "^L" cls

# accept autosuggest and execute it with "Ctrl+Enter" shortcut
# needs Key Mapping in iTerm: "Cmd+Enter" -> "Send Hex Codes: 0xa"
bindkey "^J" command-line-execute

# cycling through the history with the "Up" and "Down" keys
bindkey "\e[A" command-line-history-search-backward
bindkey "\e[B" command-line-history-search-forward

# move words by keys
# needs Key Mapping in iTerm: "Ctrl+Left": "Send Escape Sequence: b"
# needs Key Mapping in iTerm: "Ctrl+Right": "Send Escape Sequence: f"
# needs Key Mapping in iTerm: "Alt+Left": "Send Escape Sequence: b"
# needs Key Mapping in iTerm: "Alt+Right": "Send Escape Sequence: f"

# disable flow control (Ctrl+S, Ctrl+Q)
stty -ixon -ixoff

###############################################################################
# Other stuff
###############################################################################

# Load local hostname
[ -f ~/.hostname ] && LOCAL_HOSTNAME=`cat ~/.hostname`

# Load local zsh config
[ -e ~/.lzshrc ] && source ~/.lzshrc

export PATH="/usr/local/opt/node@16/bin:$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Setup virtualenvwrapper
# export VIRTUAL_ENV_DISABLE_PROMPT=1
[ -e /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/node@18/bin:$PATH"
