dofile('data/lib/custom/battlefield.lua')

function onSay(player, words, param)
	if player:getGroup():getAccess() then
		if Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) then
			if Game.getStorageValue(BATTLEFIELD.TOTAL_PLAYERS) > 0 then
				player:sendCancelMessage("Battlefield event is already active.")
				return false
			end
		end
		battlefieldTeleportCheck()
	end
	return false
end
