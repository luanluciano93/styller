function onSay(player, words, param)

	if not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendCancelMessage("To buy amulet of loss you need to be in protection zone.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local itemType = ItemType(2173)
	local itemWeight = itemType:getWeight()
	local playerCap = player:getFreeCapacity()
	if playerCap < itemWeight then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. ' weighing ' .. itemWeight .. ' oz it\'s too heavy.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:removeTotalMoney(10000) then
		player:addItem(2173, 1)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	else
		player:sendCancelMessage("You don't have 10000 gold coins to buy an amulet of loss.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end
