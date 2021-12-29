function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	creature:teleportTo(creature:getTown():getTemplePosition())
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	creature:setStorageValue(Storage.bossRoom.enterRoom, 0)

	return true
end
