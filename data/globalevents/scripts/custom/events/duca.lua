dofile('data/lib/custom/duca.lua')

function onTime(interval)
	if duca_totalPlayers() == 0 then
		duca_teleportCheck()
	else
		print(">>> Duca event is already running.")
	end
	return true
end
