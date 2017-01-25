###############################################################################
# ZSH Command Line plugin
#
# Compilation of few ZSH plugins:
# - https://github.com/johan/zsh/blob/master/Functions/Zle/history-search-end
# - https://github.com/zsh-users/zsh-autosuggestions
#
# TODO: check and add these plugins features:
# - https://github.com/johan/zsh/blob/master/Functions/Zle/history-beginning-search-menu
# - https://github.com/johan/zsh/blob/master/Functions/Zle/predict-on
# - https://github.com/zsh-users/zsh-syntax-highlighting
# - https://github.com/zsh-users/zsh-history-substring-search
# - https://github.com/hchbaw/auto-fu.zsh
###############################################################################

# Settings
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND='fg=0'
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND_OK='fg=2'
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND_BAD='fg=1'
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND_TAIL='fg=245'
ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_HISTORY_SEARCH='fg=253'


# Clear the suggestion
ZSH_COMMAND_LINE_CLEAR_WIDGETS=(
    backward-char
    beginning-of-line
    accept-line
    save-previous-command-line
)
function __zsh_command_line_clear {
    local -i retval

    unset POSTDISPLAY  # remove the suggestion

    __zsh_command_line_invoke_original_widget $@
    retval=$?

    zle .set-mark-command  # set mark at the cursor position
    __zsh_command_line_highlight
    return $retval
}
zle -N command-line-clear-autosuggest __zsh_command_line_clear


