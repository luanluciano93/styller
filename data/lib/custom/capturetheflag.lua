if not CAPTURETHEFLAG then
	CAPTURETHEFLAG = {
		minutesTotalToFinish = 20,
		flagsTotalToFinish = 10,
		positionTeleportOpen = Position(970, 956, 7),
		teleportTimeClose = 5,
		positionEnterEvent = Position(1237, 952, 8),
		storage = Storage.captureTheFlagEvent,
		lastPlayer = GlobalStorage.captureTheFlagEvent, -- global storage
		levelMin = 50,
		minPlayersToStartEvent = 10,
		reward = {6527, 1},
		redScore = 0,
		greenScore = 0,
		redFlagHolder = nil,
		greenFlagHolder = nil,

		teamsCaptureTheFlag = {
			[1] = {
				color = "Red Assassins", 
				temple = Position(1217, 943, 7), 
				outfitMale = {lookType = 152, lookAddons = 3, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94}, 
				outfitFemale = {lookType = 156, lookAddons = 3, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94},
				flagId = 1435,
				flagPosition = Position(1208, 954, 6)
			},
			[2] = {
				color = "Green Assassins", 
				temple = Position(1278, 970, 7), 
				outfitMale = {lookType = 152, lookAddons = 3, lookHead = 101, lookBody = 101, lookLegs = 101, lookFeet = 101}, 
				outfitFemale = {lookType = 156, lookAddons = 3, lookHead = 101, lookBody = 101, lookLegs = 101, lookFeet = 101},
				flagId = 1437,
				flagPosition = Position(1286, 951, 6)
			},
		}
	}
end

