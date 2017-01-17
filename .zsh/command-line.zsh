###############################################################################
# ZSH Command Line plugin
#
# Compilation of few ZSH plugins:
# - https://github.com/zsh-users/zsh-autosuggestions
#
# TODO: add these plugins features:
# - https://github.com/zsh-users/zsh-syntax-highlighting
# - https://github.com/zsh-users/zsh-history-substring-search
# - https://github.com/hchbaw/auto-fu.zsh
###############################################################################

# Settings
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND='fg=0'
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_HISTORY_SEARCH='fg=8'


# Clear the suggestion
ZSH_COMMAND_LINE_CLEAR_WIDGETS=(
    backward-char
    beginning-of-line
    accept-line
    save-previous-command-line
)
function __zsh_command_line_clear {
    echo $@ '(clear)' > /tmp/zsh-command-line.log

    local -i retval

    unset POSTDISPLAY  # remove the suggestion
    __zsh_command_line_highlight_reset

    __zsh_command_line_invoke_original_widget $@
    retval=$?

    __zsh_command_line_highlight_apply
    return $retval
}
zle -N command-line-clear __zsh_command_line_clear


# Accept the entire suggestion
ZSH_COMMAND_LINE_ACCEPT_WIDGETS=(
    forward-char
    end-of-line
)
function __zsh_command_line_accept {
    echo $@ '(accept)' > /tmp/zsh-command-line.log

    local -i retval
    __zsh_command_line_highlight_reset

    # only accept if the cursor is at the end of the buffer
    if [ $CURSOR -eq $#BUFFER ]; then
        BUFFER="$BUFFER$POSTDISPLAY"  # add the suggestion to the buffer
        unset POSTDISPLAY  # remove the suggestion
        CURSOR=${#BUFFER}  # move the cursor to the end of the buffer
    fi

    __zsh_command_line_invoke_original_widget $@
    retval=$?

    __zsh_command_line_highlight_apply
    return $retval
}
zle -N command-line-accept __zsh_command_line_accept


# Partially accept the suggestion
ZSH_COMMAND_LINE_PARTIAL_ACCEPT_WIDGETS=(
    forward-word
)
function __zsh_command_line_partial_accept {
    echo $@ '(partial accept)' > /tmp/zsh-command-line.log

    local -i retval
    __zsh_command_line_highlight_reset

    local original_buffer="$BUFFER"  # save the contents of the buffer so we can restore later if needed

    BUFFER="$BUFFER$POSTDISPLAY"  # temporarily accept the suggestion

    __zsh_command_line_invoke_original_widget $@  # original widget moves the cursor
    retval=$?

    # if we've moved past the end of the original buffer
    if [ $CURSOR -gt $#original_buffer ]; then
        POSTDISPLAY="$RBUFFER"  # ret POSTDISPLAY to text right of the cursor
        BUFFER="$LBUFFER"  # clip the buffer at the cursor
    else
        BUFFER="$original_buffer"  # restore the original buffer
    fi

    __zsh_command_line_highlight_apply
    return $retval
}


# Accept the entire suggestion and execute it
ZSH_COMMAND_LINE_EXECUTE_WIDGETS=()
function __zsh_command_line_execute {
    echo $@ '(execute)' > /tmp/zsh-command-line.log

    local -i retval
    __zsh_command_line_highlight_reset

    BUFFER="$BUFFER$POSTDISPLAY"  # add the suggestion to the buffer
    unset POSTDISPLAY  # remove the suggestion

    __zsh_command_line_invoke_original_widget $@
    retval=$?

    __zsh_command_line_highlight_apply
    return $retval
}
zle -N command-line-execute __zsh_command_line_execute


# Modify the buffer
function __zsh_command_line_modify {
    echo $@ '(modify)' > /tmp/zsh-command-line.log

    local -i retval
    __zsh_command_line_highlight_reset

    local orig_buffer="$BUFFER"  # save the contents of the postdisplay
    local orig_postdisplay="$POSTDISPLAY"  # save the contents of the postdisplay

    unset POSTDISPLAY  # clear suggestion while original widget runs

    __zsh_command_line_invoke_original_widget $@  # original widget may modify the buffer
    retval=$?

    # don't fetch a new suggestion if the buffer hasn't changed
    if [ "$BUFFER" = "$orig_buffer" ]; then
        POSTDISPLAY="$orig_postdisplay"

        __zsh_command_line_highlight_apply
        return $retval
    fi

    # get a new suggestion if the buffer is not empty after modification
    local suggestion
    if [ $#BUFFER -gt 0 ]; then
        suggestion="$(__zsh_command_line_autosuggest "$BUFFER")"
    fi

    # add the suggestion to the POSTDISPLAY
    if [ -n "$suggestion" ]; then
        POSTDISPLAY="${suggestion#$BUFFER}"
    fi

    __zsh_command_line_highlight_apply
    return $retval
}


function __zsh_command_line_autosuggest {
    setopt localoptions EXTENDED_GLOB
    fc -lnrm "${1//(#m)[\\()\[\]|*?~]/\\$MATCH}*" 1 2>/dev/null | head -n 1
}


function __zsh_command_line_history_search_backward {
    echo '__ZSH_COMMAND_LINE_HISTORY_SEARCH_BACKWARD' > /tmp/zsh-command-line.log

    local -i retval
    __zsh_command_line_highlight_reset

    RBUFFER=$POSTDISPLAY
    unset POSTDISPLAY

    zle history-beginning-search-backward
    retval=$?

    POSTDISPLAY=$RBUFFER
    unset RBUFFER

    __zsh_command_line_highlight_apply
    return $retval
}
zle -N command-line-history-search-backward __zsh_command_line_history_search_backward


function __zsh_command_line_history_search_forward {
    echo '__ZSH_COMMAND_LINE_HISTORY_SEARCH_FORWARD' > /tmp/zsh-command-line.log

    local -i retval
    __zsh_command_line_highlight_reset

    RBUFFER=$POSTDISPLAY
    unset POSTDISPLAY

    zle history-beginning-search-forward
    retval=$?

    POSTDISPLAY=$RBUFFER
    unset RBUFFER

    __zsh_command_line_highlight_apply
    return $retval
}
zle -N command-line-history-search-forward __zsh_command_line_history_search_forward


# If there was a highlight, remove it
function __zsh_command_line_highlight_reset {
    region_highlight=("0 $#BUFFER $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND")

    # echo '__zsh_command_line_highlight_reset' $region_highlight > /tmp/zsh-command-line.log
}


# If there's a suggestion, highlight it
function __zsh_command_line_highlight_apply {
    region_highlight=("0 $#BUFFER $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND")
    if [ $#POSTDISPLAY -gt 0 ]; then
        region_highlight+=("$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_HISTORY_SEARCH")
    fi

    # echo '__zsh_command_line_highlight_apply' $region_highlight > /tmp/zsh-command-line.log
}


# Given the name of an original widget and args, invoke it, if it exists
function __zsh_command_line_invoke_original_widget {
    [ $# -gt 0 ] || return  # do nothing unless called with at least one arg

    local original_widget_name="$1"
    shift

    [ $widgets[$original_widget_name] ] && zle $original_widget_name -- $@
}


# Map all configured widgets to the right autosuggest widgets
function __zsh_command_line_bind_widgets {
    local widget

    # widgets that should be ignored
    local ignore_widgets=(
        .\*
        _\*
        zle-line-\*
        command-line-\*
        command-line-orig-\*
        history-beginning-search-\*
        orig-\*
        beep
        run-help
        set-local-history
        which-command
        yank
    )

    # Find every widget we might want to bind and bind it appropriately
    for widget in ${${(f)"$(builtin zle -la)"}:#${(j:|:)~ignore_widgets}}; do
        if   [ ${ZSH_COMMAND_LINE_CLEAR_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget clear
        elif [ ${ZSH_COMMAND_LINE_ACCEPT_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget accept
        elif [ ${ZSH_COMMAND_LINE_EXECUTE_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget execute
        elif [ ${ZSH_COMMAND_LINE_PARTIAL_ACCEPT_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget partial_accept
        else
            # assume any unspecified widget might modify the buffer
            __zsh_command_line_bind_widget $widget modify
        fi
    done
}

# Bind a single widget to an Command Line widget, saving a reference to the original widget
function __zsh_command_line_bind_widget {
    local widget=$1
    local action=$2

    # save a reference to the original widget
    case $widgets[$widget] in
        user:__zsh_command_line_(bound|orig)_*)  # already bound
            ;;

        user:*)  # user-defined widget
            zle -N command-line-orig-$widget ${widgets[$widget]#*:}
            ;;

        builtin)  # built-in widget
            eval "function __zsh_command_line_orig_${(q)widget} { zle .${(q)widget} }"
            zle -N command-line-orig-$widget __zsh_command_line_orig_$widget
            ;;

        completion:*)  # completion widget
            eval "zle -C command-line-orig-${(q)widget} ${${(s.:.)widgets[$widget]}[2,3]}"
            ;;
    esac

    # Pass the original widget's name explicitly into the autosuggest
    # function. Use this passed in widget name to call the original
    # widget instead of relying on the $WIDGET variable being set
    # correctly. $WIDGET cannot be trusted because other plugins call
    # zle without the `-w` flag (e.g. `zle self-insert` instead of
    # `zle self-insert -w`).
    eval "function __zsh_command_line_bound_${(q)widget} {
        __zsh_command_line_$action command-line-orig-${(q)widget} \$@
    }"

    # create the bound widget
    zle -N $widget __zsh_command_line_bound_$widget
}


# Start the autosuggestion widgets
function __zsh_command_line_start {
    __zsh_command_line_bind_widgets
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __zsh_command_line_start
