if not BATTLEFIELD then
	BATTLEFIELD = {
		positionTeleportOpen = Position(970, 956, 7),
		teleportTimeClose = 5,
		minutesOpenGate = 3,
		storage = Storage.battlefieldEvent,
		lastPlayer = GlobalStorage.battlefieldEvent, -- global storage
		levelMin = 80,
		reward = {6527, 1},
		itemWall = 3517,
		walls = {
			Position(1106, 984, 6),
			Position(1106, 985, 6),
			Position(1106, 986, 6),
			Position(1106, 987, 6)
		},

		teamsBattlefield = {
			[1] = {
				color = "Black Warriors", 
				temple = Position(1094, 986, 6), 
				outfitMale = {lookType = 134, lookHead = 114, lookBody = 114, lookLegs = 114, lookFeet = 114}, 
				outfitFemale = {lookType = 142, lookHead = 114, lookBody = 114, lookLegs = 114, lookFeet = 114}
			},
			[2] = {
				color = "Red Barbarians", 
				temple = Position(1118, 986, 6), 
				outfitMale = {lookType = 143, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94}, 
				outfitFemale = {lookType = 147, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94}
			},
		}
	}
end

function battlefield_teleportCheck()
	local tile = Tile(BATTLEFIELD.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			if (battlefield_totalPlayers() % 2) ~= 0 then
				battlefield_removePlayer(Game.getStorageValue(BATTLEFIELD.lastPlayer))
			end

			local totalPlayers = battlefield_totalPlayers()
			if totalPlayers > 0 then
				Game.broadcastMessage("Battlefield will start in ".. BATTLEFIELD.minutesOpenGate .." minutes, please create your strategy!", MESSAGE_STATUS_WARNING)

				print(">>> BattleField Event will begin now [".. totalPlayers .."].")

				addEvent(battlefield_checkGate, BATTLEFIELD.minutesOpenGate * 60000)
			else
				-- print(">>> BattleField Event ended up not having the participation of players.")
			end
		else			
			battlefield_openMsg(BATTLEFIELD.teleportTimeClose)

			local teleport = Game.createItem(1387, 1, BATTLEFIELD.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9612)
				eventsOutfit = {}
				addEvent(battlefield_teleportCheck, BATTLEFIELD.teleportTimeClose * 60000)
			end
		end
	end
end

function battlefield_openMsg(minutes)
	local totalPlayers = battlefield_totalPlayers()

	if minutes == BATTLEFIELD.teleportTimeClose then
		Game.broadcastMessage("The battlefield event was opened and will close in ".. minutes .." "..(minutes == 1 and "minute" or "minutes") ..".", MESSAGE_STATUS_WARNING)
	else
		Game.broadcastMessage("The battlefield event was opened and will close in ".. minutes .." ".. (minutes == 1 and "minute" or "minutes") ..". The event has ".. totalPlayers .." ".. (totalPlayers > 1 and "participants" or "participant") ..".", MESSAGE_STATUS_WARNING)
	end

	local minutesTime = minutes - 1
	if minutesTime > 0 then
		addEvent(battlefield_openMsg, 60000, minutesTime)
	end
end

function battlefield_removePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:unregisterEvent("Battlefield")
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(BATTLEFIELD.storage, 0)
		player:setOutfit(eventsOutfit[player:getGuid()])
	end
end

function battlefield_checkGate()
	local wall = BATTLEFIELD.walls
	for i = 1, #wall do
		local tile = Tile(wall[i])
		if tile then
			local item = tile:getItemById(BATTLEFIELD.itemWall)
			if item then
				item:remove()
				if i == 1 then
					Game.broadcastMessage("The BattleEvent Event will begin now!", MESSAGE_STATUS_WARNING)
					battlefield_msg()
				end
			else
				Game.createItem(BATTLEFIELD.itemWall, 1, wall[i])
			end
		end
	end
end

function battlefield_totalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(BATTLEFIELD.storage) > 0 then
			x = x + 1
		end
	end
	return x
end

function battlefield_totalPlayersTeam(team)
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(BATTLEFIELD.storage) == team then
			x = x + 1
		end
	end
	return x
end

function battlefield_msg()
	for _, participant in ipairs(Game.getPlayers()) do
		if participant:getStorageValue(BATTLEFIELD.storage) > 0 then
			participant:sendTextMessage(MESSAGE_INFO_DESCR, "[BattleField] ".. BATTLEFIELD.teamsBattlefield[1].color .." ".. battlefield_totalPlayersTeam(1) .." x ".. battlefield_totalPlayersTeam(2) .." " .. BATTLEFIELD.teamsBattlefield[2].color)
		end
	end
end
