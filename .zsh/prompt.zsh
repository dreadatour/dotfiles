###############################################################################
# ZSH Prompt plugin
###############################################################################

autoload -U add-zsh-hook  # use zsh hooks
# autoload -U regexp-replace  # use zsh regexp-replace

# check elapsed time after command execution
__ELAPSED_TIME_NEED_BELL=
function __calc_elapsed_time {
    __ELAPSED_TIME_NEED_BELL=

    [ -z $__PREVIOUS_COMMAND_LINE ] && return

    # 1 sec is enough for bell since it will bell only on inactive terminal
    [ $(($SECONDS-$__CMD_START_TIME)) -ge 1 ] && __ELAPSED_TIME_NEED_BELL=1

    __reset_cmd_start_time
}

# visual bell to be catched by iTerm2 and trigger Dock icon bounce
# TODO: check https://gist.github.com/jpouellet/5278239
# TODO: check https://github.com/dotphiles/dotzsh/tree/master/modules/notify
function __bell_elapsed_time {
    [ $__ELAPSED_TIME_NEED_BELL ] && echo -ne '\a'
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
function __save_previous_command_line {
    __PREVIOUS_COMMAND_LINE=$BUFFER
    zle accept-line
}

# save exit status code
__EXIT_CODE=
function __save_exit_status {
    __EXIT_CODE=$?

    if [[ -z $__PREVIOUS_COMMAND_LINE ]] || [[ "$__EXIT_CODE" == "0" ]]; then
        __EXIT_CODE=
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
    __update_title
}

# setup zsh hooks
zle -N save-previous-command-line __save_previous_command_line
add-zsh-hook preexec __prompt_preexec
add-zsh-hook precmd __prompt_precmd

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

function __prompt_cwd {
    local color_fg='245'
    local color_git_root='black'

    local pwd_short=${PWD//#$HOME/\~}
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    local git_root_short=${git_root//#$HOME/\~}

    # shorten cwd if git repo is active and git repo is not dotfiles repo and we are inside git repo
    if [[ -n $git_root ]] && [[ "$git_root" != "$HOME" ]] && [[ "$PWD" == "$git_root"* ]]; then
        local cwd_tail=${pwd_short//#$git_root_short/}  # this is path inside git repo
        local git_root_parts=(${(s:/:)git_root_short})  # this is list of directories for git root path
        local cwd_basename=$git_root_parts[-1]          # this is name of git root directory
        local git_root_parts_letters=()                 # leave only first letter for all directories before git root
        for directory in $git_root_parts[1,-2]; do
            git_root_parts_letters+=$directory[1]
        done
        local cwd_head=${(j:/:)git_root_parts_letters}  # this is shorten path to get root directory

        echo -n "%F{${color_fg}}${cwd_head}/%F{${color_git_root}}${cwd_basename}%F{${color_fg}}${cwd_tail}%f"
    else
        echo -n "%F{${color_fg}}${pwd_short}%f"
    fi
}

function __build_prompt {
    local color_bg='255'
    local color_fg='245'
    local prompt_cwd=$(__prompt_cwd)

    echo -n "%f%b%k"  # reset colors

    # current working directory
    echo -n "%F{${color_fg}}%K{${color_bg}}${prompt_cwd}%f%k "

    echo -n "%f%b%k"  # reset colors
}

function __build_rprompt {
    local printed
    local prompt_git=$(__prompt_git_status)

    echo -n "%f%b%k"  # reset colors

    # exit status
    if [[ -n "$__EXIT_CODE" ]]; then
        [ -n "$printed" ] && echo -n " "
        echo -n "%F{red}${__EXIT_CODE}%f"
        printed=1
    fi

    # project
    if [[ -n "$WORK_PROJECT" ]]; then
        [ -n "$printed" ] && echo -n " "
        echo -n "%F{black}${WORK_PROJECT}%f"
        [ -n "$prompt_git" ] && echo -n ":"
        printed=1
    fi

    # git status
    if [[ -n "$prompt_git" ]]; then
        [ -n "$printed" ] && echo -n " "
        echo -n $prompt_git
        printed=1
    fi

    echo -n "%f%b%k"  # reset colors
}
