dofile('data/lib/custom/styllerConfig.lua')

function onSay(player, words, param)
    
	local storage = Storage.guildBroadcast
	local cooldown = 1 * 60
	local value = STYLLER.valueForSendGuildBroadcast

	local delayMinutes = player:getStorageValue(storage) - os.time()
	if delayMinutes > 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Can only be executed once every " .. delayMinutes .. " seconds. Remaining cooldown: " .. delayMinutes .. ".")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guild = player:getGuild()
	if not guild then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You don't have a guild.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

    if player:getGuildLevel() == 1 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You must be a leader or vice-leader to send broadcasts to the guild.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Insufficient parameters. Ex: !guild message")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if player:removeTotalMoney(value) then
		for _, members in ipairs(guild:getMembersOnline()) do
			members:sendPrivateMessage(player, param, TALKTYPE_BROADCAST)
		end
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You need ".. value .." gold coins to send broadcasts to the guild.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setStorageValue(storage, os.time() + cooldown)

    return false
end
