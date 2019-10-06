dofile('data/lib/custom/achievements.lua')

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	item:transform(2786)
	item:decay()
	Game.createItem(2677, 3, fromPosition)

	if player:getStorageValue(Storage.achievements.blueberryBush) <= 499 then
		player:setStorageValue(Storage.achievements.blueberryBush, player:getStorageValue(Storage.achievements.blueberryBush) + 1)
	end

	if player:getStorageValue(Storage.achievements.blueberryBush) == 499 then
		player:addAchievement(1) -- Bluebarian
	end

	return true
end
