local function cleanServer()
	cleanMap()
	saveServer()
	Game.broadcastMessage("Clean map completed and the next clean at on 3 hours.", MESSAGE_STATUS_CONSOLE_RED)
end

function onTime(interval)
	Game.broadcastMessage("Cleaning map in 3 minutes.", MESSAGE_STATUS_WARNING)
	addEvent(cleanServer, 180 * 1000)
	return true
end
