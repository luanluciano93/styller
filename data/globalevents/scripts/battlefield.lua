dofile('data/lib/custom/battlefield.lua')

function onTime(interval)
	battlefieldTeleportCheck()
	return true
end
