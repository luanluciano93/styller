dofile('data/lib/custom/duca.lua')

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getGroup():getAccess() then
		player:teleportTo(DUCA.teamsDuca[1].temple)
		return true
	end

	if player:getLevel() < DUCA.levelMin then
		player:sendCancelMessage("You need level " .. DUCA.levelMin .. " to enter in duca event.")
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
		if player:getIp() == check:getIp() and check:getStorageValue(DUCA.storage) > 0 then
			player:sendCancelMessage("You already have another player inside the event.")
			player:teleportTo(fromPosition)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	eventsOutfit[player:getGuid()] = player:getOutfit()												

	local team = duca_balanceTeam()
	duca_addPlayerinTeam(player:getGuid(), team)
	player:registerEvent("Duca")
	player:teleportTo(DUCA.teamsDuca[team].temple)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:setStorageValue(DUCA.ducaPoints, 0)

	return true
end
