dofile('data/lib/custom/capturetheflag.lua')

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if item.actionid == 9619 then

		if player:getGroup():getAccess() then
			player:teleportTo(CAPTURETHEFLAG.teamsCaptureTheFlag[1].temple)
			return true
		end

		if player:getLevel() < CAPTURETHEFLAG.levelMin then
			player:sendCancelMessage("You need level " .. CAPTURETHEFLAG.levelMin .. " to enter in capture the flag event.")
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
			if player:getIp() == check:getIp() and check:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
				player:sendCancelMessage("You already have another player inside the event.")
				player:teleportTo(fromPosition)
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
		end

		eventsOutfit[player:getGuid()] = player:getOutfit()

		player:setStorageValue(CAPTURETHEFLAG.storage, 1)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You will join the event, wait.")
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:registerEvent("CaptureTheFlag")
		player:teleportTo(CAPTURETHEFLAG.positionEnterEvent)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

		Game.setStorageValue(CAPTURETHEFLAG.lastPlayer, player:getGuid())
		return true

	elseif item.actionid == 9620 then
        if player:getStorageValue(CAPTURETHEFLAG.storage) == 1 then
            if greenFlagHolder ~= player:getName() then
                player:teleportTo(fromPosition, true)
                player:sendCancelMessage("You cannot stand on your capture tile.")
                return false
            else
                player:teleportTo(fromPosition, true)
                greenFlagHolder = nil
				capturetheflag_addScore(1)
				capturetheflag_addFlag(2, CAPTURETHEFLAG.teamsCaptureTheFlag[2].flagPosition)
				player:setSkull(SKULL_NONE)

                if CAPTURETHEFLAG.redScore == CAPTURETHEFLAG.flagsTotalToFinish then
                    capturetheflag_finishEvent(1)
                    return true
                end
              
                capturetheflag_broadcastToPlayers("The red assassins team has captured the green assassins team flag! The score is now: Red Assassins ".. CAPTURETHEFLAG.redScore .." x ".. CAPTURETHEFLAG.greenScore .." Green Asassins.")
            end
        else
            player:teleportTo(fromPosition, true)
            player:sendCancelMessage("You are not of this team.")
            return false
        end
      
    elseif item.actionid == 9621 then
        if player:getStorageValue(CAPTURETHEFLAG.storage) == 2 then
            if redFlagHolder ~= player:getName() then
                player:teleportTo(fromPosition, true)
                player:sendCancelMessage("You cannot stand on your capture tile.")
                return false
            else
                player:teleportTo(fromPosition, true)
                redFlagHolder = nil
                capturetheflag_addScore(2)
                capturetheflag_addFlag(1, CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagPosition)
				player:setSkull(SKULL_NONE)
              
                if CAPTURETHEFLAG.greenScore == CAPTURETHEFLAG.flagsTotalToFinish then
                    capturetheflag_finishEvent(2)
                    return true
                end

				capturetheflag_broadcastToPlayers("The green assassins team has captured the red assassins team flag! The score is now: Red Assassins ".. CAPTURETHEFLAG.redScore .." x ".. CAPTURETHEFLAG.greenScore .." Green Asassins.")
            end
        else
            player:teleportTo(fromPosition, true)
            player:sendCancelMessage("You are not of this team.")
            return false
        end
    end

	return true
end
