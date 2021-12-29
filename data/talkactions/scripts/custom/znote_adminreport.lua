function onSay(player, words, param)

	local storage = Storage.znoteAdminReport
	local delaytime = 30

	if param == '' then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Command param required. !report message")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local delaySeconds = player:getStorageValue(storage) - os.time()
	if delaySeconds > 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You have to wait " .. delaySeconds .. " seconds to report again.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	db.query("INSERT INTO `znote_player_reports` (`id` ,`name` ,`posx` ,`posy` ,`posz` ,`report_description` ,`date`) VALUES (NULL ,  " 
	.. db.escapeString(player:getName()) .. ",  '" .. player:getPosition().x .. "',  '" .. player:getPosition().y .. "',  '" .. player:getPosition().z .. "',  " .. db.escapeString(param) .. ",  '" .. os.time() .. "')")
	player:sendTextMessage(MESSAGE_INFO_DESCR, "Your report has been received successfully!")
	player:setStorageValue(storage, os.time() + delaytime)

	return false
end
