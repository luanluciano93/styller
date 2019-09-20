dofile('data/lib/custom/battlefield.lua')

local function battlefieldBalanceTeam()
	local time1, time2 = 0, 0
	for _, uid in ipairs(Game.getPlayers()) do
		if uid:getStorageValue(Storage.events) == 1 then
			time1 = time1 + 1
		elseif uid:getStorageValue(Storage.events) == 2 then
			time2 = time2 + 1
		end
	end
	return (time1 <= time2) and 1 or 2
end

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getGroup():getAccess() then
		player:teleportTo(BATTLEFIELD.TEAMS[1].temple)
		return true
	end

	if player:getLevel() < BATTLEFIELD.LEVEL_MIN then
		player:sendCancelMessage("You need level " .. BATTLEFIELD.LEVEL_MIN .. " to enter in Battlefield event.")
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:getItemCount(2165) >= 1 then
		player:sendCancelMessage("You can not enter stealth ring in the event.")
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local ring = player:getSlotItem(CONST_SLOT_RING)
	if ring then
		if ring:getId() == 2202 then
			player:sendCancelMessage("You can not enter stealth ring in the event.")
			player:teleportTo(fromPosition)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	for _, check in ipairs(Game.getPlayers()) do
		if player:getIp() == check:getIp() and check:getStorageValue(Storage.events) > 0 then
			player:sendCancelMessage("You already have another player inside the event.")
			player:teleportTo(fromPosition)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	local team = battlefieldBalanceTeam()
	player:setOutfit(BATTLEFIELD.TEAMS[team].outfit)
	player:setStorageValue(Storage.events, team)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You will join the " .. BATTLEFIELD.TEAMS[team].color .. ".")
	player:addHealth(player:getMaxHealth())
	player:addMana(player:getMaxMana())
	player:registerEvent("Battlefield")
	player:teleportTo(BATTLEFIELD.TEAMS[team].temple)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	Game.setStorageValue(BATTLEFIELD.LAST_PLAYER, player:getGuid())
	Game.setStorageValue(BATTLEFIELD.TOTAL_PLAYERS, Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) + 1)

	return true
end
