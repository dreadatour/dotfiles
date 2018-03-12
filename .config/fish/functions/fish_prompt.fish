# expand home directory to variable
set __fish_prompt_realhome ~
# expand user ID to variable
set __fish_prompt_user_id (id -u "$USER")
# variable for store prompt emoji
set __fish_prompt_emoji

function fish_prompt --description 'Write out the prompt'
    set_color normal -b e4e4e4

# iTerm is broken so comment this out until fix
#    if test 0 -eq $__fish_prompt_user_id
#        # warn for root user
#        echo -sn ⚠️
#    else
#        # choose random emoji face for highlight prompt
#        if test -z "$__fish_prompt_emoji"
#            prompt_face
#        end
#        echo -sn $__fish_prompt_emoji
#    end
#
#    echo -sn ' '

    # print current working directory
    # echo -sn (echo -sn $PWD | sed -e "s|^$__fish_prompt_realhome|~|")
    prompt_pwd normal black normal e4e4e4

    # normal color to user prompt
    set_color e4e4e4 -b normal
    printf '\uE0B0'
    set_color normal
    echo -sn ' '
end
