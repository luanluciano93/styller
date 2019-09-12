local config = {
	[1] = {
		--equipment: steel helmet, plate armor, plate legs, dwarven shield, leather boots, platinum amulet, wand of vortex
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2525, 1}, {2643, 1}, {2171, 1}, {2190, 1}},
		--container rope, shovel, mana potion
		container = {{2120, 1}, {2554, 1}, {2160, 1}, {7620, 5}}
	},
	[2] = {
		--equipment: steel helmet, plate armor, plate legs, dwarven shield, leather boots, platinum amulet, snakebite rod
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2525, 1}, {2643, 1}, {2171, 1}, {2182, 1}},
		--container rope, shovel, mana potion
		container = {{2120, 1}, {2554, 1}, {2160, 1}, {7620, 5}}
	},
	[3] = {
		--equipment: steel helmet, plate armor, plate legs, dwarven shield, leather boots, platinum amulet, 5 spear
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2525, 1}, {2643, 1}, {2171, 1}, {2389, 1}},
		--container rope, shovel, health potion, bow, 50 arrow
		container = {{2120, 1}, {2554, 1}, {2160, 1}, {7618, 5}, {2456, 1}, {2544, 50}}
	},
	[4] = {
		--equipment: steel helmet, plate armor, plate legs, dwarven shield, leather boots, platinum amulet, steel axe, brass armor, brass helmet
		items = {{2457, 1}, {2463, 1}, {2647, 1}, {2525, 1}, {2643, 1}, {2171, 1}, {8601, 1}},
		--container rope, shovel, health potion, jagged sword, daramian mace
		container = {{2120, 1}, {2554, 1}, {2160, 1}, {7618, 5}, {8602, 1}, {2439, 1}}
	}
}

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if player == nil then
		return false
	end

	local targetVocation = config[player:getVocation():getId()]
	if not targetVocation then
		return true
	end

	for i = 1, #targetVocation.items do
		player:addItem(targetVocation.items[i][1], targetVocation.items[i][2])
	end

	local backpack = player:addItem(5949)
	if not backpack then
		return true
	end

	for i = 1, #targetVocation.container do
		backpack:addItem(targetVocation.container[i][1], targetVocation.container[i][2])
	end

	local town = Town(2)
	player:setTown(town)
	player:teleportTo(town:getTemplePosition())
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You are now a citizen of ' .. town:getName() .. '.')

	return true
end
