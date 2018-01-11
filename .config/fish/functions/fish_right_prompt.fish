function fish_right_prompt --description 'Write out the right prompt'
    test $status -gt 0; and echo -sn '🔴  '
    fish_prompt_git
end
