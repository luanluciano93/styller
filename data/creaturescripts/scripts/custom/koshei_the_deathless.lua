function onKill(creature, target)
	local player = creature:getPlayer()
	if not player then
		return true
	end
	
	local koshei = target:getMonster()
	if not koshei then
		return true
	end
	
	if target:getName():lower() == "koshei the deathless" then
		player:setStorageValue(Storage.blueLegsQuest, 1)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		player:say("You can open the magic door! grrrrr!.", TALKTYPE_MONSTER_SAY)
	end

	return true
end