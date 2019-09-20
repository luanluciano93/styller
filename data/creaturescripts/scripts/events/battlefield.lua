dofile('data/lib/custom/battlefield.lua')

local function battlefieldWinners(team)
	for _, winner in ipairs(Game.getPlayers()) do
		if winner:getStorageValue(Storage.events) == team then	
			winner:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations, your team won the battlefield event.")
			winner:addItem(BATTLEFIELD.REWARD[1], BATTLEFIELD.REWARD[2])
			battlefieldRemovePlayer(winner:getGuid())
		end
	end

	Game.broadcastMessage("The BattleEvent is finish, team ".. BATTLEFIELD.TEAMS[team].color .." win.", MESSAGE_STATUS_WARNING)
	battlefieldCheckGate()

	print("> BattleField Event was finished.")

	addEvent(checkFinishEvent, 3000)
end

local function checkFinishEvent()
	for _, p in ipairs(Game.getPlayers()) do
		if p:getStorageValue(Storage.events) > 0 then
			battlefieldRemovePlayer(p:getGuid())
		end
	end
	Game.setStorageValue(BATTLEFIELD.TOTAL_PLAYERS, 0)
end

function onPrepareDeath(player, killer)

	local team = player:getStorageValue(Storage.events)
	if team > 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are dead in Battlefield Event!")
		battlefieldRemovePlayer(player:getGuid())

		if battlefieldCountPlayers(team) == 0 then
			battlefieldWinners((team == 1) and 2 or 1)
		else
			battlefieldMsg()
		end
	end

	return false
end
