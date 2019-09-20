function onSay(player, words, param)
	if player:getExhaustion() <= 0 then
		player:setExhaustion(2)

		if not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
			player:sendCancelMessage("To buy amulet of loss you need to be in protection zone.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemWeight = ItemType(2173):getWeight()
		if player:getFreeCapacity() >= itemWeight then
			if not player:removeMoney(10000) then
				player:sendCancelMessage("You don't have 10000 gold coins to buy an amulet of loss.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			elseif not player:addItem(2173, 1) then
				print("[ERROR] TALKACTION: aol, FUNCTION: addItem, PLAYER: "..player:getName())
			else
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			end
		else
			player:sendCancelMessage("You don't have capacity.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
	return false
end
