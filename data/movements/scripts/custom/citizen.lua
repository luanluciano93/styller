function onStepIn(creature, item, position, fromPosition)
	if item.actionid > actionIds.citizenship and item.actionid < actionIds.citizenshipLast then
		if not creature:isPlayer() then
			return false
		end

		local town = Town(item.actionid - actionIds.citizenship)
		if not town then
			return true
		end

		creature:setTown(town)
		creature:teleportTo(town:getTemplePosition())
		creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You are now a citizen of " .. town:getName() .. ".")
	end
	return true
end
