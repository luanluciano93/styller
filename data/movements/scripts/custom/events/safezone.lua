dofile('data/lib/custom/safezone.lua')

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getGroup():getAccess() then
		player:teleportTo(SAFEZONE.positionEnterEvent)
		return true
	end

	if player:getLevel() < SAFEZONE.levelMin then
		player:sendCancelMessage("You need level " .. SAFEZONE.levelMin .. " to enter in safezone event.")
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
		if player:getIp() == check:getIp() and check:getStorageValue(SAFEZONE.storage) > 0 then
			player:sendCancelMessage("You already have another player inside the event.")
			player:teleportTo(fromPosition)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end
	end

	if safezone_totalPlayers() >= SAFEZONE.maxPlayers then
		player:sendCancelMessage("The event already has the maximum number of participants.")
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	eventsOutfit[player:getGuid()] = player:getOutfit()

	local outfit = player:getSex() == 0 and 136 or 128
	local treeLifeColor = SAFEZONE.lifeColor[3]
	player:setOutfit({lookType = outfit, lookHead = treeLifeColor, lookBody = treeLifeColor, lookLegs = treeLifeColor, lookFeet = treeLifeColor})

	player:sendTextMessage(MESSAGE_INFO_DESCR, "You entered the safezone event, good luck.")
	player:teleportTo(SAFEZONE.positionEnterEvent)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:setStorageValue(SAFEZONE.storage, 3)

	return true
end
