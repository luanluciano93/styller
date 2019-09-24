local statues = {
	[1444] = SKILL_SWORD,
	[8836] = SKILL_AXE,
	[8626] = SKILL_CLUB,
	[10353] = SKILL_DISTANCE,
	[8777] = SKILL_MAGLEVEL
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local skill = statues[item:getId()]

	if player:isPzLocked() then
		return false
	end

	player:setOfflineTrainingSkill(skill)
	player:remove()
	return true
end
