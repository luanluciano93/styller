dofile('data/lib/custom/styllerConfig.lua')

local freeBlessMaxLevel = STYLLER.freeBlessMaxLevel

function onLogin(player)

	if player:getLevel() < freeBlessMaxLevel then
		player:addBlessing(32) ----------- bit representation
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, 'You received free blessings for you to be level less than ' .. freeBlessMaxLevel .. '!')
	end
	return true
end
