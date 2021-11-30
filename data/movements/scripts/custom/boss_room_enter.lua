local config = {
	[1] = {storage = Storage.bossRoom.thul, boss = "Thul"},
	[2] = {storage = Storage.bossRoom.theOldWidow, boss = "The Old Widow"},
	[3] = {storage = Storage.bossRoom.theMany, boss = "The Many"},
	[4] = {storage = Storage.bossRoom.theNoxiousSpawn, boss = "The Noxious Spawn"},
	[5] = {storage = Storage.bossRoom.stonecracker, boss = "Stonecracker"},
	[6] = {storage = Storage.bossRoom.leviathan, boss = "Leviathan"},
	[7] = {storage = Storage.bossRoom.demodras, boss = "Demodras"}
}

local centerRoom = {x = 1051, y = 1044, z = 8}

local function removePlayer(uid)
	local player = Player(uid)
	if player then
		if player:getStorageValue(Storage.bossRoom.enterRoom) > 0 then
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(Storage.bossRoom.enterRoom, 0)
		end
	end
end

function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return true
	end

	if creature:getExhaustion() <= 0 then
		if creature:getStorageValue(Storage.task.storageJoin) == 1 then
			local bossStorage = false
			for key, value in pairs(config) do
				if creature:getStorageValue(value.storage) > 0 then
					local pos = Position(centerRoom)
					if pos then
						local spectators, hasMonsters, hasPlayers = Game.getSpectators(pos, false, false, 6, 6, 6, 6), false, false
						for i = 1, #spectators do
							if spectators[i]:isMonster() and not spectators[i]:getMaster() then
								hasMonsters = true
							elseif spectators[i]:isPlayer() then
								hasPlayers = true
							end
						end

						if hasMonsters and not hasPlayers then
							for i = 1, #spectators do
								if spectators[i]:isMonster() then
									spectators[i]:remove()
								end
							end
						elseif hasPlayers and not hasMonsters then
							for i = 1, #spectators do
								if spectators[i]:isPlayer() then
									spectators[i]:teleportTo(spectators[i]:getTown():getTemplePosition())
								end
							end
						elseif hasPlayers and hasMonsters then
							creature:teleportTo(fromPosition, true)
							creature:getPosition():sendMagicEffect(CONST_ME_POFF)
							creature:sendCancelMessage("Boss room is busy.")
							creature:setExhaustion(5)
							return false
						end

						local monster = Game.createMonster(value.boss, pos)
						if monster then
							creature:teleportTo(pos)
							creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
							creature:setStorageValue(value.storage, 0)
							creature:setStorageValue(Storage.bossRoom.enterRoom, 1)
							addEvent(removePlayer, 600000, creature:getGuid())
							creature:sendTextMessage(MESSAGE_INFO_DESCR, "You have 10 minutes to kill the boss.")
							return true
						else
							creature:teleportTo(fromPosition, true)
							creature:getPosition():sendMagicEffect(CONST_ME_POFF)
							creature:sendCancelMessage("This boss does not exist.")
							creature:setExhaustion(5)
							return false
						end

						bossStorage = true
					end
					break
				end
			end

			if not bossStorage then
				creature:teleportTo(fromPosition, true)
				creature:getPosition():sendMagicEffect(CONST_ME_POFF)
				creature:sendCancelMessage("There is no boss for you to kill.")
				creature:setExhaustion(10)
				return false
			end
		else
			creature:teleportTo(fromPosition, true)
			creature:getPosition():sendMagicEffect(CONST_ME_POFF)
			creature:sendCancelMessage("You're exhausted.")
			return false
		end
	else
		creature:teleportTo(fromPosition, true)
		creature:sendCancelMessage("You're exhausted.")
	end

	return true
end
