# ls aliases
alias ls='ls -G'
alias ll='ls -l'
alias la='ls -lA'

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

