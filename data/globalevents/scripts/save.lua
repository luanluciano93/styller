local function cleanServer()
	cleanMap()
	saveServer()
	broadcastMessage("Clean map completed and the next clean at on 2 hours.", MESSAGE_STATUS_CONSOLE_RED)
end

function onThink(interval)
	broadcastMessage("Cleaning map in 1 minute.", MESSAGE_STATUS_WARNING)
	addEvent(cleanServer, 60000)
	return true
end
