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

    # username
    switch $USER
        case root toor
            # root user will be displayed with red color
            set_color red -b white
        case '*'
            # regular user will be green
            set_color green -b white
    end
    echo -n $USER

    # divider
    echo -n -s (set_color 9c9c9c -b white) '@'

    # hostname
    set_color yellow -b white
    echo -n $__fish_prompt_hostname

    # divider
    echo -n -s (set_color 9c9c9c -b white) ':'

    # current working directory
    set_color normal -b white
    echo -n (echo -n $PWD | sed -e "s|^$realhome|~|")

    # arrow divider (you need to install one of these fonts to make this works: https://github.com/powerline/fonts)
    set_color white -b normal
    printf '\uE0B0'
    set_color normal
end
