local table = 
{
	-- [level] = type = "item", id = {ITEM_ID, QUANTIDADE}, msg = "MENSAGEM"},
	-- [level] = type = "bank", id = {QUANTIDADE, 0}, msg = "MENSAGEM"},
	-- [level] = type = "addon", id = {ID_ADDON_FEMALE, ID_ADDON_MALE}, msg = "MENSAGEM"},

	-- [20] = {type = "item", id = {2160, 2}, msg = "Voce ganhou 2 crystal coins por alcancar o level 20!"},
	[30] = {type = "bank", id = {50000, 0}, msg = "Congratulations, you have reached level 50 and received 50000﻿ gold coints﻿ in your bank!"},
	-- [40] = {type = "addon", id = {136, 128}, msg = "Voce ganhou o addon citizen﻿ full por alcancar o level 40!"},
	[300] = {type = "item", id = {9693, 1}, msg = "Congratulations, you have reached level 300 and received an addon doll!"}
	-- pure energy )refinaldor
}

function onAdvance(player, skill, oldLevel, newLevel)

	if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
		return true
	end

	for level, _ in pairs(table) do
		if newLevel >= level and player:getStorageValue(Storage.levelReward) < level then
			if table[level].type == "item" then	
				player:addItem(table[level].id[1], table[level].id[2])
			elseif table[level].type == "bank" then
				if player:getBankBalance﻿() == nil then
					player:setBankBalance﻿(table[level].id[1])
				else
					player:setBankBalance﻿(player:getBankBalance﻿() + table[level].id[1])
				end
			elseif table[level].type == "addon" then
				player:addOutfitAddon(table[level].id[1], 3)
				player:addOutfitAddon(table[level].id[2], 3)
			else
				return false
			end

			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, table[level].msg)
			player:setStorageValue(Storage.levelReward, level)
			player:save﻿()
		end
	end

	return true
end