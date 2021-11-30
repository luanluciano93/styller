function onLogin(player)
	if player:getStorageValue(Storage.events) > 0 then
		player:setStorageValue(Storage.events, 0)
		player:teleportTo(player:getTown():getTemplePosition())
	end

	return true
end
