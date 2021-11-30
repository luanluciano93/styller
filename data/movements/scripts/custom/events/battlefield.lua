dofile('data/lib/custom/battlefield.lua')

local function battlefieldBalanceTeam()
	local time1, time2 = 0, 0
	for _, uid in ipairs(Game.getPlayers()) do
		if uid:getStorageValue(Storage.events) == 5 then
			time1 = time1 + 1
		elseif uid:getStorageValue(Storage.events) == 6 then
			time2 = time2 + 1
		end
	end
	return (time1 <= time2) and 5 or 6
end

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getGroup():getAccess() then
		player:teleportTo(BATTLEFIELD.teamsBattlefield[5].temple)
		return true
	end

	if player:getLevel() < BATTLEFIELD.levelMin then
		player:sendCancelMessage("You need level " .. BATTLEFIELD.levelMin .. " to enter in battlefield event.")
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
	player:setOutfit(BATTLEFIELD.teamsBattlefield[team].outfit)
	player:setStorageValue(Storage.events, team)
	player:sendTextMessage(MESSAGE_INFO_DESCR, "You will join the " .. BATTLEFIELD.teamsBattlefield[team].color .. ".")
	player:addHealth(player:getMaxHealth())
	player:addMana(player:getMaxMana())
	player:registerEvent("Battlefield")
	player:teleportTo(BATTLEFIELD.teamsBattlefield[team].temple)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	Game.setStorageValue(BATTLEFIELD.lastPlayer, player:getGuid())

	return true
end
