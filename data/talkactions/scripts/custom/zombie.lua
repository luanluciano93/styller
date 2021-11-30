dofile('data/lib/custom/zombie.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if zombieTotalPlayers() == 0 then
			zombieTeleportCheck()
		else
			player:sendCancelMessage("Zombie event is already running.")
		end
	end
	return false
end
