function onKill(creature, target)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	
	local koshei = target:getMonster()
	if not koshei then
		return true
	end
	
	if target:getName():lower() == "pythius the rotten" then
		player:say("NICE FIGHTING LITTLE WORM, YOUR VICTORY SHALL BE REWARDED!.", TALKTYPE_MONSTER_SAY)
		player:teleportTo(Position(1232, 1101, 8))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end
