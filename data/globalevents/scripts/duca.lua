dofile('data/lib/custom/duca.lua')

function onTime(interval)
	if ducaTotalPlayers() == 0 then
		ducaTeleportCheck()
	else
		print(">> Duca event is already running.")
	end
	return true
end
