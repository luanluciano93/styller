RANK_NONE = 0
RANK_JOIN = 1
RANK_HUNTSMAN = 2
RANK_RANGER = 3
RANK_BIGGAMEHUNTER = 4
RANK_TROPHYHUNTER = 5
RANK_ELITEHUNTER = 6

tasksByPlayer = 3

tasks = {
	[1] = {killsRequired = 600, raceName = "Quaras", level = {50, 999}, creatures = {"quara hydromancer", "quara predator", "quara constrictor", "quara mantassin", "quara pincher"}, rewards = {{type = "exp", value = {15000}},{type = "storage", value = {Storage.bossRoom.thul, 1}},{type = "points", value = {3}}}},
	[2] = {killsRequired = 500, raceName = "Giant Spiders", level = {50, 999}, creatures = {"giant spider"}, rewards = {{type = "exp", value = {20000}},{type = "storage", value = {Storage.bossRoom.theOldWidow, 1}},{type = "points", value = {3}}}},
	[3] = {killsRequired = 650, raceName = "Hydras", level = {100, 9999}, creatures = {"hydra"}, rewards = {{type = "exp", value = {30000}},{type = "storage", value = {Storage.bossRoom.theMany, 1}},{type = "points", value = {3}}}},
	[4] = {killsRequired = 800, raceName = "Serpent Spawns", level = {100, 9999}, creatures = {"serpent spawn"}, rewards = {{type = "exp", value = {30000}},{type = "storage", value = {Storage.bossRoom.theNoxiousSpawn, 1}},{type = "points", value = {4}}}},
	[5] = {killsRequired = 500, raceName = "Medusas", level = {100, 9999}, creatures = {"medusa"}, rewards = {{type = "exp", value = {40000}},{type = "points", value = {5}}}},
	[6] = {killsRequired = 700, raceName = "Behemoths", level = {100, 9999}, creatures = {"behemoth"}, rewards = {{type = "exp", value = {30000}},{type = "storage", value = {Storage.bossRoom.stonecracker, 1}},{type = "points", value = {4}}}},
	[7] = {killsRequired = 900, raceName = "Sea Serpents", level = {100, 9999}, creatures = {"sea serpent"}, rewards = {{type = "exp", value = {30000}},{type = "storage", value = {Storage.bossRoom.leviathan, 1}},{type = "points", value = {4}}}},
	[8] = {killsRequired = 1000, raceName = "Dragon Lords", level = {100, 9999}, creatures = {"dragon lord"}, rewards = {{type = "exp", value = {100000}},{type = "storage", value = {Storage.bossRoom.demodras, 1}},{type = "points", value = {4}}}},
	[9] = {killsRequired = 6666, raceName = "Demons", level = {130, 9999}, creatures = {"demon"}, rewards = {{type = "storage", value = {Storage.bossRoom.demons, 1}},{type = "points", value = {5}}}},
	
}

function Player.getTaskRank(self)
	return (self:getStorageValue(Storage.task.pointsTask) >= 100 and RANK_ELITEHUNTER 
	or self:getStorageValue(Storage.task.pointsTask) >= 70 and RANK_TROPHYHUNTER 
	or self:getStorageValue(Storage.task.pointsTask) >= 40 and RANK_BIGGAMEHUNTER 
	or self:getStorageValue(Storage.task.pointsTask) >= 20 and RANK_RANGER 
	or self:getStorageValue(Storage.task.pointsTask) >= 10 and RANK_HUNTSMAN 
	or self:getStorageValue(Storage.task.storageJoin) == 1 and RANK_JOIN 
	or RANK_NONE)
end

function Player.getTaskPoints(self)
	return math.max(self:getStorageValue(Storage.task.pointsTask), 0)
end

function getTaskByName(name, table)
	local t = (table and table or tasks)
	for k, v in pairs(t) do
		if v.name then
			if v.name:lower() == name:lower() then
				return k
			end
		else
			if v.raceName:lower() == name:lower() then
				return k
			end
		end
	end
	return false
end

function Player.getTasks(self)
	local canmake = {}
	local able = {}
	for k, v in pairs(tasks) do
		if self:getStorageValue(Storage.task.storageTaskBase + k) < 1 then
			able[k] = true
			if self:getLevel() < v.level[1] or self:getLevel() > v.level[2] then
				able[k] = false
			end
			if v.storage and self:getStorageValue(v.storage[1]) < v.storage[2] then
				able[k] = false
			end

			if v.rank then
				if self:getTaskRank() < v.rank then
					able[k] = false
				end
			end

			if v.premium then
				if not self:isPremium() then
					able[k] = false
				end
			end

			if able[k] then
				canmake[#canmake + 1] = k
			end
		end
	end
	return canmake
end

function Player.canStartTask(self, name, table)
	local v = ""
	local id = 0
	local t = (table and table or tasks)
	for k, i in pairs(t) do
		if i.name then
			if i.name:lower() == name:lower() then
				v = i
				id = k
				break
			end
		else
			if i.raceName:lower() == name:lower() then
				v = i
				id = k
				break
			end
		end
	end
	if v == "" then
		return false
	end
	if self:getStorageValue(Storage.task.storageTaskBase + id) > 0 then
		return false
	end
	if v.level and self:getLevel() < v.level[1] and self:getLevel() > v.level[2] then
		return false
	end
	if v.premium and not self:isPremium() then
		return false
	end
	if v.rank and self:getTaskRank() < v.rank then
		return false
	end
	if v.storage and self:getStorageValue(v.storage[1]) < v.storage then
		return false
	end
	return true
end

function Player.getStartedTasks(self)
	local tmp = {}
	for k, v in pairs(tasks) do
		if self:getStorageValue(Storage.task.storageTaskBase + k) > 0 and self:getStorageValue(Storage.task.storageTaskBase + k) < 2 then
			tmp[#tmp + 1] = k
		end
	end
	return tmp
end
