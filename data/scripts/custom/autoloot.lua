-- !autoloot clear
-- !autoloot list
-- !autoloot add, itemName		  / ex: !autoloot add, fire sword
-- !autoloot remove, itemName	   / ex: !autoloot remove, fire sword

local autoloot = {
	freeAccountLimit = 10,
	premiumAccountLimit = 20,
}

local autolootCache = {}

local function getPlayerLimit(player)
	if player then
		return player:isPremium() and autoloot.premiumAccountLimit or autoloot.freeAccountLimit
	end
	return false
end

local function getPlayerAutolootItems(player)
	local limits = getPlayerLimit(player)
	if limits then
		local guid = player:getGuid()
		if guid then
			local itemsCache = autolootCache[guid]
			if itemsCache then
				if #itemsCache > limits then
					local newChache = {unpack(itemsCache, 1, limits)}
					autolootCache[guid] = newChache
					return newChache
				end
				return itemsCache
			end

			local items = {}
			for i = 1, limits do
				local itemType = ItemType(math.max(player:getStorageValue(Storage.autolootBase + i)), 0)
				if itemType then
					if itemType:getId() ~= 0 then
						items[#items +1] = itemType:getId()
					end
				end
			end

			autolootCache[guid] = items
			return items
		end
	end
	return false
end

local function setPlayerAutolootItems(player, items)
	if items then
		local limit = getPlayerLimit(player)
		if limit then
			for i = limit, 1, -1 do
				player:setStorageValue(Storage.autolootBase + i, (items[i] and items[i] or -1))
			end
		end
		return true
	end
	return false
end

local function addPlayerAutolootItem(player, itemId)
	local items = getPlayerAutolootItems(player)
	if items then
		for _, id in pairs(items) do
			if itemId == id then
				return false
			end
		end
		items[#items +1] = itemId
		return setPlayerAutolootItems(player, items)
	end
	return false
end

local function removePlayerAutoAlllootItem(player)
	local items = getPlayerAutolootItems(player)
	if items then
		for i, id in pairs(items) do
			table.remove(items, i)
		end
		return setPlayerAutolootItems(player, items)
	end
	return false
end

local function removePlayerAutolootItem(player, itemId)
	local items = getPlayerAutolootItems(player)
	if items then
		for i, id in pairs(items) do
			if itemId == id then
				table.remove(items, i)
				return setPlayerAutolootItems(player, items)
			end
		end
	end
	return false
end

local function hasPlayerAutolootItem(player, itemId)
	local items = getPlayerAutolootItems(player)
	if items then
		for _, id in pairs(items) do
			if itemId then
				if itemId == id then
					return true
				end
			end
		end
	end
	return false
end

local ec = EventCallback

function ec.onDropLoot(monster, corpse)
	if not corpse:getType():isContainer() then
		return
	end

	local corpseOwner = Player(corpse:getCorpseOwner())
	if not corpseOwner then
		return
	end
	local items = corpse:getItems()
	local mType = monster:getType()
	local text = "Autoloot de ".. mType:getNameDescription() ..":"
	if items then
		for _, item in pairs(items) do
			local itemId = item:getId()
			local amount = item:getCount()
			if table.contains({ITEM_GOLD_COIN, ITEM_PLATINUM_COIN, ITEM_CRYSTAL_COIN, 10559}, itemId) and corpseOwner:getStorageValue(Storage.autolootGoldAtive) == 1 then
				if amount then
					item:remove(amount)
					if itemId == ITEM_PLATINUM_COIN then
						amount = amount * 100
					elseif itemId == ITEM_CRYSTAL_COIN then
						amount = amount * 10000
					elseif itemId == 10559 then
						amount = amount * 1000000
					end
					corpseOwner:setBankBalance(corpseOwner:getBankBalance() + amount)
					corpseOwner:sendTextMessage(MESSAGE_INFO_DESCR, text .." ".. amount .. " gold ".. (amount > 1 and "coins were transferred" or "coin has been transferred") .." to your bank account.")
				end
			else
				if hasPlayerAutolootItem(corpseOwner, itemId) then
					local itemName = amount > 1 and item:getPluralName() or item:getName()
					local itemArticle = item:getArticle() ~= "" and item:getArticle() or "a"
					if not item:moveTo(corpseOwner) then
						corpseOwner:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[AUTO LOOT] You don't have capacity.")
						break
					else
						corpseOwner:sendTextMessage(MESSAGE_INFO_DESCR, text .." ".. (amount > 1 and amount or itemArticle) .. " ".. itemName ..".")
					end
				end
			end
		end
	end
end

ec:register(3)

local talkAction = TalkAction("!autoloot")

function talkAction.onSay(player, words, param, type)
	local split = param:splitTrimmed(",")
	local action = split[1]
	if not action then
		player:showTextDialog(8977, "[AUTO LOOT] Commands:" .. "\n\n"
			.. "!autoloot clear" .. "\n"
			.. "!autoloot list" .. "\n"
			.. "!autoloot add, itemName" .. "\n"
			.. "!autoloot remove, itemName".. "\n"
			.. "!autoloot gold".. "\n\n"
			.. "Number of slots: ".. "\n"
			.. autoloot.freeAccountLimit .." free account".. "\n"
			.. autoloot.premiumAccountLimit .." premium account")
		return false
	end

	if not table.contains({"clear", "list", "add", "remove", "gold"}, action) then
		player:showTextDialog(8977, "[AUTO LOOT] Commands:" .. "\n\n"
			.. "!autoloot clear" .. "\n"
			.. "!autoloot list" .. "\n"
			.. "!autoloot add, itemName" .. "\n"
			.. "!autoloot remove, itemName".. "\n"
			.. "!autoloot gold".. "\n\n"
			.. "Quantidade de slots: ".. "\n"
			.. autoloot.freeAccountLimit .." free account".. "\n"
			.. autoloot.premiumAccountLimit .." premium account")
		return false
	end

	-- !autoloot clear
	if action == "clear" then
		removePlayerAutoAlllootItem(player)
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[AUTO LOOT] Clean autoloot list.") 
		return false

	-- !autoloot list
	elseif action == "list" then
		local items = getPlayerAutolootItems(player)
		if items then
			local limit = getPlayerLimit(player)
			if limit then
				local description = {string.format('[AUTO LOOT] Capacity: %d/%d ~\n\nList of items:\n-----------------------------', #items, limit)}
				for i, itemId in pairs(items) do
					description[#description +1] = string.format("%d) %s", i, ItemType(itemId):getName())
				end
				player:showTextDialog(8977, table.concat(description, '\n'), false)
			end
		end
		return false
	end

	local function getItemType()
		local itemType = ItemType(split[2])
		if not itemType or itemType:getId() == 0 then
			itemType = ItemType(tonumber(split[2]) or 0)
			if not itemType or itemType:getId() == 0 then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] The item %s does not exist!", split[2]))
				return false
			end
		end
		return itemType
	end

	-- !autoloot add, itemName
	if action == "add" then
		local itemType = getItemType()
		if itemType then
			local limits = getPlayerLimit(player)
			if limits then
				local items = getPlayerAutolootItems(player)
				if items then
					if #items >= limits then
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Your autoloot only allows you to add %d items.", limits))
						return false
					end

					if addPlayerAutolootItem(player, itemType:getId()) then
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Perfect, you added the autoloot list: %s", itemType:getName()))
					else
						player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Item %s is already on the list!", itemType:getName()))
					end
				end
			end
		end
		return false

	-- !autoloot remove, itemName
	elseif action == "remove" then
		local itemType = getItemType()
		if itemType then
			if removePlayerAutolootItem(player, itemType:getId()) then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Perfect, you removed it from the autoloot list: %s", itemType:getName()))
			else
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format("[AUTO LOOT] Item %s is not in your list.", itemType:getName()))
			end
		end
		return false

	-- !autoloot gold
	elseif action == "gold" then
		player:setStorageValue(Storage.autolootGoldAtive, player:getStorageValue(Storage.autolootGoldAtive) == 1 and 0 or 1)
		local check = player:getStorageValue(Storage.autolootGoldAtive) == 1 and "activated" or "disabled"
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "[AUTO LOOT] You ".. check .." collecting money by autoloot.")
		return false
	end

	return false
end

talkAction:separator(" ")
talkAction:register()

local creatureEvent = CreatureEvent("autolootCleanCache")

function creatureEvent.onLogout(player)
	local items = getPlayerAutolootItems(player)
	if items then
		setPlayerAutolootItems(player, items)
		autolootCache[player:getGuid()] = nil
	end
	return true
end
