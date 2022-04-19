function onDeath(player, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)

	if killer:isPlayer() then
		local CHANNEL_DEATHCAST = 11
		sendChannelMessage(CHANNEL_DEATHCAST, TALKTYPE_CHANNEL_R1, "DeathCast: "..player:getName().." ["..player:getLevel().."] just got killed by "..killer:getName().." ["..killer:getLevel().."].")
	end
end
