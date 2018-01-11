function git_stashed -a color_stashed color_reset
	# Print git stashed status
	if test (command git rev-parse --verify --quiet refs/stash ^/dev/null)
		set_color $color_stashed
		echo ' ⧖'
		set_color $color_reset
	end
end
