local inquisitionReward = {8930, 8918, 8888, 8890, 8881, 8928, 8851, 8854, 8924}
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid <= 1250 or item.uid >= 30000 then
		return false
	end

	local itemType = ItemType(item.uid)
	if itemType:getId() == 0 then
		return false
	end

	if table.contains(inquisitionReward, item.uid) then
		local itemWeight = itemType:getWeight()
		local playerCap = player:getFreeCapacity()
		if player:getStorageValue(Storage.inquisition) < 3 then
				if playerCap >= itemWeight then
					if not player:addItem(item.uid, 1) then
						print("[ERROR] ACTION: inquisition, FUNCTION: addItem, PLAYER: "..player:getName())
					else
						player:sendTextMessage(MESSAGE_INFO_DESCR, 'You have found a ' .. itemType:getName() .. '.')
						player:setStorageValue(item.uid, 3)
					end
				else
					player:sendTextMessage(MESSAGE_INFO_DESCR, 'You have found a ' .. itemType:getName() .. ' weighing ' .. itemWeight .. ' oz it\'s too heavy.')
				end
		else
			player:sendCancelMessage("It is empty.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		print("[ERROR] ACTION: inquisition_reward, FUNCTION: table.contains, PLAYER: "..player:getName())
	end
	return true
end