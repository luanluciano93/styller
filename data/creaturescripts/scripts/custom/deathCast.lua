function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)

	if killer:isPlayer() then
		Game.broadcastMessage("DeathCast: "..player:getName().." ["..player:getLevel().."] just got killed by "..killer:getName().." ["..killer:getLevel().."].", MESSAGE_STATUS_DEFAULT)
	end
end
