-- !offer add, itemName, itemCount, itemPrice
-- !offer add, plate armor, 1, 500

-- !offer buy, AuctionID
-- !offer buy, 1943

-- !offer remove, AuctionID
-- !offer remove, 1943

-- !offer withdraw
-- Use this command to get money for sold items.

----------------------------------------------------------------------------------- verificar se na tabela é usado o item_name e verificar se é possível enviar o valor arrecadado para a conta (balance account)

local config = {
	levelRequiredToAdd = 20,
	maxOffersPerPlayer = 5,
	blockedItems = {2165, 2152, 2148, 2160, 2166, 2167, 2168, 2169, 2202, 2203, 2204, 2205, 2206, 2207, 2208, 2209, 2210, 2211, 2212, 2213, 2214, 2215, 2343, 2433, 2640, 6132, 6300, 6301, 9932, 9933}
}

function onSay(player, words, param)
	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	elseif not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You must be in the protection zone to use these commands.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local word = param:split(",")
	if word[1] == "add" then
		if not word[2] or not word[3] and or word[4] then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif not tonumber(word[3]) or not tonumber(word[4]) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You don't set valid price or items count.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif tonumber(word[3]) < 1 or tonumber(word[4]) < 1 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have to type a number higher than 0.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif string.len(word[3]) > 3 or string.len(word[4]) > 7 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "This price or item count is too high.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif player:getLevel() < config.levelRequiredToAdd then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You don't have required (" .. config.levelRequiredToAdd .. ") level.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif table.contains(config.blockedItems, itemId) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "This item is blocked.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerGuid, offers = player:getGuid(), 0
		local resultId = db.storeQuery("SELECT `id` FROM `auction_system` WHERE `player` = " .. playerGuid)
		if resultId ~= false then
			repeat
				offers = offers + 1
			until not result.next(resultId)
			result.free(resultId)
		end

		if offers >= config.maxOffersPerPlayer then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Sorry you can't add more offers (max. " .. config.maxOffersPerPlayer .. ")")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemId = ItemType(word[2]):getId()
		if itemId == 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Item wich such name does not exists.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif player:getItemCount(itemId) < word[3]  then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Sorry, you don't have this item(s).")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemCount, itemValue = math.floor(word[3]), math.floor(word[4])
		if not player:removeItem(itemId, itemCount) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You do not have the necessary items!")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		else
			db.query("INSERT INTO `auction_system` (`player`, `item_name`, `item_id`, `count`, `value`, `date`) VALUES (" .. playerGuid .. ", \"" .. db.escapeString(itemName) .. "\", " .. itemId .. ", " .. itemCount .. ", " .. itemValue ..", " .. os.time() .. ")")
		end

		return false

	elseif word[1] == "buy" then

		if not tonumber(word[2]) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Wrong ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local id = word[2]
		local resultId = db.storeQuery("SELECT * FROM `auction_system` WHERE `id` = " .. id)
		if resultId == false then
			return false
		end

		local playerName = result.getString(resultId, "player")
		local itemValue = result.getNumber(resultId, "value")
		local itemId = result.getNumber(resultId, "item_id")
		local itemCount = result.getNumber(resultId, "count")
		result.free(resultId)

		local playerCap, itemWeight = player:getFreeCapacity(), ItemType(itemId):getWeight()
		if playerCap < itemWeight then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You don't have capacity.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif player:getName() == playerName then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Sorry, you can't buy your own items.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif not player:removeMoney(itemValue) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You don't have enoguh gold coins.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		elseif not player:addItem(itemId, itemCount) then
			print("[ERROR] TALKACTION: auction_system, FUNCTION: addItem, PLAYER: "..player:getName())
			return false
		else
			db.query("DELETE FROM `auction_system` WHERE `id` = " .. id)
			db.query("DELETE FROM `auction_system` WHERE `id` = " .. id)
			db.executeQuery("DELETE FROM `auction_system` WHERE `id` = " .. id)
			
			--db.executeQuery("UPDATE `players` SET `auction_balance` = `auction_balance` + " .. buy:getDataInt("cost") .. " WHERE `id` = " .. buy:getDataInt("player") .. ";")
			--player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You bought " .. itemCount .. " ".. playerName .. " for " .. itemValue .. " gold coins in auction system!")
		end

		return false

	elseif word[1] == "remove" then
-----------------------------------------------------------------------------------
						if((not tonumber(word[2]))) then
								doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Wrong ID.")
								return true
						end
		   
						if(not getTilePzInfo(getPlayerPosition(cid))) then
							doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "You must be in PZ area when you remove offerts from database.")
							return true
						end
						local delete = db.getResult("SELECT * FROM `auction_system` WHERE `id` = " .. (tonumber(word[2])) .. ";")        
						if(delete:getID() ~= -1) then
								if(getPlayerGUID(cid) == delete:getDataInt("player")) then
										db.executeQuery("DELETE FROM `auction_system` WHERE `id` = " .. word[2] .. ";")
										if(isItemStackable(delete:getDataString("item_id"))) then
												doPlayerAddItem(cid, delete:getDataString("item_id"), delete:getDataInt("count"))
										else
												for i = 1, delete:getDataInt("count") do
														doPlayerAddItem(cid, delete:getDataString("item_id"), 1)
												end
										end
										doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Your offert has been deleted from offerts database.")
								else
										doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "This is not your offert!")
								end
						delete:free()
						else
								doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Wrong ID.")
						end
				end
				if(t[1] == "withdraw") then
						local balance = db.getResult("SELECT `auction_balance` FROM `players` WHERE `id` = " .. getPlayerGUID(cid) .. ";")
						if(balance:getDataInt("auction_balance") < 1) then
								doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You don't have money on your auction balance.")
								balance:free()
								return true
						end
						doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You got " .. balance:getDataInt("auction_balance") .. " gps from auction system!")
						doPlayerAddMoney(cid, balance:getDataInt("auction_balance"))
						db.executeQuery("UPDATE `players` SET `auction_balance` = '0' WHERE `id` = " .. getPlayerGUID(cid) .. ";")
						balance:free()
				end
	else
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
	
	return false
end