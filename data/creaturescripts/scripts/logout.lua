function onLogout(player)
	local playerId = player:getId()
	db.query("DELETE FROM `players_online` WHERE `player_id` = " .. playerId .. ";")
	if nextUseStaminaTime[playerId] then
		nextUseStaminaTime[playerId] = nil
	end

	local stats = player:inBossFight()
	if stats then
		-- Player logged out (or died) in the middle of a boss fight, store his damageOut and stamina
		local boss = Monster(stats.bossId)
		if boss then
			local dmgOut = boss:getDamageMap()[playerId]
			if dmgOut then
				stats.damageOut = (stats.damageOut or 0) + dmgOut.total
			end
			stats.stamina = player:getStamina()
		end
	end

	if player:getStorageValue(Storage.events) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	return true
end
