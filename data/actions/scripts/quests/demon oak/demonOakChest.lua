local demonOakReward = {
	[7007] = 2495, 
	[7008] = 8905, 
	[7009] = 8918, 
	[7010] = 8851
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	local itemUid = demonOakReward[item.uid]
	if not itemUid then
		return true
	end

	if player:getStorageValue(Storage.demonOak.progress) == 2 then
		local itemWeight = itemType:getWeight()
		local playerCap = player:getFreeCapacity()
		if playerCap >= itemWeight then
			if not player:addItem(itemUid, 1) then
				print("[ERROR] ACTION: demonoak_reward, FUNCTION: addItem, PLAYER: "..player:getName())
			else
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. '.')
				player:setStorageValue(Storage.demonOak.progress, 3)
			end
		else
			player:sendCancelMessage("You don't have capacity.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		player:sendCancelMessage("It is empty.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return true
end