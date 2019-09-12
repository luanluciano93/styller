function onSay(player, words, param)
	if player:getExhaustion(1000) <= 0 then
		player:setExhaustion(1000, 2)

		local text = {}
		local spells = {}
		for _, spell in ipairs(player:getInstantSpells()) do
			if spell.level ~= 0 then
				if spell.manapercent > 0 then
					spell.mana = spell.manapercent .. "%"
				end
				spells[#spells + 1] = spell
			end
		end

		table.sort(spells, function(a, b) return a.level < b.level end)

		local prevLevel = -1
		for i, spell in ipairs(spells) do
			if prevLevel ~= spell.level then
				if i == 1 then
					text[#text == nil and 1 or #text+1] = "Spells for Level "
				else
					text[#text+1] = "\nSpells for Level "
				end
				text[#text+1] = spell.level .. "\n"
				prevLevel = spell.level
			end
			text[#text+1] = spell.words .. " - " .. spell.name .. " : " .. spell.mana .. "\n"
		end

		player:showTextDialog(SPELL_BOOK, text)
	else
		player:sendTextMessage(MESSAGE_STATUS_SMALL, 'You\'re exhausted for: '..player:getExhaustion(1000)..' seconds.')
	end
end
