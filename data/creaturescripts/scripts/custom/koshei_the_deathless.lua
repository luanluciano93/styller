function onKill(creature, target)
	local player = creature:isPlayer()
	if not player then
		return true
	end
	
	local koshei = target:isMonster()
	if not koshei then
		return true
	end
	
	if target:getName():lower() == "koshei the deathless" then
		creature:setStorageValue(Storage.blueLegsQuest, 1)
		creature:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		creature:say("You can open the magic door! grrrrr!.", TALKTYPE_MONSTER_SAY)
	end

	return true
end
