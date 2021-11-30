dofile('data/lib/custom/task.lua')

function onKill(player, target)
	if target:isPlayer() or target:getMaster() then
		return true
	end

	local targetName, startedTasks, taskId = target:getName():lower(), player:getStartedTasks()
	for i = 1, #startedTasks do
		taskId = startedTasks[i]
		if table.contains(tasks[taskId].creatures, targetName) then
			local killAmount = player:getStorageValue(Storage.task.killsTaskBase + taskId)
			local killsRequired = tasks[taskId].killsRequired
			if killAmount < killsRequired then
				player:setStorageValue(Storage.task.killsTaskBase + taskId, killAmount + 1)
				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, '[Task System] You kill ['..player:getStorageValue(Storage.task.killsTaskBase + taskId)..'/'..killsRequired..'] '..target:getName()..'.')
			end
		end
	end
	return true
end
