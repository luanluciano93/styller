dofile('data/lib/custom/battlefield.lua')

function onTime(interval)
	if battlefield_totalPlayers() == 0 then
		battlefield_teleportCheck()
	else
		print(">>> Battlefield event is already running.")
	end
	return true
end
