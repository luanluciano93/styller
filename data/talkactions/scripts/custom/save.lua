function onSay(player, words, param)
	if player:getExhaustion() > 0 then
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(10)
	player:save()
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your player is saved ...")

	return false
end
