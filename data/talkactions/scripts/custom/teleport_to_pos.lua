function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. Ex: /pos x, y, z")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local tile = param:split(",")
	local position
	if tile[1] and tile[2] and tile[3] then
		position = Position(tile[1], tile[2], tile[3])
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Invalid param specified. Ex: /pos x, y, z")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local positionTile = Tile(position)
	if not position or not positionTile then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Invalid tile position. Ex: /pos x, y, z")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if not positionTile:isWalkable() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Invalid tile position. Ex: /pos x, y, z")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local tmp = player:getPosition()
	if player:teleportTo(position) and not player:isInGhostMode() then
		tmp:sendMagicEffect(CONST_ME_POFF)
		position:sendMagicEffect(CONST_ME_TELEPORT)
	end

	return false
end
