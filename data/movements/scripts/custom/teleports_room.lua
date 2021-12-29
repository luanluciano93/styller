function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	creature:teleportTo(Position(895, 978, 7))
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end
