function git_diverged -a color_diverged color_reset
	# Print git ahead-behind commits count if current branch is diverged
	set_color $color_diverged
	command git rev-list --count --left-right '@{upstream}...HEAD' ^/dev/null | command awk '
		$1 > 0 && $2 > 0 { print " ↓" $1 "↑" $2; exit 0 }
		$1 > 0           { print " ↓" $1;        exit 0 }
		$2 > 0           { print " ↑" $2;        exit 0 }
	'
	set_color $color_reset
end
