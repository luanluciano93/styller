function onSay(player, words, param)

	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return true
	end

	----------------------------------------------------------------------

	----------------------------------------------------------------------
	return true
end
