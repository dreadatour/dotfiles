# You need to install one of these fonts to make arrow dividers works:
# https://github.com/powerline/fonts

function fish_prompt --description 'Write out the prompt'
    # expand home directory to variable
    set -l realhome ~

    # save hostname to variable (just calculate this once, to save few CPU cycles when displaying the prompt)
    if not set -q __fish_prompt_hostname
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

    # virtualenv name
    if set -q VIRTUAL_ENV
        set_color $fish_color_prompt_virtualenv_fg -b $fish_color_prompt_virtualenv_bg
        echo -n (basename "$VIRTUAL_ENV")
        # divider
        set_color $fish_color_prompt_virtualenv_bg -b $fish_color_prompt_user_host_bg
        printf '\uE0B0'
    end

    # username
    switch $USER
        case root toor
            # root user will be displayed with red color
            set_color red -b $fish_color_prompt_user_host_bg
        case '*'
            # regular user will be green
            set_color $fish_color_prompt_user_fg -b $fish_color_prompt_user_host_bg
    end
    echo -n $USER
    # divider
    echo -n -s (set_color normal -b $fish_color_prompt_user_host_bg) '@'

    # hostname
    set_color $fish_color_prompt_host_fg -b $fish_color_prompt_user_host_bg
    echo -n $__fish_prompt_hostname
    # divider
    set_color $fish_color_prompt_user_host_bg -b $fish_color_prompt_path_bg
    printf '\uE0B0'

    # current working directory
    set_color $fish_color_prompt_path_fg -b $fish_color_prompt_path_bg
    echo -n (echo -n $PWD | sed -e "s|^$realhome|~|")
    # divider
    set_color $fish_color_prompt_path_bg -b normal
    printf '\uE0B0'

    # normal color to user prompt
    set_color normal
end
