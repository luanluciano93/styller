local events = {
	'DropLoot',
	'DeathCast',
	'AdvanceSave',
	'LevelReward',
    'znotePlayerDeath',
	'BossAchievements',
	'Tasks',
	'KosheiKill',
	'PythiusTheRotten'
}

function onLogin(player)
	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
		player:setBankBalance(0)
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	-- Events
	for i = 1, #events do
		player:registerEvent(events[i])
	end

	if not player:isPremium() then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You are not yet a premium account, enter our website and enjoy the benefits of being premium.")
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You have "..player:getPremiumDays().." days of premium account.")
	end

	player:openChannel(11) -- Deathcast

	return true
end
