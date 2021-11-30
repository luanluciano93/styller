function onSay(player, words, param)

	local outfits =
	{
		--[outfit] = {id_female, id_male}
		["citizen"] = {136, 128},
		["hunter"] = {137, 129},
		-- ["mage"] = {138, 130},
		["knight"] = {139, 131},
		["nobleman"] = {140, 132}, ["noblewoman"] = {140, 132},
		["summoner"] = {141, 133},
		["warrior"] = {142, 134},
		["barbarian"] = {147, 143},
		["druid"] = {148, 144},
		["wizard"] = {149, 145},
		["oriental"] = {150, 146},
		["pirate"] = {155, 151},
		["assassin"] = {156, 152},
		["beggar"] = {157, 153},
		["shaman"] = {158, 154},
		["norseman"] = {252, 251}, ["norsewoman"] = {252, 251},
		["nightmare"] = {269, 268},
		["jester"] = {270, 273},
		["brotherhood"] = {279, 278},
		-- ["demonhunter"] = {288, 289},
		["yalaharian"] = {324, 325},
		["warmaster"] = {336, 335},
		["wayfarer"] = {366, 367}
	}

	local addondoll_id = 9693

	if player:getExhaustion() <= 0 then
		player:setExhaustion(2)

		if param == "" then
			player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
			return false
		end

		if player:getItemCount(addondoll_id) > 0 then
			local word = outfits[string.lower(param)]
			if param ~= "" and word then
				if not player:removeItem(addondoll_id, 1) then
					print("[ERROR] TALKACTION: addon doll, FUNCTION: removeItem, PLAYER: "..player:getName())
				else
					player:addOutfitAddon(word[1], 3)
					player:addOutfitAddon(word[2], 3)
					player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Your full addon ".. string.lower(param) .." has been added!")
					player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
				end
			else
				player:sendCancelMessage("Invalid param specified.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
			end
		else
			player:sendCancelMessage("You don't have an addon doll!")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
	return false
end
