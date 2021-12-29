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
		creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	return true
end