function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	local function removeTrainers(position)
		local arrayPos = {{x = position.x - 1, y = position.y + 1, z = position.z}, {x = position.x + 1 , y = position.y + 1, z = position.z}}
		for places = 1, #arrayPos do
			local trainer = Tile(arrayPos[places]):getTopCreature()
			if trainer then
				if trainer:isMonster() then
					trainer:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
					trainer:remove()
				end
			end
		end
	end

	removeTrainers(fromPosition)
	creature:teleportTo(creature:getTown():getTemplePosition())
	creature:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	creature:setExhaustion(5, Storage.exhaustion.trainer)

	return true
end
