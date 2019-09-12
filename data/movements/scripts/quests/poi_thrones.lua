local config = {
	[2016] = {text = 'You have touched Infernatil\'s throne and absorbed some of his spirit.', effect = CONST_ME_FIREAREA},
	[2017] = {text = 'You have touched Tafariel\'s throne and absorbed some of his spirit.', effect = CONST_ME_MORTAREA},
	[2018] = {text = 'You have touched Verminor\'s throne and absorbed some of his spirit.', effect = CONST_ME_POISONAREA},
	[2019] = {text = 'You have touched Apocalypse\'s throne and absorbed some of his spirit.', effect = CONST_ME_EXPLOSIONAREA},
	[2020] = {text = 'You have touched Ashfalor\'s throne and absorbed some of his spirit.', effect = CONST_ME_FIREAREA}
}

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local throne = config[item.uid]
	if not throne then
		return true
	end

	if player:getStorageValue(item.uid) == -1 then
		player:setStorageValue(item.uid, 1)
		player:getPosition():sendMagicEffect(throne.effect)
		player:say(throne.text, TALKTYPE_MONSTER_SAY)
		player:teleportTo(fromPosition)
	else
		player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
		player:say('Begone!', TALKTYPE_MONSTER_SAY)
		player:teleportTo(fromPosition)
	end
	return true
end