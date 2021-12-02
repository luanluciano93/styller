if not ZOMBIE then
	ZOMBIE = {
		positionTeleportOpen = Position(970, 956, 7),
		teleportTimeClose = 5,
		positionEnterEvent = Position(808, 926, 9),
		storage = Storage.zombieEvent,
		levelMin = 50,
		reward = {6527, 3}
	}
end

function zombie_teleportCheck()
	local tile = Tile(ZOMBIE.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()
			local totalPlayers = zombie_totalPlayers()
			if totalPlayers > 0 then
				Game.broadcastMessage("The zombie event will begin now!", MESSAGE_STATUS_WARNING)
				Game.createMonster("Zombie Event", ZOMBIE.positionEnterEvent)
				print(">>> Zombie Event will begin now [".. totalPlayers .."].")
			else
				-- print(">>> Zombie Event ended up not having the participation of players.")
			end
		else
			zombie_openMsg(ZOMBIE.teleportTimeClose)

			local teleport = Game.createItem(1387, 1, ZOMBIE.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9613)
				addEvent(zombie_teleportCheck, ZOMBIE.teleportTimeClose * 60000)
			end
		end
	end
end

function zombie_openMsg(minutes)
	local totalPlayers = zombie_totalPlayers()

	if minutes == ZOMBIE.teleportTimeClose then
		Game.broadcastMessage("The zombie event was opened and will close in ".. minutes .." "..(minutes == 1 and "minute" or "minutes") ..".", MESSAGE_STATUS_WARNING)
	else
		Game.broadcastMessage("The zombie event was opened and will close in ".. minutes .." ".. (minutes == 1 and "minute" or "minutes") ..". The event has ".. totalPlayers .." ".. (totalPlayers > 1 and "participants" or "participant") ..".", MESSAGE_STATUS_WARNING)
	end

	local minutesTime = minutes - 1
	if minutesTime > 0 then
		addEvent(zombie_openMsg, 60000, minutesTime)
	end
end

function zombie_totalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(ZOMBIE.storage) > 0 then
			x = x + 1
		end
	end
	return x
end
