function git_status -a color_clean color_unmerged color_staged color_changed color_untracked color_reset
	# Print git status and untracked, unmerged, changed and staged files count
	set -l state (command git status --porcelain ^/dev/null | command awk '
		BEGIN { untracked = 0; unmerged = 0; changed = 0; staged = 0 }
		$0 ~ /^\?\?/                   { untracked++ }
		$0 ~ /^(DD|AU|UD|UA|DU|AA|UU)/ { unmerged++ }
		$0 ~ /^.[MD]/                  { changed++ }
		$0 ~ /^[MADRC]./               { staged++ }
		END { printf "%d\n%d\n%d\n%d\n", untracked, unmerged, changed, staged }
	')
    set -l untracked $state[1]
    set -l unmerged $state[2]
    set -l changed $state[3]
    set -l staged $state[4]

    if test $untracked -eq 0 -a $unmerged -eq 0 -a $changed -eq 0 -a $staged -eq 0
        set_color $color_clean
        echo -sn " ✔"
    else
        if test $unmerged -gt 0
            set_color $color_unmerged
            echo -sn " ✖$unmerged"
        end

        if test $staged -gt 0
            set_color $color_staged
            echo -sn " ✚$staged"
        end

        if test $changed -gt 0
            set_color $color_changed
            echo -sn " *$changed"
        end

        if test $untracked -gt 0
            set_color $color_untracked
            echo -sn " …$untracked"
        end
    end

    set_color $color_reset
end
