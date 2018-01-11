# Setup locale
set -gx  LC_ALL en_US.UTF-8

# Path settings
set -gx PATH ~/.bin $PATH

# Go settings
set -gx GOPATH ~/work/go
set -gx PATH ~/work/go/bin $PATH

# Setup greeting
set fish_greeting ''  # turn it off

# Setup colors
set fish_color_normal                normal              # the default color
set fish_color_command               000000              # commands
set fish_color_autosuggestion        93a1a1              # commands suggestions
set fish_color_quote                 green               # quoted blocks of text
set fish_color_redirection           blue                # IO redirections
set fish_color_end                   blue                # process separators like ';' and '&'
set fish_color_error                 red                 # used to highlight potential errors
set fish_color_param                 000000              # regular command parameters
set fish_color_comment               93a1a1              # code comments
set fish_color_match                 normal --bold       # highlight matching parenthesis
set fish_color_search_match          cyan --bold         # highlight history search matches
set fish_color_operator              000000 --bold       # parameter expansion operators like '*' and '~'
set fish_color_escape                green --bold        # highlight character escapes like '\n' and '\x70'
set fish_color_cwd                   yellow              # the current working directory in the default prompt
set fish_color_cwd_root              red --bold          # color of the current working directory if user is root
set fish_color_valid_path            000000              # valid path
set fish_color_selection             cyan --bold purple  # selections
set fish_color_history_current       000000              # current history item color for `dirh` command
set fish_pager_color_prefix          000000              # prefix string, i.e. the string that is to be completed
set fish_pager_color_completion      normal              # completion itself
set fish_pager_color_description     93a1a1              # completion description
set fish_pager_color_progress        cyan --bold         # progress bar at the bottom left corner
set fish_pager_color_secondary       cyan                # every second completion

# Run local rc if file is exists
if test -e ~/.fishrc
    source ~/.fishrc
end
