local demonHelmetReward = {2493, 2520, 2645}
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	if table.contains(demonHelmetReward, item.uid) then
		if player:getStorageValue(item.uid) == -1 then
			local itemWeight = itemType:getWeight()
			local playerCap = player:getFreeCapacity()
			if playerCap >= itemWeight then
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. '.')
				player:addItem(item.uid, 1)
				player:setStorageValue(item.uid, 1)
			else
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. ' weighing ' .. itemWeight .. ' oz it\'s too heavy.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		else
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'It is empty.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		print("[ERROR] ACTION: demonhelmet_reward, FUNCTION: table.contains, PLAYER: "..player:getName())
	end
	return true
end
