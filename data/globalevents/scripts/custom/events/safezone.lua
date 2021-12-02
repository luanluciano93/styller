dofile('data/lib/custom/safezone.lua')

function onTime(interval)
	if safezone_totalPlayers() == 0 then
		safezone_teleportCheck()
	else
		print(">>> Safezone event is already running.")
	end
	return true
end
