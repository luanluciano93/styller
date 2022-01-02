--[[
CREATE TABLE IF NOT EXISTS `lottery` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `item_id` smallint unsigned NOT NULL,
  `item_count` smallint unsigned NOT NULL DEFAULT '1',
  `item_name` varchar(255) NOT NULL,
  `addData` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
]]--

local config = STYLLER.lottery

function onTime(interval)
	local playersOnline = Game.getPlayers()
    local rewards = config.rewards

	if #playersOnline > 0 and #rewards > 0 then

		local n = math.random(1, #rewards)
		local itemid, count = rewards[n][1], rewards[n][2]

		local item = ItemType(itemid)
		if not item then
			print("[LOTTERY SYSTEM] ItemType ".. itemid .." invalid.")
			return true
		end

		if not item:isStackable() then
			count = 1
		end

		local itemIdCheck = item:getId()
		if not itemIdCheck then
			print("[LOTTERY SYSTEM] itemID ".. itemIdCheck .." invalid.")
			return true
		end

		if itemIdCheck == 0 then
			print("[LOTTERY SYSTEM] itemID invalid.")
			return true
		end

		local players = {}
		for _, online in ipairs(Game.getPlayers()) do
			if not online:getGroup():getAccess() then
				table.insert(players, online)
			end
		end

		if #players < 1 then
			print("[LOTTERY SYSTEM] No valid player.")
			return true
		end

		local winner = players[math.random(#players)]
		if not winner then
			print("[LOTTERY SYSTEM] player invalid.")
			return true
		end

		if winner:addItem(itemid, count) then
			local itemArticle = (count > 1 and count or (item:getArticle() ~= "" and item:getArticle() or ""))
			local itemPluralName = (count > 1 and item:getPluralName() or item:getName())

			Game.broadcastMessage("[LOTTERY SYSTEM] " .. winner:getName() .. " won " .. itemArticle .. " " .. itemPluralName .. "! Congratulations! (Next lottery in " .. config.interval .. ")", MESSAGE_STATUS_WARNING)

			if config.website then
				local playerId = winner:getGuid()
				db.query("INSERT INTO `lottery` (`id`, `player_id`, `item_id`, `item_count`, `item_name`, `addData`) VALUES (NULL, ".. playerId ..", ".. itemIdCheck ..", ".. count .. ", ".. db.escapeString(itemPluralName) ..", ".. os.time() ..")")
			end
		end
    end

    return true
end
