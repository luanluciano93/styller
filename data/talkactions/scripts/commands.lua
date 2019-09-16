function onSay(player, words, param)
	if player:getExhaustion() <= 0 then
		player:setExhaustion(2)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Player commands:" .. "\n"
			.. "!buyhouse" .. "\n"
			.. "!leavehouse" .. "\n"
			.. "!serverinfo" .. "\n"
			.. "!online" .. "\n"
			.. "!save" .. "\n"
			.. "!kills" .. "\n"
			.. "!uptime")
		return false
	else
		player:sendCancelMessage("You're exhausted.")
	end
end
