local position = {
	Position(1184, 1011, 13), -- stone position
	Position(1183, 1010, 13), -- teleport creation position
	Position(1201, 1011, 12) -- where the teleport takes you
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 1945 then
		local tile = position[1]:getTile()
		if tile then
			local stone = tile:getItemById(1355)
			if stone then
				stone:remove()
			end
		end

		local teleport = Game.createItem(1387, 1, position[2])
		if teleport then
			teleport:setDestination(position[3])
			position[2]:sendMagicEffect(CONST_ME_TELEPORT)
		end
	elseif item.itemid == 1946 then
		local tile = position[2]:getTile()
		if tile then
			local teleport = tile:getItemById(1387)
			if teleport and teleport:isTeleport() then
				teleport:remove()
			end
		end
		position[2]:sendMagicEffect(CONST_ME_POFF)
		Game.createItem(1355, 1, position[1])
	end
	return item:transform(item.itemid == 1945 and 1946 or 1945)
end