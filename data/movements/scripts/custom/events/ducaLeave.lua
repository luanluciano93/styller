dofile('data/lib/custom/duca.lua')

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	duca_removePlayer(player:getGuid())
	duca_updateRank()

	player:sendCancelMessage("You left the duca event.")

	return true
end
