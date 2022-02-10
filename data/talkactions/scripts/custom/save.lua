function onSay(player, words, param)

	local exaust = player:getExhaustion(Storage.exhaustion.savePlayer)
	if exaust > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You're exhausted for ".. exaust .. " seconds.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(60, Storage.exhaustion.savePlayer)

	player:save()
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your player is saved ...")

	return false
end
