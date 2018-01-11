function fish_prompt_git --description 'Write out git status for fish prompt'
    set -l home ~
    set -l git_root (command git rev-parse --show-toplevel ^/dev/null)

    if test -z $git_root
        return
    end

    if test "$git_root" = "$home" -a "$PWD" != "$home"
        return
    end

    if set branch_name (git_branch_name cyan yellow red normal)
        # print git branch
        echo -sn $branch_name
        # print git stashed status
        echo -sn (git_stashed normal normal)
        # print git ahead status
        echo -sn (git_diverged normal normal)
        # get git status
        echo -sn (git_status green red green blue yellow normal)
    end
end
