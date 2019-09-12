function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.inquisition) < 2 then -- INQUISITION QUEST PERMISSION
		player:addOutfitAddon(288, 3)
		player:addOutfitAddon(289, 3)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your full addon demon hunter has been added!")
		player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)	
		player:setStorageValue(Storage.inquisition, 2)
	end

	return true
end
