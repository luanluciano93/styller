dofile('data/lib/custom/battlefield.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if battlefieldTotalPlayers() == 0 then
			battlefieldTeleportCheck()
		else
			player:sendCancelMessage("Battlefield event is already running.")
		end
	end
	return false
end
