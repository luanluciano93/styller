function onSay(player, words, param)

	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	local target
	if param == '' then
		target = player:getTarget()
		if not target then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'Gives players the ability to wear all addons. Ex: /addons playerName')
			return false
		end
	else
		target = Player(param)
	end

	if not target then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, 'Player ' .. param .. ' is currently not online.')
		return false
	end

	local looktypes = {
		128, 136, 129, 137, 130, 138, 131, 139, 132, 140, 133, 141, 134, 142,
		143, 147, 144, 148, 145, 149, 146, 150, 151, 155, 152, 156, 153, 157,
		154, 158, 251, 252, 268, 269, 273, 270, 278, 279, 289, 288, 325, 324,
		335, 336, 366, 367, 328, 329
	}

	for i = 1, #looktypes do
		target:addOutfitAddon(looktypes[i], 3)
	end

	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'All addons unlocked for ' .. target:getName() .. '.')
	target:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, '[Server] All addons unlocked.')

	logCommand(player, words, param)

	return false
end
