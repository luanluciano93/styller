local pos = {   
	DEMON_OAK_KICK_POSITION = Position(877, 1025, 7),
	DEMON_OAK_POSITION = Position(877, 1036, 7)
}

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local spectators, hasMonsters = Game.getSpectators(pos.DEMON_OAK_POSITION, false, false, 9, 9, 6, 6), false
	for i = 1, #spectators do
		if spectators[i]:isMonster() then
			hasMonsters = true
			break
		end
	end

	if hasMonsters then
		player:sendCancelMessage("You need to kill all monsters first.")
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:teleportTo(pos.DEMON_OAK_KICK_POSITION)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end
