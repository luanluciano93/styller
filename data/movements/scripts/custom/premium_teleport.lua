function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	if not creature:isPremium() then
		creature:sendCancelMessage(Game.getReturnMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT))
		creature:teleportTo(fromPosition, true)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	else
		creature:teleportTo(Position(841, 1022, 7))
		creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end