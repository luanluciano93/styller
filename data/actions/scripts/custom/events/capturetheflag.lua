dofile('data/lib/custom/capturetheflag.lua')

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if item.itemid == CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagId and player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
        if player:getStorageValue(CAPTURETHEFLAG.storage) == 1 then
            if item:getPosition() == CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagPosition then
                return player:sendCancelMessage("You cannot pick up your own flag.")
            else
                item:moveTo(CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagPosition)
                capturetheflag_broadcastToPlayers("The red assassins team flag was recovered.")
            end
        else
            redFlagHolder = player:getName()
            item:remove()
            capturetheflag_broadcastToPlayers("The red flag has been taken by ".. player:getName() .."!")
			player:setSkull(SKULL_GREEN)
        end
  
    elseif item.itemid == CAPTURETHEFLAG.teamsCaptureTheFlag[2].flagId and player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
        if player:getStorageValue(CAPTURETHEFLAG.storage) == 2 then
            if item:getPosition() == CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagPosition then
                return player:sendCancelMessage("You cannot pick up your own flag.")
            else
                item:moveTo(CAPTURETHEFLAG.teamsCaptureTheFlag[1].flagPosition)
                capturetheflag_broadcastToPlayers("The green assassins team flag was recovered.")
            end
        else
            greenFlagHolder = player:getName()
            item:remove()
            capturetheflag_broadcastToPlayers("The green flag has been taken by ".. player:getName() .."!")
			player:setSkull(SKULL_GREEN)
        end
    end
    return true
end
