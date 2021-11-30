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
	
function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	removeTrainers(fromPosition)
	player:teleportTo(player:getTown():getTemplePosition())
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:setExhaustion(5)

	return true
end
