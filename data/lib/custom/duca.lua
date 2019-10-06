DUCA = {
	minutesTotalEvent = 3,
	positionTeleportOpen = Position(972, 964, 7),
	levelMin = 10,
	rewardFirst = {12411, 10},
	rewardSecond = {12411, 3},
	teamsDuca = {
		[1] = {color = "Black", temple = Position(1099, 855, 7), outfit = {lookType = 128, lookAddons = 114, lookHead = 114, lookLegs = 114, lookBody = 114, lookFeet = 114}},
		[2] = {color = "White", temple = Position(1141, 915, 7), outfit = {lookType = 128, lookAddons = 19, lookHead = 19, lookLegs = 19, lookBody = 19, lookFeet = 19}},
		[3] = {color = "Red", outfit = {lookType = 134, lookAddons = 94, lookHead = 94, lookLegs = 94, lookBody = 94, lookFeet = 94}},
		[4] = {color = "Green", outfit = {lookType = 134, lookAddons = 101, lookHead = 101, lookLegs = 101, lookBody = 101, lookFeet = 101}},
	}
}

function ducaTeleportCheck()
	local tile = Tile(DUCA.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()
			ducaFinishEvent()
			print(">>> Duca Event was finished. <<<")
		else
			Game.broadcastMessage("Duca event was started and will close in ".. DUCA.minutesTotalEvent .." minutes.", MESSAGE_STATUS_WARNING)
			print(">>> Duca Event was started. <<<")

			local teleport = Game.createItem(1387, 1, DUCA.positionTeleportOpen)
			if teleport then
				teleport:setActionId(9614)
			end

			addEvent(ducaTeleportCheck, DUCA.minutesTotalEvent * 60000)
		end
	end
end

function ducaBalanceTeam()
	local time1, time2 = 0, 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == 1 then
			time1 = time1 + 1
		elseif player:getStorageValue(Storage.events) == 2 then
			time2 = time2 + 1
		end
	end
	return (time1 <= time2) and 1 or 2
end

function ducaAddPlayerinTeam(uid, team)
	local player = Player(uid)
	if player then
		player:setOutfit(DUCA.teamsDuca[team].outfit)
		player:setStorageValue(Storage.events, team)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You will join the " .. DUCA.teamsDuca[team].color .. " Team.")
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
	end
end

function ducaRemovePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:unregisterEvent("Duca")
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(Storage.events, 0)
		player:setStorageValue(Storage.ducaPoints, 0)
	end
end

function ducaUpdateRank()
	local participants = {}
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) > 0 and player:getStorageValue(Storage.events) < 5 then
			table.insert(participants, player:getGuid())
		end
	end

	table.sort(participants, function(a, b) return Player(a):getStorageValue(Storage.ducaPoints) > Player(b):getStorageValue(Storage.ducaPoints) end)

	if (#participants >= 1) then
		ducaAddPlayerinTeam(participants[1], 4)
		Player(participants[1]):getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	if (#participants >= 11) then
		for i = 2, 11 do
			ducaAddPlayerinTeam(participants[i], 3)
			Player(participants[i]):getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		end
	end

	if (#participants > 12) then
		for x = 12, #participants do
			if Player(participants[x]):getStorageValue(Storage.events) >= 3 then
				ducaAddPlayerinTeam(participants[x], ducaBalanceTeam())
				Player(participants[x]):getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
		end
	end
end

function ducaFinishEvent()
	ducaUpdateRank()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == 4 then
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

		elseif player:getStorageValue(Storage.events) == 3 then
			local itemType = ItemType(DUCA.rewardSecond[1])
			if itemType:getId() ~= 0 then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received ".. DUCA.rewardSecond[2] .." ".. itemType:getName() .. " as a reward from the duca event.")
				player:addItem(itemType:getId(), DUCA.rewardSecond[2])
			end
		end

		if player:getStorageValue(Storage.events) > 0 and player:getStorageValue(Storage.events) < 5 then
			ducaRemovePlayer(player:getGuid())
		end
	end
end

function ducaTotalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) > 0 and player:getStorageValue(Storage.events) <= 4 then
			x = x + 1
		end
	end
	return x
end
