BATTLEFIELD = {
	OPEN_GATE_MINUTES = 1,
	TELEPORT = {POSITION = Position(972, 964, 7), CLOSE_MINUTES = 1},
	LAST_PLAYER = 27001, -- global storage
	TOTAL_PLAYERS = 27002, -- global storage
	LEVEL_MIN = 10,
	REWARD = {12411, 1},

	TEAMS = {
		[1] = {color = "Black Assassins", temple = Position(1094, 986, 6), outfit = {lookType = 134, lookAddons = 114, lookHead = 114, lookLegs = 114, lookBody = 114, lookFeet = 114}},
		[2] = {color = "Red Barbarians", temple = Position(1118, 986, 6), outfit = {lookType = 143, lookAddons = 94, lookHead = 94, lookLegs = 94, lookBody = 94, lookFeet = 94}},
	},

	ITEM_WALL = 3517,
	WALLS = {
		Position(1106, 984, 6),
		Position(1106, 985, 6),
		Position(1106, 986, 6),
		Position(1106, 987, 6)
	}
}

function battlefieldTeleportCheck()
	local tile = Tile(BATTLEFIELD.TELEPORT.POSITION)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			if (Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) % 2) ~= 0 then
				battlefieldRemovePlayer(Game.getStorageValue(BATTLEFIELD.LAST_PLAYER))
			end

			if Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) > 0 then
				Game.broadcastMessage("Battlefield will start in ".. BATTLEFIELD.OPEN_GATE_MINUTES .." minutes, please create your strategy!", MESSAGE_STATUS_WARNING)

				print("> BattleField Event will begin now [".. Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) .."].")

				addEvent(battlefieldCheckGate, BATTLEFIELD.OPEN_GATE_MINUTES * 60000)
			else
				print("> BattleField Event ended up not having the participation of players.")
			end
		else
			Game.broadcastMessage("The BattleField Event was opened and will close in ".. BATTLEFIELD.TELEPORT.CLOSE_MINUTES .." minutes.", MESSAGE_STATUS_WARNING)
			Game.setStorageValue(BATTLEFIELD.TOTAL_PLAYERS, 0)

			print("> BattleField Event was opened teleport.")

			local teleport = Game.createItem(1387, 1, BATTLEFIELD.TELEPORT.POSITION)
			if teleport then
				teleport:setActionId(9612)
			end

			addEvent(battlefieldTeleportCheck, BATTLEFIELD.TELEPORT.CLOSE_MINUTES * 60000)
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

	Game.setStorageValue(BATTLEFIELD.TOTAL_PLAYERS, Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) - 1)
end

function battlefieldCheckGate()
	local wall = BATTLEFIELD.WALLS
	for i = 1, #wall do
		local tile = Tile(wall[i])
		if tile then
			local item = tile:getItemById(BATTLEFIELD.ITEM_WALL)
			if item then
				item:remove()
				if i == 1 then
					Game.broadcastMessage("The BattleEvent Event will begin now!", MESSAGE_STATUS_WARNING)
					battlefieldMsg()
				end
			else
				Game.createItem(BATTLEFIELD.ITEM_WALL, 1, wall[i])
			end
		end
	end
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
		if player:getStorageValue(Storage.events) > 0 then
			player:sendTextMessage(MESSAGE_INFO_DESCR, "[BattleField] ".. BATTLEFIELD.TEAMS[1].color .." ".. battlefieldCountPlayers(1) .." x ".. battlefieldCountPlayers(2) .." " .. BATTLEFIELD.TEAMS[2].color)
		end
	end
end
