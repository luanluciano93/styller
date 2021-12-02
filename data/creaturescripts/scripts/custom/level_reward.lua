-- [level] = type = "item", id = {ITEM_ID, QUANTIDADE}, msg = "MENSAGEM"},
-- [level] = type = "bank", id = {QUANTIDADE, 0}, msg = "MENSAGEM"},
-- [level] = type = "addon", id = {ID_ADDON_FEMALE, ID_ADDON_MALE}, msg = "MENSAGEM"},

local config = {
	[{1,5}] = {
		[13] = {type = "item", id = {2191, 1}, msg = "Congratulations, you have reached level 13 and received a wand of dragonbreath."},
		[19] = {type = "item", id = {2188, 1}, msg = "Congratulations, you have reached level 19 and received a wand of decay."},
		[20] = {type = "item", id = {2160, 2}, msg = "Congratulations, you have reached level 20 and received 20000 gold coins."},
		[22] = {type = "item", id = {8921, 1}, msg = "Congratulations, you have reached level 22 and received a wand of draconia."},
		[26] = {type = "item", id = {2189, 1}, msg = "Congratulations, you have reached level 26 and received a wand of cosmic energy."},
		[33] = {type = "item", id = {2187, 1}, msg = "Congratulations, you have reached level 33 and received a wand of inferno."},
		[37] = {type = "item", id = {8920, 1}, msg = "Congratulations, you have reached level 37 and received a wand of starstorm."},
		[42] = {type = "item", id = {8922, 1}, msg = "Congratulations, you have reached level 42 and received a wand of voodoo."}
	},
	[{2,6}] = {
		[13] = {type = "item", id = {2186, 1}, msg = "Congratulations, you have reached level 13 and received a moonlight rod."},
		[19] = {type = "item", id = {2185, 1}, msg = "Congratulations, you have reached level 19 and received a necrotic rod."},
		[20] = {type = "item", id = {2160, 2}, msg = "Congratulations, you have reached level 20 and received 20000 gold coins."},
		[22] = {type = "item", id = {8911, 1}, msg = "Congratulations, you have reached level 22 and received a northwind rod."},
		[26] = {type = "item", id = {2181, 1}, msg = "Congratulations, you have reached level 26 and received a terra rod."},
		[33] = {type = "item", id = {2183, 1}, msg = "Congratulations, you have reached level 33 and received a hailstorm rod."},
		[37] = {type = "item", id = {8912, 1}, msg = "Congratulations, you have reached level 37 and received a springsprout rod."},
		[42] = {type = "item", id = {8910, 1}, msg = "Congratulations, you have reached level 42 and received a underworld rod."}
	},
	[{3,7}] = {
		[20] = {type = "item", id = {2160, 2}, msg = "Congratulations, you have reached level 20 and received 20000 gold coins."},
		[21] = {type = "item", id = {3965, 1}, msg = "Congratulations, you have reached level 21 and received a hunting spear."},
		[25] = {type = "item", id = {7378, 1}, msg = "Congratulations, you have reached level 25 and received a royal spear."},
		[42] = {type = "item", id = {7367, 1}, msg = "Congratulations, you have reached level 42 and received a enchanted spear."},
		[80] = {type = "item", id = {7368, 1}, msg = "Congratulations, you have reached level 80 and received a assassin star."}
	},
	[{4,8}] = {
		[20] = {type = "item", id = {2160, 2}, msg = "Congratulations, you have reached level 20 and received 20000 gold coins."},
		[21] = {type = "item", id = {2423, 1}, msg = "Congratulations, you have reached level 21 and received a clerical mace."},
		[22] = {type = "item", id = {2429, 1}, msg = "Congratulations, you have reached level 22 and received a barbarian axe."},
		[23] = {type = "item", id = {7385, 1}, msg = "Congratulations, you have reached level 23 and received a crimson sword."},
		[30] = {type = "item", id = {2436, 1}, msg = "Congratulations, you have reached level 30 and received a skull staff."},
		[31] = {type = "item", id = {3962, 1}, msg = "Congratulations, you have reached level 31 and received a beastslayer axe."},
		[32] = {type = "item", id = {2407, 1}, msg = "Congratulations, you have reached level 32 and received a bright sword."},
		[40] = {type = "item", id = {3961, 1}, msg = "Congratulations, you have reached level 40 and received a lich staff."},
		[41] = {type = "item", id = {7419, 1}, msg = "Congratulations, you have reached level 41 and received a dreaded cleaver."},
		[42] = {type = "item", id = {7404, 1}, msg = "Congratulations, you have reached level 42 and received a assassin dagger."},
		[50] = {type = "item", id = {7409, 1}, msg = "Congratulations, you have reached level 50 and received a northern star."},
		[51] = {type = "item", id = {7411, 1}, msg = "Congratulations, you have reached level 51 and received a ornamented axe."},
		[52] = {type = "item", id = {7383, 1}, msg = "Congratulations, you have reached level 52 and received a relic sword."}
	}
}

function onAdvance(player, skill, oldLevel, newLevel)

	if skill ~= SKILL_LEVEL or newLevel <= oldLevel then
		return true
	end

	for vocationConfig, valueVocation in pairs(config) do
		if table.contains(vocationConfig, player:getVocation():getId()) then
			for levelConfig, valueLevel in pairs(valueVocation) do		
				if newLevel >= levelConfig and player:getStorageValue(Storage.levelReward) < levelConfig then
						
					if valueLevel.type == "item" then	
						player:addItem(valueLevel.id[1], valueLevel.id[2])
					elseif valueLevel.type == "bank" then
						player:setBankBalance(player:getBankBalance() + valueLevel.id[1])
					elseif valueLevel.type == "addon" then
						player:addOutfitAddon(valueLevel.id[1], 3)
						player:addOutfitAddon(valueLevel.id[2], 3)
					else
						return false
					end

					player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, valueLevel.msg)
					player:setStorageValue(Storage.levelReward, levelConfig)
					player:save()

					break
				end
			end
		end
	end
	return true
end
