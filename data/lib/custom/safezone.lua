if not SAFEZONE then
	SAFEZONE = {
		positionTeleportOpen = Position(970, 956, 7),
		teleportTimeClose = 5,
		positionEnterEvent = Position(1105, 969, 4), 
		storage = Storage.safezoneEvent,
		actionId = 9618,
		protectionTileId = {9562, 9563, 9564, 9565},
		levelMin = 50,
		maxPlayers = 30,
		reward = {6527, 1},
		lifeColor = {
			[1] = 94, -- red
			[2] = 77, -- orange
			[3] = 79 -- yellow
		},
		positionEvent = {firstTile = {x = 1097, y = 963, z = 4}, tilesX = 16, tilesY = 12}
	}
end 

function safezone_teleportCheck()
	local tile = Tile(SAFEZONE.positionTeleportOpen)
	if tile then
		local item = tile:getItemById(1387)
		if item then
			item:remove()

			local totalPlayers = safezone_totalPlayers()
			if totalPlayers > 0 then
				Game.broadcastMessage("The safezone event will begin now with ".. totalPlayers .." participants!", MESSAGE_STATUS_WARNING)
				print(">>> Safezone Event will begin now [".. totalPlayers .."].")
				
				safezone_createProtectionTiles()
			else
				-- print(">>> Safezone Event ended up not having the participation of players.")
			end
		else
			safezone_openMsg(SAFEZONE.teleportTimeClose)

			local teleport = Game.createItem(1387, 1, SAFEZONE.positionTeleportOpen)
			if teleport then
				teleport:setActionId(SAFEZONE.actionId)
				eventsOutfit = {}
				addEvent(safezone_teleportCheck, SAFEZONE.teleportTimeClose * 60000)
			end
		end
	end
end

function safezone_openMsg(minutes)
	local totalPlayers = safezone_totalPlayers()

	if minutes == SAFEZONE.teleportTimeClose then
		Game.broadcastMessage("The safezone event was opened and will close in ".. minutes .." "..(minutes == 1 and "minute" or "minutes") ..".", MESSAGE_STATUS_WARNING)
	else
		Game.broadcastMessage("The safezone event was opened and will close in ".. minutes .." ".. (minutes == 1 and "minute" or "minutes") ..". The event has ".. totalPlayers .." ".. (totalPlayers > 1 and "participants" or "participant") ..".", MESSAGE_STATUS_WARNING)
	end

	local minutesTime = minutes - 1
	if minutesTime > 0 then
		addEvent(safezone_openMsg, 60000, minutesTime)
	end
end

function safezone_removePlayer(uid)
	local player = Player(uid)
	if player then
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(SAFEZONE.storage, 0)
		player:setOutfit(eventsOutfit[player:getGuid()])
	end	
end

function safezone_totalPlayers()
	local x = 0
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			x = x + 1
		end
	end
	return x
end

local function safezone_totalProtectionTile()
	local totalPlayers = safezone_totalPlayers()
	if totalPlayers >= 5 then
		return totalPlayers - 3
	else
		return totalPlayers - 1
	end
end

