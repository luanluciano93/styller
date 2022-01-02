-- !war invite, enemyGuild, frags(x), money(x), timeDays(x) [0]
-- !war accept, enemyGuild (aceita um convite recebido [1])
-- !war reject,enemyGuild (cancela um convite recebido [2])
-- !war cancel, enemyGuild (cancela um convite enviado [3])
-- !war end, enemyGuild  (se voce for quem enviouo convite encerra a guerra [5] ou se for quem recebeu o convite ela muda para pedido de encerramento [4])
-- !war finish, enemyGuild (se voce for o lider e tiver pedido de encerramento da outra guild encerra a guerra [5])
-- !war balance
-- !war deposity, money
-- !war withdraw, money

local frags = STYLLER.warSystem.frags
local timeDaysMax = STYLLER.warSystem.daysMaxToInviteWar

local function getEnemyId(enemyName)
	local resultId = db.storeQuery("SELECT `id` FROM `guilds` WHERE `name` = " .. db.escapeString(enemyName))
	if resultId == false then
		return false
	end

	local enemyId = result.getNumber(resultId, "id")
	result.free(resultId)
	return enemyId
end

local function getEnemyName(enemyId)
	local resultId = db.storeQuery("SELECT `name` FROM `guilds` WHERE `id` = " .. enemyId)
	if resultId == false then
		return false
	end

	local enemyName = result.getString(resultId, "name")
	result.free(resultId)
	return enemyName
end

local function isValidMoneyGuild(value)
	if not value then
		return false
	end
	return (value > 0 and value <= 99999999999999)
end

