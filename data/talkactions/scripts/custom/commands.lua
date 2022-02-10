function onSay(player, words, param)
	local commands = CUSTOM.playerTalkactionsCommands
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, commands)
	return false
end
