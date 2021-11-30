function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if not player:isPremium() then
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:sendCancelMessage(Game.getReturnMessage(RETURNVALUE_YOUNEEDPREMIUMACCOUNT))
		return false
	else
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	return true
end