function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	local x = item.actionid - 1000
	if creature:getLevel() < x then
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "Required level "..x.." to pass this door.")
		creature:teleportTo(fromPosition, true)
		return false
	end
	return true
end
