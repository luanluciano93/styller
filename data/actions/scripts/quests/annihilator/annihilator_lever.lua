local config = {
	requiredLevel = 100,
	centerDemonRoomPosition = Position(1008, 1028, 10),
	playerPositions = {
		Position(1010, 1028, 9),
		Position(1009, 1028, 9),
		Position(1008, 1028, 9),
		Position(1007, 1028, 9)
	},
	newPositions = {
		Position(1009, 1028, 10),
		Position(1008, 1028, 10),
		Position(1007, 1028, 10),
		Position(1006, 1028, 10)
	},
	demonPositions = {
		Position(1006, 1026, 10),
		Position(1008, 1026, 10),
		Position(1009, 1030, 10),
		Position(1007, 1030, 10),
		Position(1010, 1028, 10),
		Position(1011, 1028, 10)
	}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 1946 then

		local players = {}
		for _, position in ipairs(config.playerPositions) do
			local topPlayer = Tile(position):getTopCreature()
			if not topPlayer or not topPlayer:isPlayer() then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, "You need 4 players.")
				return false
			end

			if topPlayer:getLevel() < config.requiredLevel then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, "All the players need to be level ".. config.requiredLevel .." or higher.")
				return false
			end

			players[#players + 1] = topPlayer
		end

		local specs, spec = Game.getSpectators(config.centerDemonRoomPosition, false, false, 3, 3, 2, 2)
		for i = 1, #specs do
			spec = specs[i]
			if spec:isPlayer() then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, "A team is already inside the quest room.")
				return false
			end

			spec:remove()
		end

		for i, demonPosition in ipairs(config.demonPositions) do
			Game.createMonster("Demon", demonPosition)
		end

		for i, targetPlayer in ipairs(players) do
			Position(playerPosition[i]):sendMagicEffect(CONST_ME_POFF)
			targetPlayer:teleportTo(config.newPositions[i], false)
			targetPlayer:getPosition():sendMagicEffect(CONST_ME_ENERGYAREA)
			targetPlayer:setDirection(DIRECTION_EAST)
		end
	end

	item:transform(item.itemid == 1946 and 1945 or 1946)
	return true
end
