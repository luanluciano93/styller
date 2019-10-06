local BOSSES = {
	["thul"] = {storage = Storage.achievements.thul, achievement = 2}, -- Back into the Abyss
	["the old widow"] = {storage = Storage.achievements.theOldWidow, achievement = 3}, -- Choking on Her Venom
	["the many"] = {storage = Storage.achievements.theMany, achievement = 4}, -- One Less
	["the noxious spawn"] = {storage = Storage.achievements.theNoxiousSpawn, achievement = 5}, -- Hissing Downfall
	["stonecracker"] = {storage = Storage.achievements.stonecracker, achievement = 6}, -- Just Cracked Me Up!
	["leviathan"] = {storage = Storage.achievements.leviathan, achievement = 7} -- The Drowned Sea God
}

function onKill(creature, target)
	if not creature:isPlayer() then
		return true
	end

	if not target:isMonster() then
		return true
	end

	local boss = BOSSES[target:getName():lower()]
	if boss then
		if creature:getStorageValue(boss.storage) ~= 1 then
			creature:setStorageValue(boss.storage, 1)
			creature:addAchievement(boss.achievement)
		end
	end

	return true
end
