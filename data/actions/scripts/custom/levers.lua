local pos = {
	[8000] = Position(947, 1102, 9), -- divine place quest
	[8001] = Position(960, 1102, 9), -- vile axe quest
	[8002] = Position(799, 1096, 10), -- inquisition quest
	[8003] = Position(846, 995, 12) -- inquisition quest
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local position = pos[item.uid]
	if not position then
		return true
	end

	local tile = Tile(position)
	if tile then
		local stone = tile:getItemById(1355)
		if stone then
			stone:remove()
		else
			Game.createItem(1355, 1, position)
		end
	end

	item:transform(item.itemid == 1945 and 1946 or 1945)

 	return true
end
