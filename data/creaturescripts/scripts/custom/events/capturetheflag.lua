dofile('data/lib/custom/capturetheflag.lua')

function onLogin(player)
	if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
		player:setStorageValue(CAPTURETHEFLAG.storage, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end

function onPrepareDeath(player, killer)
	if player:getStorageValue(CAPTURETHEFLAG.storage) > 0 and killer:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
		if redFlagHolder == player:getName() then
			redFlagHolder = nil
			player:setSkull(SKULL_NONE)
			capturetheflag_addFlag(1, player:getPosition())
		elseif greenFlagHolder == player:getName() then
			greenFlagHolder = nil
			player:setSkull(SKULL_NONE)
			capturetheflag_addFlag(2, player:getPosition())
		end
		player:addHealth(player:getMaxHealth())
		player:addMana(player:getMaxMana())
		player:teleportTo(CAPTURETHEFLAG.teamsCaptureTheFlag[player:getStorageValue(CAPTURETHEFLAG.storage)].temple)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
	return false
end
