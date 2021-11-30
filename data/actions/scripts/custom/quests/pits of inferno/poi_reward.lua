local poiReward = {2453, 6528, 5803}
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	if table.contains(poiReward, item.uid) then
		if player:getStorageValue(Storage.pitsOfInferno.reward) == -1 then
			local itemWeight = itemType:getWeight()
			local playerCap = player:getFreeCapacity()
			if playerCap >= itemWeight then
				player:addItem(item.uid, 1)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. '.')
				player:setStorageValue(Storage.pitsOfInferno.reward, 1)
			else
				player:sendCancelMessage("You don't have capacity.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		else
			player:sendCancelMessage("It is empty.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		print("[ERROR] ACTION: poi_reward, FUNCTION: table.contains, PLAYER: "..player:getName())
	end
	return true
end
