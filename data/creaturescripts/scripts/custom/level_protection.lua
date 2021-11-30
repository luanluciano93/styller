local freeBlessMaxLevel = 50

function onLogin(player)

	if player:getLevel() < freeBlessMaxLevel then
		local blessings = 0
		for i = 1, 5 do
			if not player:hasBlessing(i) then
				player:addBlessing(i, 1)
				blessings = blessings + 1
			end
		end

		if blessings > 0 then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'You received free blessings for you to be level less than ' .. freeBlessMaxLevel .. '!')
		end	
	end
	return true
end