local pos = {   
	DEMON_OAK_POSITION = Position(877, 1036, 7),
	DEMON_OAK_KICK_POSITION = Position(877, 1025, 7),
	DEMON_OAK_ENTER_POSITION = Position(877, 1031, 7)
}

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if #Game.getSpectators(pos.DEMON_OAK_POSITION, false, true, 9, 9, 6, 6) == 0 then
		if player:getStorageValue(Storage.demonOak.progress) >= 2 then
			player:teleportTo(pos.DEMON_OAK_KICK_POSITION)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			return true
		end

		if player:getLevel() < 120 then
			player:say("LEAVE LITTLE FISH, YOU ARE NOT WORTH IT!", TALKTYPE_MONSTER_YELL, false, player, pos.DEMON_OAK_POSITION)
			player:teleportTo(pos.DEMON_OAK_KICK_POSITION)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			return true
		end

		if player:getItemCount(8293) == 0 then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'Go talk with Oldrak and get the hallowed axe to kill The Demon Oak.')
			player:teleportTo(pos.DEMON_OAK_KICK_POSITION)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			return true
		end

		if player:getStorageValue(Storage.demonOak.progress) < 1 then
			if not player:removeItem(10305, 1) then
				player:say("You need a holy icon to enter.!", TALKTYPE_MONSTER_YELL, false, player, pos.DEMON_OAK_KICK_POSITION)
				player:teleportTo(pos.DEMON_OAK_KICK_POSITION)
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				return true
			else
				player:setStorageValue(Storage.demonOak.progress, 1)
			end
		end

		player:teleportTo(pos.DEMON_OAK_ENTER_POSITION)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:say("I AWAITED YOU! COME HERE AND GET YOUR REWARD!", TALKTYPE_MONSTER_YELL, false, player, pos.DEMON_OAK_POSITION)
	else
		player:teleportTo(pos.DEMON_OAK_KICK_POSITION)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end

	return true
end