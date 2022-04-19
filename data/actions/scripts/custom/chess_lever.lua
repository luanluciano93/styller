-- <action actionid="1530" script="custom/chess_lever.lua" />

local firstPosition = Position(1018, 963, 8)

function onUse(player, item, fromPosition, target, toPosition, isHotkey)

	-- removendo as peças
	for a = 0, 7 do
		for b = 0, 7 do
			local position = {x = firstPosition.x + a, y = firstPosition.y + b, z = firstPosition.z}
			local tile = Tile(position)
			if tile then
				local c = 0
				while c == 0 do
					local thing = tile:getTopVisibleThing(player)
					if thing then
						if thing:isItem() and thing ~= tile:getGround() then
							thing:remove()
						else
							c = 1
						end
					end
				end
			end
		end
	end

	-- escolhendo a cor das peças
	local rand = math.random(1, 2)
	local positionWhiteOne = 0
	local positionWhiteTwo = 0
	local positionBlackOne = 0
	local positionBlackTwo = 0

	-- colocando os peoes
	for d = 0, 7 do
		positionWhiteOne = {x = firstPosition.x + d, y = firstPosition.y + 1, z = firstPosition.z}
		Game.createItem(rand == 1 and 2626 or 2632, 1, positionWhiteOne)
		positionBlackOne = {x = firstPosition.x + d, y = firstPosition.y + 6, z = firstPosition.z}
		Game.createItem(rand == 1 and 2632 or 2626, 1, positionBlackOne)
	end

	-- colocando as torres
	Game.createItem(rand == 1 and 2627 or 2633, 1, firstPosition)
	positionWhiteTwo = {x = firstPosition.x + 7, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2627 or 2633, 1, positionWhiteTwo)

	positionBlackOne = {x = firstPosition.x, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2633 or 2627, 1, positionBlackOne)
	positionBlackTwo = {x = firstPosition.x + 7, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2633 or 2627, 1, positionBlackTwo)

	-- colocando os cavalos
	positionWhiteOne = {x = firstPosition.x + 1, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2628 or 2634, 1, positionWhiteOne)
	positionWhiteTwo = {x = firstPosition.x + 6, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2628 or 2634, 1, positionWhiteTwo)

	positionBlackOne = {x = firstPosition.x + 1, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2634 or 2628, 1, positionBlackOne)
	positionWhiteTwo = {x = firstPosition.x + 6, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2634 or 2628, 1, positionWhiteTwo)

	-- colocando os bispos
	positionWhiteOne = {x = firstPosition.x + 2, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2629 or 2635, 1, positionWhiteOne)
	positionWhiteTwo = {x = firstPosition.x + 5, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2629 or 2635, 1, positionWhiteTwo)

	positionBlackOne = {x = firstPosition.x + 2, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2635 or 2629, 1, positionBlackOne)
	positionWhiteTwo = {x = firstPosition.x + 5, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2635 or 2629, 1, positionWhiteTwo)

	-- colocando as rainhas e reis
	positionWhiteOne = {x = firstPosition.x + 3, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2631 or 2637, 1, positionWhiteOne)
	positionWhiteTwo = {x = firstPosition.x + 4, y = firstPosition.y, z = firstPosition.z}
	Game.createItem(rand == 1 and 2630 or 2636, 1, positionWhiteTwo)

	positionBlackOne = {x = firstPosition.x + 3, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2637 or 2631, 1, positionBlackOne)
	positionWhiteTwo = {x = firstPosition.x + 4, y = firstPosition.y  + 7, z = firstPosition.z}
	Game.createItem(rand == 1 and 2636 or 2630, 1, positionWhiteTwo)

	item:transform(item.itemid == 1945 and 1946 or 1945)
	return true
end
