function onSay(player, words, param)

	local exaust = player:getExhaustion(Storage.exhaustion.talkaction)
	if exaust > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You're exhausted for ".. exaust .. " seconds.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(2, Storage.exhaustion.talkaction)

	local tile = Tile(player:getPosition())
	if not tile then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'Invalid tile position.')
		return false
	end

	if not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'To buy bless you need to be in protection zone.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local bless = 5
	local allBless = 0
	for i = 1, bless do
		if player:hasBlessing(i) then
			allBless = allBless + 1
		end
	end

	if allBless == bless then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You already have all blessings.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local allBlessValue = CUSTOM.allBlessValue

	if player:removeTotalMoney(allBlessValue) then
		for i = 1, bless do
			player:addBlessing(i)
		end
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been blessed by the gods!")
		player:getPosition():sendMagicEffect(CONST_ME_FIREWORK_YELLOW)
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have ".. allBlessValue .." gold coints to buy bless.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end
