dofile('data/lib/custom/zombie.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if zombie_totalPlayers() == 0 then
			zombie_teleportCheck()
		else
			player:sendCancelMessage("Zombie event is already running.")
		end
	end
	return false
end
