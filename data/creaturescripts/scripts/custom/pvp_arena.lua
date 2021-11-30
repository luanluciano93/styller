local exit = Position(941, 941, 9)

function onLogin(player)
	if player:getStorageValue(Storage.pvpArena) > 0 then
		player:setStorageValue(Storage.pvpArena, 0)
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(Storage.pvpArena) > 0 then
		player:sendCancelMessage("You can not logout now!")
		return false
	end
	return true
end

function onPrepareDeath(player, killer)
	if player:getStorageValue(Storage.pvpArena) > 0 then
		player:getPosition():sendMagicEffect(CONST_ME_YALAHARIGHOST)
		player:removeCondition(CONDITION_INFIGHT)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are dead in PVP Arena!")
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:setStorageValue(Storage.pvpArena, 0)
		player:unregisterEvent("Arena-Death")
		player:teleportTo(exit)
		if killer:isPlayer() then
			killer:getPosition():sendMagicEffect(CONST_ME_GROUNDSHAKER)
		end
		return false
	end
	return true
end
