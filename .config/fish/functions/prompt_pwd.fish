function prompt_pwd -a color_normal color_git_root color_reset color_background
	set -l home ~
	set -l pwd_short (string replace -r "^$home" '~' $PWD)
	set -l git_root (command git rev-parse --show-toplevel ^/dev/null)
	set -l git_root_short (string replace -r "^$home" '~' $git_root)

	if begin; test -n $git_root; and test "$git_root" != "$home"; and test (string match -r "^$git_root_short" $pwd_short); end
		set -l pwd_tail (string replace -r "^$git_root_short" '' $pwd_short)
		set -l git_root_shortest (string replace -r -a '([^/])[^/]+/' '$1/' $git_root_short)
		set -l git_root_head (string replace -r '[^/]+$' '' $git_root_shortest)
		set -l git_root_basename (string replace -r '^.*/' '' $git_root_shortest)
		set_color $color_normal -b $color_background
		echo -sn $git_root_head
		set_color $color_git_root -b $color_background
		echo -sn $git_root_basename
		set_color $color_normal -b $color_background
		echo -sn $pwd_tail
		set_color $color_reset -b $color_background
	else
		set_color $color_normal -b $color_background
		echo -sn $pwd_short
		set_color $color_reset -b $color_background
	end
end
