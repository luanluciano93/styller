local maxItemsPerTile = 30

local maxItemsPerTile_itemMoved = EventCallback

maxItemsPerTile_itemMoved.onMoveItem = function(self, item, count, fromPosition, toPosition, fromCylinder, toCylinder)

	local tile = Tile(toPosition)
	if tile then
		if tile:getDownItemCount() >= maxItemsPerTile then
			return false
		end
	end

	return true
end

maxItemsPerTile_itemMoved:register(-1)
