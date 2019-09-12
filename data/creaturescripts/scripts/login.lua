local function onMovementRemoveProtection(cid, oldPosition, time)
	local player = Player(cid)
	if not player then
		return true
	end

	local playerPosition = player:getPosition()
	if (playerPosition.x ~= oldPosition.x or playerPosition.y ~= oldPosition.y or playerPosition.z ~= oldPosition.z) or player:getTarget() then
		player:setStorageValue(Storage.combatProtectionStorage, 0)
		return true
	end

	addEvent(onMovementRemoveProtection, 1000, cid, oldPosition, time - 1)
end

local events = {
    'PlayerDeath',
	'DropLoot',
	'BossParticipation',
	'LevelReward',
	'KosheiKill',
	'PythiusTheRotten'
}

function onLogin(player)
	local loginStr = "Welcome to " .. configManager.getString(configKeys.SERVER_NAME) .. "! "
	if player:getLastLoginSaved() <= 0 then
		loginStr = loginStr .. " Please choose your outfit."
		player:sendOutfitWindow()
		player:setBankBalance(0)
	else
		if loginStr ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)
		end

		loginStr = string.format("Your last visit was on %s.", os.date("%a %b %d %X %Y", player:getLastLoginSaved()))
	end
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, loginStr)

	local playerId = player:getId()

	-- Stamina
	nextUseStaminaTime[playerId] = 1

	-- EXP Stamina
	nextUseXpStamina[playerId] = 1

	-- Rewards notice
	local rewards = #player:getRewardList()
	if(rewards > 0) then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, string.format("You have %d %s in your reward chest.", rewards, rewards > 1 and "rewards" or "reward"))
	end

	-- Update player id
	local stats = player:inBossFight()
	if stats then
		stats.playerId = player:getId()
	end
	
    -- Events
    for i = 1, #events do
        player:registerEvent(events[i])
    end

	if player:getStorageValue(Storage.combatProtectionStorage) <= os.time() then
		player:setStorageValue(Storage.combatProtectionStorage, os.time() + 10)
		onMovementRemoveProtection(playerId, player:getPosition(), 10)
	end
	db.query('INSERT INTO `players_online` (`player_id`) VALUES (' .. playerId .. ')')
	
	-- Msg to Premium
	-- if player:isPremium() then
	-- end
	
	--[[
	if (InitArenaScript ~= 0) then
		InitArenaScript = 1
		-- make arena rooms free
		for i = 42300, 42309 do
			setGlobalStorageValue(i, 0)
			setGlobalStorageValue(i+100, 0)
		end
    end
    -- if he did not make full arena 1 he must start from zero
    if getPlayerStorageValue(cid, 42309) < 1 then
        for i = 42300, 42309 do
            setPlayerStorageValue(cid, i, 0)
        end
    end
    -- if he did not make full arena 2 he must start from zero
    if getPlayerStorageValue(cid, 42319) < 1 then
        for i = 42310, 42319 do
            setPlayerStorageValue(cid, i, 0)
        end
    end
    -- if he did not make full arena 3 he must start from zero
    if getPlayerStorageValue(cid, 42329) < 1 then
        for i = 42320, 42329 do
            setPlayerStorageValue(cid, i, 0)
        end
    end
    if getPlayerStorageValue(cid, 42355) == -1 then
        setPlayerStorageValue(cid, 42355, 0) -- did not arena level
    end
    setPlayerStorageValue(cid, 42350, 0) -- time to kick 0
    setPlayerStorageValue(cid, 42352, 0) -- is not in arena
	
		-- Set Client XP Gain Rate
	if Game.getStorageValue(GlobalStorage.XpDisplayMode) > 0 then
		displayRate = Game.getExperienceStage(player:getLevel())
		else
		displayRate = 1
	end
	local staminaMinutes = player:getStamina()
	local storeBoost = player:getExpBoostStamina()
	if staminaMinutes > 2400 and player:isPremium() and storeBoost > 0 then
		player:setBaseXpGain(displayRate*2*100) -- Premium + Stamina boost + Store boost
	elseif staminaMinutes > 2400 and player:isPremium() and storeBoost <= 0 then
		player:setBaseXpGain(displayRate*1.5*100) -- Premium + Stamina boost
	elseif staminaMinutes <= 2400 and staminaMinutes > 840 and player:isPremium() and storeBoost > 0 then
		player:setBaseXpGain(displayRate*1.5*100) -- Premium + Store boost
	elseif staminaMinutes > 840 and storeBoost > 0 then
		player:setBaseXpGain(displayRate*1.5*100) -- FACC + Store boost
	elseif staminaMinutes <= 840 and storeBoost > 0 then
		player:setBaseXpGain(displayRate*1*100) -- ALL players low stamina + Store boost
	elseif staminaMinutes <= 840 then
		player:setBaseXpGain(displayRate*0.5*100) -- ALL players low stamina
	end

	if player:getClient().version > 1110 then
		local worldTime = getWorldTime()
		local hours = math.floor(worldTime / 60)
		local minutes = worldTime % 60
		player:sendTibiaTime(hours, minutes)
	end
	]]--

	return true
end
