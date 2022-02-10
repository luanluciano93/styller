function onSay(player, words, param)

	local exaust = player:getExhaustion(Storage.exhaustion.guildBroadcast)
	if exaust > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You're exhausted for ".. exaust .. " seconds.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guild = player:getGuild()
	if not guild then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD BROADCAST] You don't have a guild.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

    if player:getGuildLevel() == 1 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD BROADCAST] You must be a leader or vice-leader to send broadcasts to the guild.")
        player:getPosition():sendMagicEffect(CONST_ME_POFF)
        return false
    end

	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD BROADCAST] Insufficient parameters. Ex: !guild message")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local value = CUSTOM.valueForSendGuildBroadcast

	if player:removeTotalMoney(value) then
		for _, members in ipairs(guild:getMembersOnline()) do
			members:sendPrivateMessage(player, param, TALKTYPE_BROADCAST)
		end
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD BROADCAST] You need ".. value .." gold coins to send broadcasts to the guild.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(60, Storage.exhaustion.guildBroadcast)

    return false
end
