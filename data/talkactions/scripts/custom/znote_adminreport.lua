function onSay(player, words, param)

	local exaust = player:getExhaustion(Storage.exhaustion.znoteAdminReport)
	if exaust > 0 then
		player:sendTextMessage(MESSAGE_INFO_DESCR, "You're exhausted for ".. exaust .. " seconds.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. !report message")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	player:setExhaustion(30, Storage.exhaustion.znoteAdminReport)

	db.query("INSERT INTO `znote_player_reports` (`id` ,`name` ,`posx` ,`posy` ,`posz` ,`report_description` ,`date`) VALUES (NULL ,  " 
	.. db.escapeString(player:getName()) .. ",  '" .. player:getPosition().x .. "',  '" .. player:getPosition().y .. "',  '" .. player:getPosition().z .. "',  " .. db.escapeString(param) .. ",  '" .. os.time() .. "')")
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Your report has been received successfully!")

	return false
end
