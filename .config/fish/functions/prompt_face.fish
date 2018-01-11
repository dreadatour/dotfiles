function prompt_face --description 'Choose new random face'
    if test -n "$argv"
        set -g __fish_prompt_emoji $argv
    else
        set -l faces 😄 😎 🤠 👀 👽 😺 🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯 🦁 🐵 🙈 🙉 🙊 🐌 🐞 🐙 🚀
        set -g __fish_prompt_emoji $faces[(math (math (random)%(count $faces)) + 1)]
    end
end
