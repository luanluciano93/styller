function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if player == nil then
		return false
	end

	player:teleportTo(Position(662, 1152, 8))
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end
