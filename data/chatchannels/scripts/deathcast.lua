function onSpeak(player, type, message)
	local playerAccountType = player:getAccountType()
	if playerAccountType < ACCOUNT_TYPE_GAMEMASTER then
		player:sendCancelMessage("You can't talk on this channel.")
		return false
	end
	return type
end
