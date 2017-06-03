###############################################################################
# ZSH Prompt plugin
###############################################################################

autoload -U add-zsh-hook  # use zsh hooks

[ -e /usr/local/bin/growlnotify ] && LONG_CMD_GROWL_NOTIFY_ENABLED=1

# check elapsed time after command execution
ELAPSED_TIME=
ELAPSED_TIME_PLAIN=
ELAPSED_TIME_TOOLONG=
ELAPSED_TIME_NEED_BELL=
function __calc_elapsed_time {
    local timer_result
    ELAPSED_TIME=
    ELAPSED_TIME_PLAIN=
    ELAPSED_TIME_TOOLONG=
    ELAPSED_TIME_NEED_BELL=

    [[ -z $__PREVIOUS_COMMAND_LINE ]] && return

    timer_result=$(($SECONDS-$__CMD_START_TIME))
    if [[ $timer_result -ge 1 ]]; then
        ELAPSED_TIME_NEED_BELL=1  # 1 sec is enough for bell =)
    fi
    if [[ $timer_result -gt 10 ]]; then
        if [[ $timer_result -ge 600 ]]; then
            ELAPSED_TIME_TOOLONG=1  # 10 min is too long =)
        fi
        if [[ $timer_result -ge 3600 ]]; then
            let "timer_hours = $timer_result / 3600"
            let "remainder = $timer_result % 3600"
            let "timer_minutes = $remainder / 60"
            let "timer_seconds = $remainder % 60"
            ELAPSED_TIME_PLAIN="${timer_hours}h ${timer_minutes}m ${timer_seconds}s"
            ELAPSED_TIME="%F{red}$ELAPSED_TIME_PLAIN%f"
        elif [[ $timer_result -ge 60 ]]; then
            let "timer_minutes = $timer_result / 60"
            let "timer_seconds = $timer_result % 60"
            ELAPSED_TIME_PLAIN="${timer_minutes}m ${timer_seconds}s"
            ELAPSED_TIME="%F{yellow}$ELAPSED_TIME_PLAIN%f"
        elif [[ $timer_result -ge 10 ]]; then
            ELAPSED_TIME_PLAIN="${timer_result}s"
            ELAPSED_TIME="%F{green}$ELAPSED_TIME_PLAIN%f"
        fi
    fi
    __reset_cmd_start_time
}

# notify user about elapsed time
function __growl_notify_elapsed_time {
    local sticky

    if [ $__PREVIOUS_COMMAND_LINE ] && [ $ELAPSED_TIME ]; then
        [ $ELAPSED_TIME_TOOLONG ] && sticky='-s'
        echo $__PREVIOUS_COMMAND_LINE | /usr/local/bin/growlnotify $sticky -t "Finished for $ELAPSED_TIME_PLAIN:" -m -
    fi
}

# visual bell to be catched by iTerm2 and trigger Dock icon bounce
# TODO: check https://gist.github.com/jpouellet/5278239
# TODO: check https://github.com/dotphiles/dotzsh/tree/master/modules/notify
function __bell_elapsed_time {
    [ $ELAPSED_TIME_NEED_BELL ] && echo -ne '\a'
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
EXIT_CODE=
function __save_exit_status {
    if [ -n $? ]; then
        if [ "$?" -eq "0" ]; then
            EXIT_CODE=
        else
            EXIT_CODE="%F{red}$?%f"
        fi
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
    [ $LONG_CMD_GROWL_NOTIFY_ENABLED ] && __growl_notify_elapsed_time
    __update_title
}

# setup zsh hooks
zle -N save-previous-command-line __save_previous_command_line
add-zsh-hook preexec __prompt_preexec
add-zsh-hook precmd __prompt_precmd


# print git status for cwd (if we're in git repo)
LOCAL_HOSTNAME=$(hostname)
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

function __build_prompt {
    local color_bg color_fg divider
    local prompt_git prompt_venv

    color_bg='7'
    color_fg='245'
    divider=" %F{15}║%f "

    # reset colors
    echo -n "%f%b%k%K{$color_bg}"

    # username and hostname
    # current working directory
    echo -n "%(!.%F{red}.%F{green})%n%F{$color_fg}@%F{yellow}${LOCAL_HOSTNAME}%F{$color_fg}:%F{240}%~%f"

    # git status
    prompt_git=$(__prompt_git_status)
    [ ! -z "$prompt_git" ] && echo -n "$divider%F{$color_fg}git:%f $prompt_git"

    # project
    [ ! -z "$WORK_PROJECT" ] && echo -n "$divider%F{$color_fg}proj:%f %F{cyan}$WORK_PROJECT%f"

    # vitrualenv
    [ ! -z "$VIRTUAL_ENV" ] && echo -n "$divider%F{$color_fg}venv:%f %F{cyan}${VIRTUAL_ENV#$WORKON_HOME}%f"

    # elapsed time
    [ ! -z "$ELAPSED_TIME" ] && echo -n "$divider%F{$color_fg}elapsed time:%f $ELAPSED_TIME"
    ELAPSED_TIME=

    # exit status
    [ ! -z "$EXIT_CODE" ] && echo -n "$divider%F{$color_fg}exit code:%f $EXIT_CODE"
    EXIT_CODE=

    # newline and command arrow
    echo -n "%E%f%k\n%F{black}➜%f "
}
