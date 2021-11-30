-- [level] = type = "item", id = {ITEM_ID, QUANTIDADE}, msg = "MENSAGEM"},
-- [level] = type = "bank", id = {QUANTIDADE, 0}, msg = "MENSAGEM"},
-- [level] = type = "addon", id = {ID_ADDON_FEMALE, ID_ADDON_MALE}, msg = "MENSAGEM"},

local config = {
	[20] = {type = "bank", id = {20000, 0}, msg = "Congratulations, you have reached level 50 and received 20000 gold coins in your bank!"},
	[300] = {type = "item", id = {9693, 1}, msg = "Congratulations, you have reached level 300 and received an addon doll."}
}

function onAdvance(player, skill, oldLevel, newLevel)

	if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
		return true
	end

	for k, v in pairs(config) do
		if newLevel >= k then
			if player:getStorageValue(Storage.levelReward) < k then
				if v.type == "item" then	
					player:addItem(v.id[1], v.id[2])
				elseif v.type == "bank" then
					player:setBankBalance(player:getBankBalance() + v.id[1])
				elseif v.type == "addon" then
					player:addOutfitAddon(v.id[1], 3)
					player:addOutfitAddon(v.id[2], 3)
				else
					return false
				end

				player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, v.msg)
				player:setStorageValue(Storage.levelReward, k)
				player:save()

				break
			end
		end
	end
	return true
end
