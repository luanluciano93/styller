local bigQuestReward = {8883, 8869, 8867, 8853}
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	local itemWeight = itemType:getWeight()
	local playerCap = player:getFreeCapacity()
	if table.contains(bigQuestReward, item.uid) then
		if player:getStorageValue(Storage.bigQuest) == -1 then
			if playerCap >= itemWeight then
				player:addItem(item.uid, 1)
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. '.')
				player:setStorageValue(Storage.bigQuest, 1)
			else
				player:sendCancelMessage("You don't have capacity.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		else
			player:sendCancelMessage("It is empty.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		print("[ERROR] ACTION: bigquest, FUNCTION: table.contains, PLAYER: "..player:getName())
	end
	return true
end