function safezone_createProtectionTiles()
	local totalPlayers = safezone_totalPlayers()
	if totalPlayers == 1 then
		for _, player in ipairs(Game.getPlayers()) do
			if player:getStorageValue(SAFEZONE.storage) > 0 then
				local itemType = ItemType(SAFEZONE.reward[1])
				if itemType:getId() ~= 0 then
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received ".. SAFEZONE.reward[2] .." ".. itemType:getName() .. " as a reward for first place in the safezone event.")
					player:addItem(itemType:getId(), SAFEZONE.reward[2])
				end

				safezone_removePlayer(player:getGuid())

				Game.broadcastMessage("Safezone Event is finish. Congratulation to the player ".. player:getName() .." for being the event champion!", MESSAGE_STATUS_WARNING)
				print(">>> Safezone Event is finish. Congratulation to the player ".. player:getName() .." for being the event champion!")
			end
		end

	elseif totalPlayers > 1 then
		local createTiles, totalTiles = 0, safezone_totalProtectionTile()
		local tileX = SAFEZONE.positionEvent.firstTile.x
		local tileY = SAFEZONE.positionEvent.firstTile.y
		local tileZ = SAFEZONE.positionEvent.firstTile.z
		local tilesX = SAFEZONE.positionEvent.tilesX
		local tilesY = SAFEZONE.positionEvent.tilesY
		local protectionTileId = SAFEZONE.protectionTileId
		while createTiles < totalTiles do
			local randomX = math.random(tileX, tileX + tilesX)
			local randomY = math.random(tileY, tileY + tilesY)
			local newPosition = Position({x = randomX, y = randomY, z = tileZ})
			local tile = Tile(newPosition)
			if tile then
				local item1 = tile:getItemById(protectionTileId[1])
				local item2 = tile:getItemById(protectionTileId[2])
				local item3 = tile:getItemById(protectionTileId[3])
				local item4 = tile:getItemById(protectionTileId[4])
				if not item1 and not item2 and not item3 and not item4 then
					local randomTile = math.random(protectionTileId[1], protectionTileId[4])
					local tileProtection = Game.createItem(randomTile, 1, newPosition)
					if tileProtection then
						tileProtection:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
						addEvent(safezone_deleteProtectionTiles, 5500, newPosition, randomTile)
						createTiles = createTiles + 1
					end
				end
			end
		end
		addEvent(safezone_effectArea, 5000, SAFEZONE.positionEvent.firstTile, SAFEZONE.positionEvent.tilesX, SAFEZONE.positionEvent.tilesY)
		addEvent(safezone_checkPlayersinProtectionTiles, 5000)
		addEvent(safezone_createProtectionTiles, 6000)
	end
end

function safezone_deleteProtectionTiles(position, tileId)
	local tile = Tile(position)
	if tile then
		local item = tile:getItemById(tileId)
		if item then
			item:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			item:remove()
		end
	end
end

function safezone_checkPlayersinProtectionTiles()
	local protectionTileId = SAFEZONE.protectionTileId
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(SAFEZONE.storage) > 0 then
			local tile = Tile(player:getPosition())
			if tile then
				local item1 = tile:getItemById(protectionTileId[1])
				local item2 = tile:getItemById(protectionTileId[2])
				local item3 = tile:getItemById(protectionTileId[3])
				local item4 = tile:getItemById(protectionTileId[4])
				if not item1 and not item2 and not item3 and not item4 then
					if player:getStorageValue(SAFEZONE.storage) > 1 then

						player:setStorageValue(SAFEZONE.storage, player:getStorageValue(SAFEZONE.storage) - 1)
						local lifes = player:getStorageValue(SAFEZONE.storage)
						player:setStorageValue(SAFEZONE.storage, 0)
						player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)

						local outfit = player:getSex() == 0 and 136 or 128
						if lifes == 1 then
							local lifeColor = SAFEZONE.lifeColor[1]
							player:setOutfit({lookType = outfit, lookHead = lifeColor, lookBody = lifeColor, lookLegs = lifeColor, lookFeet = lifeColor})
						elseif lifes == 2 then
							local lifeColor = SAFEZONE.lifeColor[2]
							player:setOutfit({lookType = outfit, lookHead = lifeColor, lookBody = lifeColor, lookLegs = lifeColor, lookFeet = lifeColor})
						end
						
						player:setStorageValue(SAFEZONE.storage, lifes)
					else
						player:getPosition():sendMagicEffect(CONST_ME_SMALLPLANTS)
						safezone_removePlayer(player:getGuid())
					end
				end
			end
		end
	end
end

function safezone_effectArea(firstTile, tilesX, tilesY)
	local fromPosition = firstTile
	local toPositionX = fromPosition.x + tilesX
	local toPositionY = fromPosition.y + tilesY
	for x = fromPosition.x, toPositionX do
		for y = fromPosition.y, toPositionY do
			local position = Position({x = x, y = y, z = fromPosition.z})
			if position then
				position:sendMagicEffect(CONST_ME_SMALLPLANTS)
			end
		end
	end
end
