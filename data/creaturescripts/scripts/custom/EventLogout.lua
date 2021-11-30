function onLogout(player)

	if player:getStorageValue(Storage.events) > 0 then
		player:sendCancelMessage("You can not logout in event!")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	return true
end
