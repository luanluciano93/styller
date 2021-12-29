function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	local x = item.actionid - actionIds.levelDoor
	if creature:getLevel() < x and not creature:getGroup():getAccess() then
		creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Required level "..x.." to pass this door.")
		creature:teleportTo(fromPosition, true)
		return false
	end
	return true
end
