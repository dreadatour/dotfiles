# ls aliases
alias ls='ls -G'
alias ll='ls -l'
alias la='ls -lA'

# tree aliaces
alias tree='tree --dirsfirst'

# git aliaces
alias gtree='git log --graph --full-history --all --color --pretty=format:"%x1b[33m%h%x09%x09%x1b[32m%d%x1b[0m %x1b[34m%an%x1b[0m   %s" "$@"'

# pwd and cd aliases
alias .='pwd'
alias ..='cd ..'
alias ...='cd ../..'

# mkdir
md() { mkdir -p "$@" && cd "$@"; }

# exit
alias q='logout'
alias :q='logout'

# other
div() {
	local columns=$(($(tput cols) - 8))
	local line=$(printf '%0.1s' "-"{1..500})
	printf "\e[01;31m---- 8< ${line:0:${columns}}\e[0m\n"
}

