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
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'To buy amulet of loss you need to be in protection zone.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local itemType = ItemType(2173)
	local itemWeight = itemType:getWeight()
	local playerCap = player:getFreeCapacity()
	if playerCap < itemWeight then
		itemWeight = itemWeight / 100
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You have found a " .. itemType:getName() .. " weighing " .. itemWeight .. " oz it's too heavy.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)			
	if not backpack or backpack:getEmptySlots(false) < 1 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Your main backpack is full. You need to free up 1 available slots to get " .. itemType:getName() .. ".")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local aolValue = CUSTOM.aolValue

	if player:removeTotalMoney(aolValue) then
		player:addItem(2173, 1)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have ".. aolValue .." gold coins to buy an amulet of loss.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end
