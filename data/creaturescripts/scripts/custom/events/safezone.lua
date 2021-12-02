dofile('data/lib/custom/safezone.lua')

function onLogin(player)
	if player:getStorageValue(SAFEZONE.storage) > 0 then
		player:setStorageValue(SAFEZONE.storage, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(SAFEZONE.storage) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end
