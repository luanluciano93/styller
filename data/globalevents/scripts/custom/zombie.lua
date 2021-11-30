dofile('data/lib/custom/zombie.lua')

function onTime(interval)
	if zombieTotalPlayers() == 0 then
		zombieTeleportCheck()
	else
		print(">> Zombie event is already running.")
	end
	return true
end
