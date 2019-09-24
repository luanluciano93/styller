dofile('data/lib/custom/duca.lua')

function onPrepareDeath(player, killer)

	if killer then
		local team = player:getStorageValue(Storage.events)
		local teamKiller = player:getStorageValue(Storage.events)
		if team > 0 and teamKiller > 0 then
			local points = {[1] = 1, [2] = 1, [3] = 10, [4] = 30}
			local pointsPerKill = points[team]
			killer:setStorageValue(Storage.ducaPoints, killer:getStorageValue(Storage.ducaPoints) + pointsPerKill)
			killer:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You have ".. killer:getStorageValue(Storage.ducaPoints) .." duca points.")
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are dead in duca event and your duca points is set to 0!")
			ducaRemovePlayer(player:getGuid())
			ducaUpdateRank()
		end
	end

	return false
end
