local function cleanServer()
	cleanMap()
	saveServer()
	Game.broadcastMessage("Clean map completed and the next clean at on 3 hours.", MESSAGE_STATUS_CONSOLE_RED)
end

function onTime(interval)
	Game.broadcastMessage("Cleaning map in 1 minute.", MESSAGE_STATUS_WARNING)
	addEvent(cleanServer, 60000)
	return true
end
