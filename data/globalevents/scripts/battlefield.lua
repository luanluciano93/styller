dofile('data/lib/custom/battlefield.lua')

function onTime(interval)
	if battlefieldTotalPlayers() == 0 then
		battlefieldTeleportCheck()
	else
		print(">> Battlefield event is already running.")
	end
	return true
end
