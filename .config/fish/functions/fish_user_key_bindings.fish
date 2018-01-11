function fish_user_key_bindings
	# 'Meta-.' hotkey to autocomplete last command arguments
	bind \e. 'history-token-search-backward'

	# Accept suggestion and execute on Ctrl+Enter
	# needs Key Mapping in iTerm: "Cmd+Enter" -> "Send Hex Codes: 0xa"
	bind \cJ 'commandline -f accept-autosuggestion execute'
end
