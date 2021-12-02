dofile('data/lib/custom/battlefield.lua')

function onLogin(player)
	if player:getStorageValue(BATTLEFIELD.storage) > 0 then
		player:setStorageValue(BATTLEFIELD.storage, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end
	return true
end

function onLogout(player)
	if player:getStorageValue(BATTLEFIELD.storage) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end
	return true
end

function battlefield_removeAllPlayers()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(BATTLEFIELD.storage) > 0 then
			battlefield_removePlayer(player:getGuid())
		end
	end
end

local function battlefield_winners(team)
	for _, winner in ipairs(Game.getPlayers()) do
		if winner:getStorageValue(BATTLEFIELD.storage) == team then	
			winner:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations, your team won the battlefield event.")
			winner:addItem(BATTLEFIELD.reward[1], BATTLEFIELD.reward[2])
			battlefield_removePlayer(winner:getGuid())
		end
	end

	Game.broadcastMessage("The BattleEvent is finish, team ".. BATTLEFIELD.teamsBattlefield[team].color .." win.", MESSAGE_STATUS_WARNING)
	battlefield_checkGate()

	print(">>> BattleField Event was finished.")

	addEvent(battlefield_removeAllPlayers, 3000)
end

function onPrepareDeath(player, killer)
	if killer then
		local team = player:getStorageValue(BATTLEFIELD.storage)
		if team > 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are dead in battlefield event!")
			battlefield_removePlayer(player:getGuid())

			if battlefield_totalPlayersTeam(team) == 0 then
				battlefield_winners((team == 1) and 2 or 1)
			else
				battlefield_msg()
			end
		end
	end
	return false
end
