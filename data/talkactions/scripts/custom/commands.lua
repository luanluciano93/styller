dofile('data/lib/custom/styllerConfig.lua')

function onSay(player, words, param)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, STYLLER.playerTalkactionsCommands)
	return false
end
