function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local itemId = item:getId()
	if table.contains(questDoors, itemId) then
		if item.actionid == 9000 and player:getStorageValue(Storage.inquisition) ~= -1 then -- INQUISITION QUEST PERMISSION
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
			return true
		elseif item.actionid == 9001 and player:getStorageValue(Storage.blueLegsQuest) ~= -1 then -- BLUE LEGS QUEST PERMISSION
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
			return true
		elseif item.actionid == 9002 and player:getStorageValue(Storage.pitsOfInferno.permission) ~= -1 then -- POI QUEST PERMISSION
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
			return true
		elseif item.actionid == 9003 and player:getStorageValue(Storage.pitsOfInferno.completed) ~= -1 then -- POI QUEST COMPLETED
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
			return true
		elseif item.actionid == 9004 and player:getStorageValue(Storage.annihilator) ~= -1 then -- ANIHI QUEST COMPLETED
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
			return true
		elseif player:getStorageValue(item.actionid) ~= -1 then
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)	
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "The door seems to be sealed against unwanted intruders.")
		end
		return true
	elseif table.contains(levelDoors, itemId) then
		if item.actionid > 0 then
			local level = item.actionid - 1000
			if player:getLevel() >= level then
				item:transform(itemId + 1)
				player:teleportTo(toPosition, true)
			else
				player:sendTextMessage(MESSAGE_INFO_DESCR, "You need level ".. level .." to pass this door.")
			end
		else
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
		end
		return true
	elseif table.contains(keys, itemId) then
		if target.actionid > 0 then
			if item.actionid == target.actionid and doors[target.itemid] then
				target:transform(doors[target.itemid])
				return true
			end
			player:sendTextMessage(MESSAGE_STATUS_SMALL, "The key does not match.")
			return true
		end
		return false
	end

	if table.contains(horizontalOpenDoors, itemId) or table.contains(verticalOpenDoors, itemId) then
		local doorCreature = Tile(toPosition):getTopCreature()
		if doorCreature then
			toPosition.x = toPosition.x + 1
			local query = Tile(toPosition):queryAdd(doorCreature, bit.bor(FLAG_IGNOREBLOCKCREATURE, FLAG_PATHFINDING))
			if query ~= RETURNVALUE_NOERROR then
				toPosition.x = toPosition.x - 1
				toPosition.y = toPosition.y + 1
				query = Tile(toPosition):queryAdd(doorCreature, bit.bor(FLAG_IGNOREBLOCKCREATURE, FLAG_PATHFINDING))
			end

			if query ~= RETURNVALUE_NOERROR then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, Game.getReturnMessage(query))
				return true
			end

			doorCreature:teleportTo(toPosition, true)
		end

		if not table.contains(openSpecialDoors, itemId) then
			item:transform(itemId - 1)
		end
		return true
	end

	if doors[itemId] then
		if item.actionid == 0 then
			item:transform(doors[itemId])
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "It is locked.")
		end
		return true
	end
	return false
end
