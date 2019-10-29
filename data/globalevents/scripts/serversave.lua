local function serverSave()
	Game.setGameState(GAME_STATE_SHUTDOWN)
end

local function secondServerSaveWarning()
	Game.broadcastMessage("Server is saving game in one minute. Please logout.", MESSAGE_STATUS_WARNING)
	saveServer()
	addEvent(serverSave, 60000)
end

local function firstServerSaveWarning()
	Game.broadcastMessage("Server is saving game in 3 minutes. Please logout.", MESSAGE_STATUS_WARNING)
	addEvent(secondServerSaveWarning, 120000)
end

function onTime(interval)
	Game.broadcastMessage("Server is saving game in 5 minutes. Please logout.", MESSAGE_STATUS_WARNING)
	addEvent(firstServerSaveWarning, 120000)
	return true
end