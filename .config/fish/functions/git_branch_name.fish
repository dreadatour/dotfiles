function git_branch_name -a color_branch color_tag color_hash color_reset
    # check if we can get branch name and print it
    if set -l branch_name (command git symbolic-ref --short HEAD ^/dev/null)
        if test -n "$color_branch"
            set_color $color_branch
        end
        echo $branch_name
        if test -n "$color_reset"
            set_color $color_reset
        end
        return
    end

    # check if we can get tag name and print it
    if set -l tag_name (command git describe --tags --exact-match HEAD ^/dev/null)
        if test -n "$color_tag"
            set_color $color_tag
        else if test -n "$color_branch"
            set_color $color_branch
        end
        echo $tag_name
        if test -n "$color_reset"
            set_color $color_reset
        end
        return
    end

    # check if we can get commit hash and print it
    if set -l commit_hash (command git rev-parse --short HEAD ^/dev/null)
        if test -n "$color_hash"
            set_color $color_hash
        else if test -n "$color_branch"
            set_color $color_branch
        end
        echo $commit_hash
        if test -n "$color_reset"
            set_color $color_reset
        end
        return
    end
end
