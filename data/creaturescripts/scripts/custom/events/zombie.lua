dofile('data/lib/custom/zombie.lua')

function onLogin(player)
	if player:getStorageValue(ZOMBIE.storage) > 0 then
		player:setStorageValue(ZOMBIE.storage, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(ZOMBIE.storage) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end

local function zombie_removePlayer(uid)
	local player = Player(uid)
	if player then
		player:removeCondition(CONDITION_INFIGHT)
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:unregisterEvent("Zombie")
		player:teleportTo(player:getTown():getTemplePosition())
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:setStorageValue(ZOMBIE.storage, 0)
	end
end

function zombie_checkFinishEvent()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(ZOMBIE.storage) > 0 then
			zombie_removePlayer(player:getGuid())
		end
	end
	addEvent(zombie_clearEvent, 1000)
end

function zombie_clearEvent()
	local spectators = Game.getSpectators(ZOMBIE.positionEnterEvent, false, false, 40, 40, 40, 40)
	for i = 1, #spectators do
		local monster = spectators[i]
		if monster:isMonster() then
			monster:getPosition():sendMagicEffect(CONST_ME_POFF)
			monster:remove()
		end
	end
end

function onHealthChange(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if attacker then
		if attacker:isMonster() and attacker:getName() == "Zombie" then
			local totalPlayers = zombie_totalPlayers()
			if totalPlayers > 0 then
				if totalPlayers == 1 then
					creature:say("ZOMBIE EVENT WIN!", TALKTYPE_MONSTER_SAY)
					Game.broadcastMessage("The player ".. creature:getName() .." is win zombie event.", MESSAGE_STATUS_WARNING)

					local itemType = ItemType(ZOMBIE.reward[1])
					if itemType:getId() ~= 0 then
						creature:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Congratulations, you won the zombie event and received ".. ZOMBIE.reward[2] .." ".. itemType:getName() .. " as a reward.")
						creature:addItem(itemType:getId(), ZOMBIE.reward[2])
					end

					local trophy = creature:addItem(10129, 1)
					if trophy then
						trophy:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, 'Awarded to '.. creature:getName() ..'.')
					end

					addEvent(zombie_checkFinishEvent, 3000)

					print(">>> Zombie event finish, winner: " .. creature:getName())
				else
					attacker:say("DEAD!", TALKTYPE_MONSTER_SAY)
					attacker:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
					local summon_position = creature:getPosition()
					Game.createMonster("Zombie Event", summon_position)
				end
			end

			zombie_removePlayer(creature:getGuid())
		end
	end

	return primaryDamage, primaryType, -secondaryDamage, secondaryType
end
