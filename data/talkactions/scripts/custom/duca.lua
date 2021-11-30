dofile('data/lib/custom/duca.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if ducaTotalPlayers() == 0 then
			ducaTeleportCheck()
		else
			player:sendCancelMessage("Duca event is already running.")
		end
	end
	return false
end