function capturetheflag_teleportCheck()
	local tile = Tile(CAPTURETHEFLAG.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			if (capturetheflag_totalPlayers() % 2) ~= 0 then
				capturetheflag_removePlayer(Game.getStorageValue(CAPTURETHEFLAG.lastPlayer))
				Game.setStorageValue(CAPTURETHEFLAG.lastPlayer, 0)
			end

			local totalPlayers = capturetheflag_totalPlayers()
			if totalPlayers > 0 then
				if totalPlayers < CAPTURETHEFLAG.minPlayersToStartEvent then
					Game.broadcastMessage("Capture the Flag event was canceled due to no minimum of ".. CAPTURETHEFLAG.minPlayersToStartEvent .." participants.", MESSAGE_STATUS_WARNING)
					print(">>> Capture the Flag event was canceled due to no minimum of ".. CAPTURETHEFLAG.minPlayersToStartEvent .." participants.")
					capturetheflag_removeAllPlayers()
				else
					Game.broadcastMessage("Capture the Flag event started with ".. totalPlayers .." participants and will last for ".. CAPTURETHEFLAG.minutesTotalToFinish .." minutes or will end when a team captures ".. CAPTURETHEFLAG.flagsTotalToFinish .."x the enemy flag.", MESSAGE_STATUS_WARNING)
					print(">>> Capture the Flag event will begin now [".. totalPlayers .."].")
					capturetheflag_addFlag(1, CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagPosition)
					capturetheflag_addFlag(2, CAPTURETHEFLAG.teamsCaptureTheFlag[2].flagPosition)
					addEvent(capturetheflag_balanceTeam, 1000)
					addEvent(capturetheflag_checkFinishEvent, CAPTURETHEFLAG.minutesTotalToFinish * 60000)
				end
			else
				-- print(">>> Capture the Flag event ended up not having the participation of players.")
			end
		else			
			capturetheflag_openMsg(CAPTURETHEFLAG.teleportTimeClose)

			local teleport = Game.createItem(1387, 1, CAPTURETHEFLAG.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9619)
				eventsOutfit = {}
				CAPTURETHEFLAG.redScore = 0
				CAPTURETHEFLAG.greenScore = 0
				CAPTURETHEFLAG.redFlagHolder = nil
				CAPTURETHEFLAG.greenFlagHolder = nil
				addEvent(capturetheflag_teleportCheck, CAPTURETHEFLAG.teleportTimeClose * 60000)
			end
		end
	end
end

function capturetheflag_openMsg(minutes)
	local totalPlayers = capturetheflag_totalPlayers()

	if minutes == CAPTURETHEFLAG.teleportTimeClose then
		Game.broadcastMessage("Capture the Flag event was opened and will close in ".. minutes .." "..(minutes == 1 and "minute" or "minutes") ..".", MESSAGE_STATUS_WARNING)
	else
		Game.broadcastMessage("Capture the Flag event was opened and will close in ".. minutes .." ".. (minutes == 1 and "minute" or "minutes") ..". The event has ".. totalPlayers .." ".. (totalPlayers > 1 and "participants" or "participant") ..".", MESSAGE_STATUS_WARNING)
	end

	local minutesTime = minutes - 1
	if minutesTime > 0 then
		addEvent(capturetheflag_openMsg, 60000, minutesTime)
	end
end

function capturetheflag_totalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			x = x + 1
		end
	end
	return x
end

function capturetheflag_removePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:unregisterEvent("CaptureTheFlag")
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(CAPTURETHEFLAG.storage, 0)
		player:setOutfit(eventsOutfit[player:getGuid()])
		if player:getSkull() == SKULL_GREEN then
			player:setSkull(SKULL_NONE)
		end
	end
end

function capturetheflag_removeAllPlayers()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			capturetheflag_removePlayer(player:getGuid())
		end
	end
end

function capturetheflag_addPlayerinTeam(uid, team)
	local player = Player(uid)
	if player then
		if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			player:setStorageValue(CAPTURETHEFLAG.storage, 0)
			if player:getSex() == PLAYERSEX_FEMALE then
				player:setOutfit(CAPTURETHEFLAG.teamsCaptureTheFlag[team].outfitFemale)
			else
				player:setOutfit(CAPTURETHEFLAG.teamsCaptureTheFlag[team].outfitMale)
			end
			player:setStorageValue(CAPTURETHEFLAG.storage, team)
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You will join the " .. CAPTURETHEFLAG.teamsCaptureTheFlag[team].color .. " Team.")
			player:addHealth(player:getMaxHealth())
			player:addMana(player:getMaxMana())
			player:teleportTo(CAPTURETHEFLAG.teamsCaptureTheFlag[team].temple)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		end
	end
end

function capturetheflag_balanceTeam()
	local participants = {}
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			table.insert(participants, player:getGuid())
		end
	end

	table.sort(participants, function(a, b) return Player(a):getLevel() > Player(b):getLevel() end)

	local x = 1
	for i = 1, #participants do
		if x == 1 then
			capturetheflag_addPlayerinTeam(Player(participants[i]):getGuid(), x)
			x = 2
		else
			capturetheflag_addPlayerinTeam(Player(participants[i]):getGuid(), x)
			x = 1
		end
	end

	participants = {}
end

function capturetheflag_addFlag(team, position)
	local tile = Tile(position)
	if tile then
		local item = tile:getItemById(CAPTURETHEFLAG.teamsCaptureTheFlag[team].flagId)
		if not item then
			Game.createItem(CAPTURETHEFLAG.teamsCaptureTheFlag[team].flagId, 1, position)
		end
	end
end

function capturetheflag_removeFlag(team)
	local tile = Tile(CAPTURETHEFLAG.teamsCaptureTheFlag[team].flagPosition)
	if tile then
		local item = tile:getItemById(CAPTURETHEFLAG.teamsCaptureTheFlag[team].flagId)
		if item then
			item:remove()
		end
	end
end

function capturetheflag_addScore(team)
	if team == 1 then
		CAPTURETHEFLAG.redScore = CAPTURETHEFLAG.redScore + 1
	elseif team == 2 then
		CAPTURETHEFLAG.greenScore = CAPTURETHEFLAG.greenScore + 1
	end
end

function capturetheflag_broadcastToPlayers(msg)
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			player:sendTextMessage(MESSAGE_STATUS_WARNING, msg)
		end
	end
end

function capturetheflag_checkFinishEvent()
	if Game.getStorageValue(CAPTURETHEFLAG.lastPlayer) ~= 1 then
		local team = 0
		if CAPTURETHEFLAG.redScore == CAPTURETHEFLAG.greenScore then
			Game.broadcastMessage("Capture the flag event ended in a draw.", MESSAGE_STATUS_WARNING)
			print(">>> Capture the flag event ended in a draw.")
			addEvent(capturetheflag_removeAllPlayers, 500)
		elseif CAPTURETHEFLAG.redScore > CAPTURETHEFLAG.greenScore then
			capturetheflag_finishEvent(1)
		elseif CAPTURETHEFLAG.redScore < CAPTURETHEFLAG.greenScore then
			capturetheflag_finishEvent(2)
		end
	end
end

function capturetheflag_finishEvent(team)
	for _, winner in ipairs(Game.getPlayers()) do
		if winner:getStorageValue(CAPTURETHEFLAG.storage) == team then	
			winner:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations, your team won the capture the flag event.")
			winner:addItem(CAPTURETHEFLAG.reward[1], CAPTURETHEFLAG.reward[2])
		end
	end

	Game.broadcastMessage("Capture the flag event is finish, the ".. CAPTURETHEFLAG.teamsCaptureTheFlag[team].color .." team won.", MESSAGE_STATUS_WARNING)

	print(">>> Capture the flag event was finished. The ".. CAPTURETHEFLAG.teamsCaptureTheFlag[team].color .." team won.")

	Game.setStorageValue(CAPTURETHEFLAG.lastPlayer, 1)
	addEvent(capturetheflag_removeAllPlayers, 500)
end
