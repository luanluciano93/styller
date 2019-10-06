local achievements = {
	[1] = {name = "Bluebarian", points = 2, description = "Obtained using 500 Blueberry Bushes."},
	[2] = {name = "Back into the Abyss", points = 1, description = "You've cut off a whole lot of tentacles today. Thul was driven back to where he belongs."},
	[3] = {name = "Choking on Her Venom", points = 1, description = "The Old Widow fell prey to your supreme hunting skills."},
	[4] = {name = "One Less", points = 2, description = "The Many is no more, but how many more are there? One can never know."},
	[5] = {name = "Hissing Downfall", points = 2, description = "You've vansquished the Noxious Spawn and his serpentine heart."},
	[6] = {name = "Just Cracked Me Up!", points = 2, description = "Stonecracker's head was much softer than the stones he threw at you."},
	[7] = {name = "The Drowned Sea God", points = 2, description = "As the killer of Leviathan, the giant sea serpent, his underwater kingdom is now under your reign."}
}

function Player.getAchievementsPoints(self)
	return self:getStorageValue(Storage.achievements.points) > 0 and self:getStorageValue(Storage.achievements.points) or 0
end

function Player.addAchievement(self, number)
	local achievement = achievements[number]
	if achievement then
		self:setStorageValue(Storage.achievements.points, self:getAchievementsPoints() + achievement.points)
		self:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Congratulations! You earned the achievement \"" .. achievement.name .. "\".")
	end
	return true
end