# Accept suggestion's one char
ZSH_COMMAND_LINE_ACCEPT_CHAR_WIDGETS=(
    forward-char
)
function __zsh_command_line_accept_char {
    local -i retval

    # only accept if the cursor is at the end of the buffer
    if [ $CURSOR -eq $#BUFFER ]; then
        BUFFER="$BUFFER${POSTDISPLAY[1]}"  # add the suggestion's first char to the buffer
        POSTDISPLAY=${POSTDISPLAY:1}  # slice suggestion
    fi

    __zsh_command_line_invoke_original_widget $@
    retval=$?

    zle .set-mark-command  # set mark at the cursor position
    __zsh_command_line_autosuggest  # get a new suggestion
    __zsh_command_line_highlight
    return $retval
}


# Partially accept the suggestion
ZSH_COMMAND_LINE_ACCEPT_WORD_WIDGETS=(
    forward-word
)
function __zsh_command_line_accept_word {
    local -i retval
    local buffer_orig="$BUFFER"  # save the contents of the buffer so we can restore later if needed

    BUFFER="$BUFFER$POSTDISPLAY"  # temporarily accept the suggestion

    __zsh_command_line_invoke_original_widget $@  # original widget moves the cursor
    retval=$?

    # if we've moved past the end of the original buffer
    if [ $CURSOR -gt $#buffer_orig ]; then
        POSTDISPLAY="$RBUFFER"  # ret POSTDISPLAY to text right of the cursor
        BUFFER="$LBUFFER"  # clip the buffer at the cursor
    else
        BUFFER="$buffer_orig"  # restore the original buffer
    fi

    zle .set-mark-command  # set mark at the cursor position
    __zsh_command_line_autosuggest  # get a new suggestion
    __zsh_command_line_highlight
    return $retval
}


# Accept the entire suggestion
ZSH_COMMAND_LINE_ACCEPT_ALL_WIDGETS=(
    end-of-line
)
function __zsh_command_line_accept_all {
    local -i retval

    # only accept if the cursor is at the end of the buffer
    if [ $CURSOR -eq $#BUFFER ]; then
        BUFFER="$BUFFER$POSTDISPLAY"  # add the suggestion to the buffer
        unset POSTDISPLAY  # remove the suggestion
    fi

    __zsh_command_line_invoke_original_widget $@
    retval=$?

    zle .set-mark-command  # set mark at the cursor position
    __zsh_command_line_autosuggest  # get a new suggestion
    __zsh_command_line_highlight
    return $retval
}


# Modify the buffer
function __zsh_command_line_modify {
    local -i retval

    local buffer_orig="$BUFFER"  # save the contents of the postdisplay
    local postdisplay_orig="$POSTDISPLAY"  # save the contents of the postdisplay

    unset POSTDISPLAY  # clear suggestion while original widget runs

    __zsh_command_line_invoke_original_widget $@  # original widget may modify the buffer
    retval=$?

    zle .set-mark-command  # set mark at the cursor position

    # don't fetch a new suggestion if the buffer hasn't changed
    if [ "$BUFFER" = "$buffer_orig" ]; then
        POSTDISPLAY="$postdisplay_orig"
    else
        __zsh_command_line_autosuggest  # get a new suggestion
    fi

    __zsh_command_line_highlight
    return $retval
}


# Accept the entire suggestion and execute it
function __zsh_command_line_execute {
    local -i retval

    BUFFER="$BUFFER$POSTDISPLAY"  # add the suggestion to the buffer
    unset POSTDISPLAY  # remove the suggestion

    zle .end-of-line  # move cursor to the end of line
    zle .set-mark-command  # set mark at the cursor position

    __zsh_command_line_highlight

    zle .accept-line
}
zle -N command-line-execute __zsh_command_line_execute


function __zsh_command_line_autosuggest_path {
    setopt localoptions NULL_GLOB
    /bin/ls -dap $1* 2>/dev/null | /usr/bin/grep '/$' | /usr/bin/head -n 1 | /usr/bin/cut -c $((${#1} + 1))-
}

function __zsh_command_line_autosuggest_history {
    setopt localoptions EXTENDED_GLOB
    fc -lnrm "${1//(#m)[\\()\[\]|*?~]/\\$MATCH}*" 1 2>/dev/null | /usr/bin/head -n 1
}

function __zsh_command_line_autosuggest {
    local suggestion

    if [ $#BUFFER -gt 0 ]; then
        if [ $CURSOR -eq $#BUFFER ]; then
            if [ "${BUFFER[1,3]}" = "cd " ]; then  # dirty hack to autosuggest directories for 'cd' command
                local -a words=(${=BUFFER})
                local path

                if [ ${#words} -gt 1 ]; then
                    path=${words[-1]}
                fi

                suggestion="$(__zsh_command_line_autosuggest_path "${path}")"
            else
                suggestion="$(__zsh_command_line_autosuggest_history "$BUFFER")"
            fi
        fi
    fi

    if [ -n "$suggestion" ]; then
        POSTDISPLAY="${suggestion#$BUFFER}"
    else
        unset POSTDISPLAY
    fi
}


function __zsh_command_line_history_search_backward {
    local -i cursor_prev=$CURSOR
    local -i mark_prev=$MARK
    local -i retval

    if [[ $LASTWIDGET = command-line-history-search-* ]]; then
        CURSOR=$MARK  # last widget called set $MARK
    else
        MARK=$CURSOR
    fi

    unset POSTDISPLAY

    zle .history-beginning-search-backward
    retval=$?

    if [ $retval -gt 0 ]; then
        CURSOR=$cursor_prev
        MARK=$mark_prev
    else
        zle .end-of-line
    fi

    __zsh_command_line_highlight
    return $retval
}
zle -N command-line-history-search-backward __zsh_command_line_history_search_backward


function __zsh_command_line_history_search_forward {
    local -i cursor_prev=$CURSOR
    local -i mark_prev=$MARK
    local -i retval

    if [[ $LASTWIDGET = command-line-history-search-* ]]; then
        CURSOR=$MARK  # last widget called set $MARK
    else
        MARK=$CURSOR
    fi

    unset POSTDISPLAY

    zle .history-beginning-search-forward
    retval=$?

    if [ $retval -gt 0 ]; then
        CURSOR=$cursor_prev
        MARK=$mark_prev
    else
        zle .end-of-line
    fi

    __zsh_command_line_highlight
    return $retval
}
zle -N command-line-history-search-forward __zsh_command_line_history_search_forward


# Highlight command line
function __zsh_command_line_highlight {
    if [ ${#BUFFER} -eq 0 ]; then
        region_highlight=()
        return
    fi


    local -a words=(${=BUFFER})
    local command=${words[1]}

    # TODO: correct highlight (for example, set ENV variables before command does not highlight)
    which-command $command >/dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
        region_highlight=("0 $#command $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND_OK")
    else
        region_highlight=("0 $#command $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND_BAD")
    fi

    region_highlight+=("$#command $#MARK $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND")
    region_highlight+=("$MARK $#BUFFER $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_COMMAND_TAIL")

    [ $#POSTDISPLAY -gt 0 ] && region_highlight+=("$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ZSH_COMMAND_LINE_HIGHLIGHT_COLOR_HISTORY_SEARCH")
}


# Given the name of an original widget and args, invoke it, if it exists
function __zsh_command_line_invoke_original_widget {
    [ $# -gt 0 ] || return  # do nothing unless called with at least one arg

    local widget_orig="$1"
    shift

    [ $widgets[$widget_orig] ] && zle $widget_orig -- $@
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
        elif [ ${ZSH_COMMAND_LINE_ACCEPT_CHAR_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget accept_char
        elif [ ${ZSH_COMMAND_LINE_ACCEPT_WORD_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget accept_word
        elif [ ${ZSH_COMMAND_LINE_ACCEPT_ALL_WIDGETS[(r)$widget]} ]; then
            __zsh_command_line_bind_widget $widget accept_all
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
