dofile('data/lib/custom/styllerConfig.lua')

local days = STYLLER.dailyReward

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	
	local timeQuest = player:getStorageValue(Storage.dailyQuestTime) > 0 and player:getStorageValue(Storage.dailyQuestTime) or 0
	if (timeQuest + 86400) >= os.time() then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You still can't get the next reward.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	elseif (timeQuest + 172800) <= os.time() then
		player:setStorageValue(Storage.dailyQuest, 1)
	end

	local day = player:getStorageValue(Storage.dailyQuest) > 0 and player:getStorageValue(Storage.dailyQuest) or 1
	local dayReward = days[day]
	if dayReward then
		local reward = ItemType(dayReward[1])
		if reward:getId() ~= 0 then
			if player:getFreeCapacity() < reward:getWeight() then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, "You don't have capacity.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return true
			end

			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You received ".. dayReward[2] .." ".. reward:getName() .. " as a reward for the ".. dayReward[3] .." day of daily quest.")
			player:addItem(reward:getId(), dayReward[2])
			player:setStorageValue(Storage.dailyQuestTime, os.time())

			if day == 7 then
				player:setStorageValue(Storage.dailyQuest, 1)
			else
				player:setStorageValue(Storage.dailyQuest, day + 1)
			end
		end
	end

	return true
end
