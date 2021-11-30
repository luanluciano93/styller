local pos = {
	Position(941, 945, 9), -- enterArena
	Position(941, 941, 9) -- exitArena
}

function onStepIn(creature, item, position, fromPosition)	
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getLevel() < 30 then
		player:sendCancelMessage("You need level 30 to enter in PVP Arena.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		player:teleportTo(fromPosition)
		return false
	end
	
	if player:getStorageValue(Storage.pvpArena) < 1 then
		player:setStorageValue(Storage.pvpArena, 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You entered PVP Arena.")
		player:registerEvent("Arena-Death")
		player:teleportTo(pos[1])
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:setStorageValue(Storage.pvpArena, 0)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You left PVP Arena.")
		player:removeCondition(CONDITION_INFIGHT)
		player:unregisterEvent("Arena-Death")
		player:teleportTo(pos[2])
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	player:addHealth(player:getMaxHealth())
	player:addMana(player:getMaxMana())

	return true
end
