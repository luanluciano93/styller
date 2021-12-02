dofile('data/lib/custom/capturetheflag.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if capturetheflag_totalPlayers() == 0 then
			capturetheflag_teleportCheck()
		else
			player:sendCancelMessage("Capture the Flag event is already running.")
		end
	end
	return false
end
