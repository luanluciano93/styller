function onLogin(player)

	if not player:isPremium() then
		if player:getStorageValue(Storage.premiumCheck) == 1 then
			player:teleportTo(player:getTown():getTemplePosition())
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:setStorageValue(Storage.premiumCheck, 0)
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Your premium account time is over.")
			
			-- check House in premium city
			local house = player:getHouse()
			if house then
				local cityPremiumId = CUSTOM.cityPremiumId
				if house:getTown():getId() == cityPremiumId then
					house:setOwnerGuid(0)
				end
			end
		end
	else
		player:setStorageValue(Storage.premiumCheck, 1)
	end

	return true
end
