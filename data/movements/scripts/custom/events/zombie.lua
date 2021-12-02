dofile('data/lib/custom/zombie.lua')

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getGroup():getAccess() then
		player:teleportTo(ZOMBIE.positionEnterEvent)
		return true
	end

	if player:getLevel() < ZOMBIE.levelMin then
		player:sendCancelMessage("You need level " .. ZOMBIE.levelMin .. " to enter in zombie event.")
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	for _, check in ipairs(Game.getPlayers()) do
		if player:getIp() == check:getIp() and check:getStorageValue(ZOMBIE.storage) > 0 then
			player:sendCancelMessage("You already have another player inside the event.")
			player:teleportTo(fromPosition)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	player:sendTextMessage(MESSAGE_INFO_DESCR, "Get ready for the zombie event!")
	player:addHealth(player:getMaxHealth())
	player:addMana(player:getMaxMana())
	player:registerEvent("Zombie")
	player:teleportTo(ZOMBIE.positionEnterEvent)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:setStorageValue(ZOMBIE.storage, 1)

	return true
end
