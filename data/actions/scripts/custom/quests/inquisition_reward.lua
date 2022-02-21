local inquisitionReward = {8930, 8918, 8888, 8890, 8881, 8928, 8851, 8854, 8924}
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	if not table.contains(inquisitionReward, item.uid) then
		print("[ERROR] ACTION: inquisition_reward, FUNCTION: table.contains, PLAYER: "..player:getName())
		return false
	end

	if player:getStorageValue(Storage.inquisition) == 3 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'It is empty.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local itemWeight = itemType:getWeight()
	local playerCap = player:getFreeCapacity()
	if playerCap < itemWeight then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have found a ' .. itemType:getName() .. ' weighing ' .. (itemWeight / 100) .. ' oz it\'s too heavy.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local backpack = player:getSlotItem(CONST_SLOT_BACKPACK)
	if not backpack or backpack:getEmptySlots(false) < 1 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your main backpack is full. You need to free up 1 available slots to get " .. itemType:getName() .. ".")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:addItem(item.uid, 1) then
		player:sendTextMessage(MESSAGE_INFO_DESCR, 'You have found a ' .. itemType:getName() .. '.')
		player:setStorageValue(Storage.inquisition, 3)
	end

	return true
end
