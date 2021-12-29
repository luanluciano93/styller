function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	creature:teleportTo(Position(662, 1152, 8))
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end
