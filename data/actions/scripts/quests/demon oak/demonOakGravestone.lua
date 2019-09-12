function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local DEMON_OAK_REWARDROOM_POSITION = Position(838, 1022, 8)
	if player:getStorageValue(Storage.demonOak.progress) == 2 then
		player:teleportTo(DEMON_OAK_REWARDROOM_POSITION)
		DEMON_OAK_REWARDROOM_POSITION:sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end