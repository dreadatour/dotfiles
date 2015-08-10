set __fish_git_prompt_show_informative_status 1
set __fish_git_prompt_showcolorhints          1
set __fish_git_prompt_char_cleanstate         ' ✔'
set __fish_git_prompt_char_dirtystate         ' ✚'
set __fish_git_prompt_char_invalidstate       ' ✖'
set __fish_git_prompt_char_stagedstate        ' *'
set __fish_git_prompt_char_stashstate         ' $'
set __fish_git_prompt_char_stateseparator     ''
set __fish_git_prompt_char_untrackedfiles     ' …'
set __fish_git_prompt_char_upstream_ahead     '↑'
set __fish_git_prompt_char_upstream_behind    '↓'
set __fish_git_prompt_char_upstream_diverged  ''
set __fish_git_prompt_char_upstream_equal     ''
set __fish_git_prompt_char_upstream_prefix    ' '


function __fish_prompt_user --description 'Returns current user name string for prompt'
    switch $USER
    case root toor
        set_color red
    case '*'
        set_color green
    end
    echo -n $USER
end

function __fish_prompt_host --description 'Returns current host name string for prompt'
    if not set -q __fish_prompt_hostname  # just calculate this once, to save a few cycles when displaying the prompt
        if test -e ~/.hostname
            # hostname will be taken from ~/.hostname file
            set -g __fish_prompt_hostname (cat ~/.hostname)
        else if test -e ~/.config/hostname
            # hostname will be taken from ~/.config/hostname file
            set -g __fish_prompt_hostname (cat ~/.config/hostname)
        else
            # hostname will be taken from hostname (wow!)
            set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
        end
    end

    set_color yellow
    echo -n $__fish_prompt_hostname
end

function __fish_prompt_cwd --description 'Returns current working directory string with home rewritten with ~'
    set -l realhome ~

    set_color normal -b white
    echo -n $PWD | sed -e "s|^$realhome|~|"
end

function __fish_prompt_venv --description 'Returns current virtualenv name'
    if set -q VIRTUAL_ENV
        echo -n -s $argv[1] ' venv: ' (set_color $__fish_venv_prompt_color) (basename "$VIRTUAL_ENV") (set_color $__fish_venv_prompt_color_done) (set_color $__fish_prompt_color_normal)
    end
end

function __fish_prompt_goenv --description 'Returns current goenv path'
    if set -q GOENV_PATH
        echo -n -s $argv[1] ' goenv: ' (set_color $__fish_goenv_prompt_color) $GOENV_PATH (set_color $__fish_goenv_prompt_color_done) (set_color $__fish_prompt_color_normal)
    end
end

# function __fish_prompt_exec_time --description 'Returns last command execution time'
#     # Taken from https://geraldkaszuba.com/tweaking-fish-shell/
#     set -l cmd_line (commandline)
#     if test -n "$cmd_line"
#         set -g last_cmd_line $cmd_line
#         set -ge new_prompt
#     else
#         set -g new_prompt true
#     end

#     set -l now (date +%s)
#     if test $last_exec_timestamp
#         set -l taken (math $now - $last_exec_timestamp)
#         if test $taken -gt 10 -a -n "$new_prompt"
#             error taken $taken
#             echo "Returned $last_status, took $taken seconds" | growlnotify -s $last_cmd_line
#             # Clear the last_cmd_line so pressing enter doesn't repeat
#             set -ge last_cmd_line
#         end
#     end
#     set -g last_exec_timestamp $now
# end

function fish_prompt --description 'Write out the prompt'
    set -l divider (set_color $__fish_prompt_color_divider)" ║"(set_color $__fish_prompt_color_normal)

    # prompt first line
    set_color $__fish_prompt_color_normal
    echo -n (__fish_prompt_user)
    echo -n -s (set_color $__fish_prompt_color_normal) '@'
    echo -n (__fish_prompt_host)
    echo -n -s (set_color $__fish_prompt_color_normal) ':'
    echo -n (__fish_prompt_cwd)
    echo -n (__fish_git_prompt "$divider git: %s")
    echo -n (__fish_prompt_venv $divider)
    echo -n (__fish_prompt_goenv $divider)
    # echo -n (__fish_prompt_exec_time $divider)
    echo -s (tput el) (set_color normal)  # fill background color to the end of line

    # prompt second line
    if test (uname) = Darwin
        echo '⌘ '
    else
        echo '➜ '
    end
end
