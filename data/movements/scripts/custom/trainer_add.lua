local function isBusyable(position)
	local player = Tile(position):getTopCreature()
	if player then
		if player:isPlayer() then
			return false
		end
	end

	local tile = Tile(position)
	if not tile then
		return false
	end

	local ground = tile:getGround()
	if not ground or ground:hasProperty(CONST_PROP_BLOCKSOLID) then
		return false
	end

	local items = tile:getItems()
	for i = 1, tile:getItemCount() do
		local item = items[i]
		local itemType = item:getType()
		if itemType:getType() ~= ITEM_TYPE_MAGICFIELD and not itemType:isMovable() and item:hasProperty(CONST_PROP_BLOCKSOLID) then
			return false
		end
	end

	return true
end

function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	local function addTrainers(pos)
		local arrayPos = {{x = pos.x - 1, y = pos.y + 1, z = pos.z}, {x = pos.x + 1 , y = pos.y + 1, z = pos.z}}
		for places = 1, #arrayPos do
			local trainer = Tile(arrayPos[places]):getTopCreature()
			if not trainer then
				local monster = Game.createMonster("Trainer", arrayPos[places])
				monster:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
		end
	end

	addTrainers(position)

	return true
end

function onStepOut(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	local function removeTrainers(pos)
		local arrayPos = {{x = pos.x - 1, y = pos.y + 1, z = pos.z}, {x = pos.x + 1 , y = pos.y + 1, z = pos.z}}
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

	return true
end