function onSay(player, words, param)

	local guild = player:getGuild()
	if not guild then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local guildId = guild:getId()
	if not guildId then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD WAR] You need to be in a guild in order to execute this command.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local split = param:splitTrimmed(",")
	if not split[1] then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD WAR] Insufficient parameters. Guild War commands:" .. "\n"
			.. "!war invite, enemyGuild, frags, money, timeDays" .. "\n"
			.. "!war accept, enemyGuild" .. "\n"
			.. "!war reject,enemyGuild" .. "\n"
			.. "!war cancel, enemyGuild" .. "\n"
			.. "!war end, enemyGuild" .. "\n"
			.. "!war finish, enemyGuild" .. "\n"
			.. "!war balance" .. "\n"
			.. "!war deposity, money" .. "\n"
			.. "!war withdraw, money")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
		return false
	end

	if not table.contains({"balance", "withdraw", "deposity", "invite", "accept", "reject", "cancel", "end", "finish"}, split[1]) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD WAR] Invalid parameters. Guild War commands:" .. "\n"
			.. "!war invite, enemyGuild, frags, money, timeDays" .. "\n"
			.. "!war accept, enemyGuild" .. "\n"
			.. "!war reject,enemyGuild" .. "\n"
			.. "!war cancel, enemyGuild" .. "\n"
			.. "!war end, enemyGuild" .. "\n"
			.. "!war finish, enemyGuild" .. "\n"
			.. "!war balance" .. "\n"
			.. "!war deposity, money" .. "\n"
			.. "!war withdraw, money")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)	
		player:getPosition():sendMagicEffect(CONST_ME_POFF)		
		return false
	end

	if split[1] == "balance" then

		local resultId = db.storeQuery('SELECT `name`, `balance` FROM `guilds` WHERE `id` = ' .. guildId)
		if not resultId then
			return false
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Current balance of guild ' .. result.getString(resultId, "name") .. ' is: ' .. result.getNumber(resultId, "balance") .. ' golds coins.')
		result.free(resultId)
		return false
	end

	if not split[2] then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "[GUILD WAR] Insufficient parameters. Guild War commands:" .. "\n"
			.. "!war invite, enemyGuild, frags, money, timeDays" .. "\n"
			.. "!war accept, enemyGuild" .. "\n"
			.. "!war reject,enemyGuild" .. "\n"
			.. "!war cancel, enemyGuild" .. "\n"
			.. "!war end, enemyGuild" .. "\n"
			.. "!war finish, enemyGuild" .. "\n"
			.. "!war balance" .. "\n"
			.. "!war deposity, money" .. "\n"
			.. "!war withdraw, money")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end	

	if player:getGuildLevel() < 3 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You need to be the guild leader to execute this command.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local money = 0
	if table.contains({"withdraw", "deposity"}, split[1]) then

		local money = tonumber(split[2])
		if not money then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Invalid amount of money specified.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end		

		if not isValidMoneyGuild(money) then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Invalid amount of money specified.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if split[1] == "withdraw" then

			local resultId = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
			if resultId == false then
				return false
			end

			local balance = result.getNumber(resultId, "balance")
			result.free(resultId)

			if money > balance then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] The balance is too low for such amount.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not db.query('UPDATE `guilds` SET `balance` = `balance` - '.. money ..' WHERE `id` = ' .. guildId .. ' LIMIT 1;') then
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if player:addMoney(money) then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You have just picked '.. money ..' gold coins from your guild balance.')
				return false
			end
	
		elseif split[1] == 'deposity' then

			if player:getMoney() < money then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You don\'t have enough money.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not player:removeMoney(money) then
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			db.query('UPDATE `guilds` SET `balance` = `balance` + ' .. money .. ' WHERE `id` = ' .. guildId .. ' LIMIT 1;')
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You have deposited '.. money ..' gold coins to your guild balance.')
		end
		
		return false
	end
	
	local enemy = getEnemyId(split[2])
	if not enemy then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Guild '.. split[2] ..' does not exists.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local enemyName = getEnemyName(enemy)
	local guildName = guild:getName()

	if enemy == guildId or enemyName == guildName then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You cannot perform war action on your own guild.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if table.contains({"accept", "reject", "cancel"}, split[1]) then
		local query = "`guild1` = " .. enemy .. " AND `guild2` = " .. guildId
		if split[1] == "cancel" then
			query = "`guild1` = " .. guildId .. " AND `guild2` = " .. enemy
		end

		local resultId = db.storeQuery("SELECT `id`, `started`, `ended`, `payment` FROM `guild_wars` WHERE " .. query .. " AND `status` = 0")
		if resultId == false then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Currently there\'s no pending invitation for a war with '.. enemyName .. '.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if split[1] == "accept" then
			local _tmp = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
			local state = result.getNumber(_tmp, "balance") < result.getNumber(resultId, "payment")
			result.free(_tmp)

			if state then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Your guild balance is too low to accept this invitation.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. result.getNumber(resultId, "payment") .. " WHERE `id` = " .. guildId)
		end

		query = "UPDATE `guild_wars` SET "

		local message = "accepted " .. enemyName .. " invitation to war."
		if split[1] == "reject" then
			query = query .. "`ended` = " .. os.time() .. ", `status` = 2"
			message = "rejected " .. enemyName .. " invitation to war."
		elseif split[1] == "cancel" then
			query = query .. "`ended` = " .. os.time() .. ", `status` = 3"
			message = "canceled invitation to a war with " .. enemyName .. "."
		else
			query = query .. "`started` = " .. os.time() .. ", `ended` = " .. (result.getNumber(resultId, "ended") > 0 and (os.time() + ((result.getNumber(resultId, "started") - result.getNumber(resultId, "ended")) / 86400)) or 0) .. ", `status` = 1"
		end

		query = query .. " WHERE `id` = " .. result.getNumber(resultId, "id")
		result.free(resultId)
		db.query(query)

		Game.broadcastMessage(guildName .. " has " .. message, MESSAGE_EVENT_ADVANCE)
		print("> Broadcasted message: \"" .. guildName .. " has " .. message .. "\".")
		
		return false

	elseif split[1] == "invite" then
		local invitationDenied, resultId = "", db.storeQuery("SELECT `guild1`, `status` FROM `guild_wars` WHERE `guild1` IN (" .. guildId .. "," .. enemy .. ") AND `guild2` IN (" .. enemy .. "," .. guildId .. ") AND `status` IN (0, 1)")
		if resultId ~= false then
			if result.getNumber(resultId, "status") == 0 then
				if result.getNumber(resultId, "guild1") == guildId then
					invitationDenied = "You have already invited " .. enemyName .. " to war."
				else
					invitationDenied = enemyName .. " have already invited you to war."
				end
			else
				invitationDenied = "You are already on a war with " .. enemyName .. "."
			end
			result.free(resultId)
		end

		if invitationDenied ~= "" then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] ' .. invitationDenied)
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local fragLimit, fragsSplit = 0, tonumber(split[3])
		if not fragsSplit then
			fragLimit = frags.standard
		else
			fragLimit = math.max(frags.min, math.min(frags.max, fragsSplit))
		end

		local payment = 0
		payment = tonumber(split[4])
		if payment then
			payment = math.floor(payment)

			if (payment < 0 or payment > 99999999999999) then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Invalid amount of money specified.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local resultId = db.storeQuery("SELECT `balance` FROM `guilds` WHERE `id` = " .. guildId)
			local state = result.getNumber(resultId, "balance") < payment
			result.free(resultId)
			if state then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Your guild balance is too low for such payment.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
			db.query("UPDATE `guilds` SET `balance` = `balance` - " .. payment .. " WHERE `id` = " .. guildId)
		else
			payment = 0
		end

		local begining, ending, days = os.time(), tonumber(split[5]), 0
		if ending and ending ~= 0 then
			if ending > timeDaysMax then
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Invalid amount of days specified. The maximum value for days of war is ' .. timeDaysMax ..' days.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
			days = ending
			ending = begining + (ending * 86400)
		else
			ending = 0
		end

		db.query("INSERT INTO `guild_wars` (`guild1`, `guild2`, `name1`, `name2`, `started`, `ended`, `frags`, `payment`) VALUES (" .. guildId .. ", " .. enemy .. ", " .. db.escapeString(guildName) .. ", " .. db.escapeString(enemyName) .. ", " .. begining .. ", " .. ending .. ", " .. fragLimit .. ", " .. payment .. ");")
		db.query("INSERT INTO `znote_guild_wars` (`limit`) VALUES ('".. fragLimit .."');")

		local msgPayment = ""
		if payment > 0 then
			msgPayment = "betting " .. payment .. " golds "
		end
		
		local msgDays = ""
		if days > 0 then
			msgDays = "with a duration of " .. days .. " day(s)"
		end		

		Game.broadcastMessage(guildName .. " has invited " .. enemyName .. " to war till " .. fragLimit .. " frags " .. msgPayment .. "" .. msgDays .. ".", MESSAGE_EVENT_ADVANCE)
		print("> [GUILD WAR] " .. guildName .. " has invited " .. enemyName .. " to war till " .. fragLimit .. " frags " .. msgPayment .."" .. msgDays .. ".")

		return false

	elseif table.contains({"end", "finish"}, split[1]) then
		local status = (split[1] == "end" and 1 or 4)
		local resultId = db.storeQuery("SELECT `id` FROM `guild_wars` WHERE `guild1` = " .. guildId .. " AND `guild2` = " .. enemy .. " AND `status` = " .. status)
		if resultId ~= false then
			local query = "UPDATE `guild_wars` SET `ended` = " .. os.time() .. ", `status` = 5 WHERE `id` = " .. result.getNumber(resultId, "id")
			result.free(resultId)
			db.query(query)

			Game.broadcastMessage(guildName .. " has " .. (status == 4 and "mend fences" or "ended up a war") .. " with " .. enemyName .. ".", MESSAGE_EVENT_ADVANCE)
			print("> Broadcasted message: \"" .. guildName .. " has " .. (status == 4 and "mend fences" or "ended up a war") .. " with " .. enemyName .. ".")

			return false
		end

		if status == 4 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Currently there\'s no pending war truce from '.. enemyName .. '.')
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local resultId = db.storeQuery("SELECT `id`, `ended` FROM `guild_wars` WHERE `guild1` = " .. enemy .. " AND `guild2` = " .. guildId .. " AND `status` = 1")
		if resultId ~= false then
			if result.getNumber(resultId, "ended") > 0 then
				result.free(resultId)
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] You cannot request ending for war with '.. enemyName ..'.')
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local query = "UPDATE `guild_wars` SET `status` = 4, `ended` = " .. os.time() .. " WHERE `id` = " .. result.getNumber(resultId, "id")
			result.free(resultId)
			db.query(query)

			Game.broadcastMessage(guildName .. " has signed an armstice declaration on a war with " .. enemyName .. ".", MESSAGE_EVENT_ADVANCE)
			print("> Broadcasted message: \"" .. guildName .. " has signed an armstice declaration on a war with " .. enemyName .. ".")
		
			return false
		end

		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, '[GUILD WAR] Currently there\'s no active war with '.. enemyName .. '.')
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end