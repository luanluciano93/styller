function onSay(player, words, param)
	if player:getExhaustion() <= 0 then
		player:setExhaustion(2)
		player:save()
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "My player is saved ...")
	else
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
end
