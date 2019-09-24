BATTLEFIELD = {
	positionTeleportOpen = Position(972, 964, 7),
	teleportTimeClose = 5,
	minutesOpenGate = 3,
	lastPlayer = 27001, -- global storage
	levelMin = 80,
	reward = {12411, 1},
	itemWall = 3517,
	walls = {
		Position(1106, 984, 6),
		Position(1106, 985, 6),
		Position(1106, 986, 6),
		Position(1106, 987, 6)
	},

	teamsBattlefield = {
		[5] = {color = "Black Assassins", temple = Position(1094, 986, 6), outfit = {lookType = 134, lookAddons = 114, lookHead = 114, lookLegs = 114, lookBody = 114, lookFeet = 114}},
		[6] = {color = "Red Barbarians", temple = Position(1118, 986, 6), outfit = {lookType = 143, lookAddons = 94, lookHead = 94, lookLegs = 94, lookBody = 94, lookFeet = 94}},
	}
}

function battlefieldTeleportCheck()
	local tile = Tile(BATTLEFIELD.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			if (battlefieldTotalPlayers() % 2) ~= 0 then
				battlefieldRemovePlayer(Game.getStorageValue(BATTLEFIELD.lastPlayer))
			end

			local totalPlayers = battlefieldTotalPlayers()
			if totalPlayers > 0 then
				Game.broadcastMessage("Battlefield will start in ".. BATTLEFIELD.minutesOpenGate .." minutes, please create your strategy!", MESSAGE_STATUS_WARNING)

				print("> BattleField Event will begin now [".. totalPlayers .."].")

				addEvent(battlefieldCheckGate, BATTLEFIELD.minutesOpenGate * 60000)
			else
				print("> BattleField Event ended up not having the participation of players.")
			end
		else
			Game.broadcastMessage("The BattleField Event was opened and will close in ".. BATTLEFIELD.teleportTimeClose .." minutes.", MESSAGE_STATUS_WARNING)

			print("> BattleField Event was opened teleport.")

			local teleport = Game.createItem(1387, 1, BATTLEFIELD.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9612)
			end

			addEvent(battlefieldTeleportCheck, BATTLEFIELD.teleportTimeClose * 60000)
		end
	end
end

function battlefieldRemovePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:unregisterEvent("Battlefield")
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(Storage.events, 0)
	end
end

function battlefieldCheckGate()
	local wall = BATTLEFIELD.walls
	for i = 1, #wall do
		local tile = Tile(wall[i])
		if tile then
			local item = tile:getItemById(BATTLEFIELD.itemWall)
			if item then
				item:remove()
				if i == 1 then
					Game.broadcastMessage("The BattleEvent Event will begin now!", MESSAGE_STATUS_WARNING)
					battlefieldMsg()
				end
			else
				Game.createItem(BATTLEFIELD.itemWall, 1, wall[i])
			end
		end
	end
end

function battlefieldTotalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == 5 or player:getStorageValue(Storage.events) == 6 then
			x = x + 1
		end
	end
	return x
end

function battlefieldCountPlayers(team)
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == team then
			x = x + 1
		end
	end
	return x
end

function battlefieldMsg()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == 5 or player:getStorageValue(Storage.events) == 6 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "[BattleField] ".. BATTLEFIELD.teamsBattlefield[5].color .." ".. battlefieldCountPlayers(5) .." x ".. battlefieldCountPlayers(6) .." " .. BATTLEFIELD.teamsBattlefield[6].color)
		end
	end
end
