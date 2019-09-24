ZOMBIE = {
	positionTeleportOpen = Position(972, 964, 7),
	teleportTimeClose = 5,
	positionEnterEvent = Position(808, 926, 9),
	levelMin = 50,
	reward = {12411, 3}
}

function zombieTeleportCheck()
	local tile = Tile(ZOMBIE.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()
			if zombieTotalPlayers() > 0 then
				Game.broadcastMessage("The zombie event will begin now!", MESSAGE_STATUS_WARNING)
				Game.createMonster("Zombie Event", ZOMBIE.positionEnterEvent)
				print("> Zombie Event will begin now [".. zombieTotalPlayers() .."].")
			else
				print("> Zombie Event ended up not having the participation of players.")
			end
		else
			Game.broadcastMessage("The zombie event was opened and will close in ".. ZOMBIE.teleportTimeClose .." minutes.", MESSAGE_STATUS_WARNING)

			local teleport = Game.createItem(1387, 1, ZOMBIE.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9613)
			end

			addEvent(zombieTeleportCheck, ZOMBIE.teleportTimeClose * 60000)
		end
	end
end

function zombieTotalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == 7 then
			x = x + 1
		end
	end
	return x
end
