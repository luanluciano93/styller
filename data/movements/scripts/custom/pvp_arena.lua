local pos = {
	Position(941, 945, 9), -- enterArena
	Position(941, 941, 9) -- exitArena
}

function onStepIn(creature, item, position, fromPosition)	
	if not creature:isPlayer() then
		return false
	end

	if creature:getLevel() < 30 then
		creature:sendCancelMessage("You need level 30 to enter in PVP Arena.")
		creature:teleportTo(fromPosition)
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	
	if creature:getStorageValue(Storage.pvpArena) < 1 then
		creature:setStorageValue(Storage.pvpArena, 1)
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "You entered PVP Arena.")
		creature:registerEvent("Arena-Death")
		creature:teleportTo(pos[1])
		creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		creature:setStorageValue(Storage.pvpArena, 0)
		creature:sendTextMessage(MESSAGE_INFO_DESCR, "You left PVP Arena.")
		creature:removeCondition(CONDITION_INFIGHT)
		creature:unregisterEvent("Arena-Death")
		creature:teleportTo(pos[2])
		creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	creature:addHealth(creature:getMaxHealth())
	creature:addMana(creature:getMaxMana())

	return true
end
