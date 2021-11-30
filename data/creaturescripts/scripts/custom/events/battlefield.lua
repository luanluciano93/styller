dofile('data/lib/custom/battlefield.lua')

local function battlefieldWinners(team)
	for _, winner in ipairs(Game.getPlayers()) do
		if winner:getStorageValue(Storage.events) == team then	
			winner:sendTextMessage(MESSAGE_INFO_DESCR, "Congratulations, your team won the battlefield event.")
			winner:addItem(BATTLEFIELD.reward[1], BATTLEFIELD.reward[2])
			battlefieldRemovePlayer(winner:getGuid())
		end
	end

	Game.broadcastMessage("The BattleEvent is finish, team ".. BATTLEFIELD.teamsBattlefield[team].color .." win.", MESSAGE_STATUS_WARNING)
	battlefieldCheckGate()

	print("> BattleField Event was finished.")

	addEvent(checkFinishEvent, 3000)
end

local function checkFinishEvent()
	for _, player in ipairs(Game.getPlayers()) do
		if player:getStorageValue(Storage.events) == 5 or player:getStorageValue(Storage.events) == 6 then
			battlefieldRemovePlayer(player:getGuid())
		end
	end
end

function onPrepareDeath(player, killer)

	if killer then
		local team = player:getStorageValue(Storage.events)
		if team == 5 or team == 6 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "You are dead in Battlefield Event!")
			battlefieldRemovePlayer(player:getGuid())

			if battlefieldCountPlayers(team) == 0 then
				battlefieldWinners((team == 5) and 6 or 5)
			else
				battlefieldMsg()
			end
		end
	end

	return false
end
