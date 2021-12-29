function onKill(creature, target)
	local player = creature:isPlayer()
	if not player then
		return true
	end
	
	local pythius = target:isMonster()
	if not pythius then
		return true
	end

	if target:getName():lower() == "pythius the rotten" then
		creature:say("NICE FIGHTING LITTLE WORM, YOUR VICTORY SHALL BE REWARDED!.", TALKTYPE_MONSTER_SAY)
		creature:teleportTo(Position(1232, 1101, 8))
		creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end
