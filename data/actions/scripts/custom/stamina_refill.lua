local stamina_full = 42 -- horas (stamina full)

function onUse(player, item, fromPosition, target, toPosition, isHotkey)

	if player:getStamina() >= (stamina_full * 60) then
		player:sendCancelMessage("Your stamina is already full.")
	else
		player:setStamina(stamina_full * 60)
		player:sendTextMessage(MESSAGE_INFO_DESCR, "Your stamina has been refilled.")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		item:remove(1)
	end

	return true
end
