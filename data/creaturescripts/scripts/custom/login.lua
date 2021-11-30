local events = {
    'PlayerDeath',
	'DropLoot',
	'AdvanceSave',
	'LevelReward',
	'BossParticipation',
	'KosheiKill',
	'PythiusTheRotten',
	'Tasks',
	'BossAchievements'
}
function onLogin(player)
	local serverName = configManager.getString(configKeys.SERVER_NAME)
	local loginStr = "Welcome to " .. serverName .. "!"
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit in %s: %s.", serverName, os.date("%d %b %Y %X", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	-- Stamina
	nextUseStaminaTime[player.uid] = 0

	-- Events
	for i = 1, #events do
		player:registerEvent(events[i])
	end

	return true
end
