function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if not player:isPremium() then
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage(Game.getReturnMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT))
	else
		player:teleportTo(Position(841, 1022, 7))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end