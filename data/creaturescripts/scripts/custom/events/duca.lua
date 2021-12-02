dofile('data/lib/custom/duca.lua')

function onLogin(player)
	if player:getStorageValue(DUCA.storage) > 0 then
		player:setStorageValue(DUCA.storage, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(DUCA.storage) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end

function onPrepareDeath(player, killer)
	if killer then
		local team = player:getStorageValue(DUCA.storage)
		local teamKiller = killer:getStorageValue(DUCA.storage)
		if team > 0 and teamKiller > 0 then
			local points = {[1] = 1, [2] = 1, [3] = 10, [4] = 30}
			local pointsPerKill = points[team]
			killer:setStorageValue(DUCA.ducaPoints, killer:getStorageValue(DUCA.ducaPoints) + pointsPerKill)
			killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have ".. killer:getStorageValue(DUCA.ducaPoints) .." duca points.")
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are dead in duca event and your duca points is set to 0!")
			Game.setStorageValue(DUCA.totalDeaths, Game.getStorageValue(DUCA.totalDeaths) + 1)
			duca_removePlayer(player:getGuid())
			duca_updateRank()
		end
	end
	return false
end
