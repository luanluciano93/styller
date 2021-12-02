if not DUCA then
	DUCA = {
		minutesTotalEvent = 30,
		positionTeleportOpen = Position(970, 956, 7),
		storage = Storage.ducaEvent,
		ducaPoints = Storage.ducaPoints,
		totalDeaths = GlobalStorage.ducaEvent, -- global storage
		levelMin = 80,
		rewardFirst = {6527, 10},
		rewardSecond = {6527, 3},
		teamsDuca = {
			[1] = {
				color = "Black",
				temple = Position(1100, 855, 7),
				outfitMale = {lookType = 128, lookHead = 114, lookBody = 114, lookLegs = 114, lookFeet = 114},
				outfitFemale = {lookType = 136, lookHead = 114, lookBody = 114, lookLegs = 114, lookFeet = 114}
			},
			[2] = {
				color = "White",
				temple = Position(1141, 916, 7),
				outfitMale = {lookType = 128, lookHead = 19, lookBody = 19, lookLegs = 19, lookFeet = 19},
				outfitFemale = {lookType = 136, lookHead = 19, lookBody = 19, lookLegs = 19, lookFeet = 19}
			},
			[3] = {
				color = "Red",
				outfitMale = {lookType = 134, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94},
				outfitFemale = {lookType = 142, lookHead = 94, lookBody = 94, lookLegs = 94, lookFeet = 94}
			},
			[4] = {
				color = "Green",
				outfitMale = {lookType = 134, lookHead = 101, lookBody = 101, lookLegs = 101, lookFeet = 101},
				outfitFemale = {lookType = 142, lookHead = 101, lookBody = 101, lookLegs = 101, lookFeet = 101}
			},
		}
	}
end

function duca_teleportCheck()
	local tile = Tile(DUCA.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()
			duca_finishEvent()
			-- print(">>> Duca Event was finished. <<<")
		else
			duca_openMsg(DUCA.minutesTotalEvent)
			-- print(">>> Duca Event was started. <<<")

			Game.setStorageValue(DUCA.totalDeaths, 0)
			
			local teleport = Game.createItem(1387, 1, DUCA.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9614)
				eventsOutfit = {}
				addEvent(duca_teleportCheck, DUCA.minutesTotalEvent * 60000)
			end
		end
	end
end

function duca_openMsg(minutes)
	local totalPlayers = duca_totalPlayers()
	local totalDeaths = Game.getStorageValue(DUCA.totalDeaths)

	if minutes == DUCA.minutesTotalEvent then
		Game.broadcastMessage("Duca event was started and will close in ".. minutes .." "..(minutes == 1 and "minute" or "minutes") ..".", MESSAGE_STATUS_WARNING)
	else
		Game.broadcastMessage("Duca event was opened and will close in ".. minutes .." ".. (minutes == 1 and "minute" or "minutes") ..". The event has ".. totalPlayers .." ".. (totalPlayers > 1 and "participants" or "participant") .." and already has ".. totalDeaths .." ".. (totalDeaths > 1 and "deaths" or "death")..".", MESSAGE_STATUS_WARNING)
	end

	local minutesTime = minutes - 1
	if minutesTime > 0 then
		addEvent(duca_openMsg, 60000, minutesTime)
	end
end

function duca_balanceTeam()
	local time1, time2 = 0, 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(DUCA.storage) == 1 then
			time1 = time1 + 1
		elseif player:getStorageValue(DUCA.storage) == 2 then
			time2 = time2 + 1
		end
	end
	return (time1 <= time2) and 1 or 2
end

function duca_addPlayerinTeam(uid, team)
	local player = Player(uid)
	if player then
		if player:getStorageValue(DUCA.storage) ~= team then
			player:setStorageValue(DUCA.storage, 0)
			if player:getSex() == PLAYERSEX_FEMALE then
				player:setOutfit(DUCA.teamsDuca[team].outfitFemale)
			else
				player:setOutfit(DUCA.teamsDuca[team].outfitMale)
			end
			player:setStorageValue(DUCA.storage, team)
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You will join the " .. DUCA.teamsDuca[team].color .. " Team.")
			player:addHealth(player:getMaxHealth())
			player:addMana(player:getMaxMana())
		end
	end
end

function duca_removePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:unregisterEvent("Duca")
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(DUCA.storage, 0)
		player:setStorageValue(DUCA.ducaPoints, 0)
		player:setOutfit(eventsOutfit[player:getGuid()])
	end
end

function duca_updateRank()
	local participants = {}
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(DUCA.storage) > 0 then
			table.insert(participants, player:getGuid())
		end
	end

	table.sort(participants, function(a, b) return Player(a):getStorageValue(DUCA.ducaPoints) > Player(b):getStorageValue(DUCA.ducaPoints) end)

	if (#participants >= 1) then
		duca_addPlayerinTeam(participants[1], 4)
		Player(participants[1]):getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	if (#participants >= 11) then
		for i = 2, 11 do
			duca_addPlayerinTeam(participants[i], 3)
			Player(participants[i]):getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		end
	end

	if (#participants > 12) then
		for x = 12, #participants do
			if Player(participants[x]):getStorageValue(DUCA.storage) >= 3 then
				duca_addPlayerinTeam(participants[x], duca_balanceTeam())
				Player(participants[x]):getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
		end
	end
end

function duca_finishEvent()
	duca_updateRank()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(DUCA.storage) > 0 then
			if player:getStorageValue(DUCA.storage) == 4 then
				Game.broadcastMessage("Duca Event is finish. Congratulation to the player ".. player:getName() .." for being the event champion!", MESSAGE_STATUS_WARNING)

				local itemType = ItemType(DUCA.rewardFirst[1])
				if itemType:getId() ~= 0 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received ".. DUCA.rewardFirst[2] .." ".. itemType:getName() .. " as a reward for first place in the duca event.")
					player:addItem(itemType:getId(), DUCA.rewardFirst[2])
				end

				local trophy = player:addItem(10127, 1)
				if trophy then
					trophy:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 'Awarded to '.. player:getName() ..'.')
				end

			elseif player:getStorageValue(DUCA.storage) == 3 then
				local itemType = ItemType(DUCA.rewardSecond[1])
				if itemType:getId() ~= 0 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received ".. DUCA.rewardSecond[2] .." ".. itemType:getName() .. " as a reward from the duca event.")
					player:addItem(itemType:getId(), DUCA.rewardSecond[2])
				end
			end

			duca_removePlayer(player:getGuid())
		end
	end
end

function duca_totalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(DUCA.storage) > 0 then
			x = x + 1
		end
	end
	return x
end
