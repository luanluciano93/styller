function onUse(player, item, fromPosition, target, toPosition, isHotkey)

	if player:getPremiumDays() <= 365 then
		player:addPremiumDays(30)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você recebeu 30 dias de premium account.")
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
		item:remove(1)
	else
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Você não pode adicionar mais que 365 dias de premium account.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	return false
end
