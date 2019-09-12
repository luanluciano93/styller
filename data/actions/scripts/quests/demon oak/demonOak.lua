local config = {
	demonOakIds = {8288, 8289, 8290, 8291},
	sounds = {
		'MY ROOTS ARE SHARP AS A SCYTHE! FEEL IT?!?',
		'CURSE YOU!',
		'RISE, MINIONS, RISE FROM THE DEAD!!!!',
		'AHHHH! YOUR BLOOD MAKES ME STRONG!',
		'GET THE BONES, HELLHOUND! GET THEM!!',
		'GET THERE WHERE I CAN REACH YOU!!!',
		'ETERNAL PAIN AWAITS YOU! NICE REWARD, HUH?!?!',
		'YOU ARE GOING TO PAY FOR EACH HIT WITH DECADES OF TORTURE!!',
		'ARGG! TORTURE IT!! KILL IT SLOWLY MY MINION!!'
	},
	bonebeastChance = 90,
	bonebeastCount = 4,
	waves = 10,
	summonPositions = {
		Position(873, 1034, 7),
		Position(878, 1034, 7),
		Position(882, 1034, 7),
		Position(873, 1038, 7),
		Position(881, 1038, 7),
		Position(873, 1041, 7),
		Position(877, 1041, 7),
		Position(882, 1041, 7),
	},
	summons = {
		[8288] = {
			[5] = {'Spectre', 'Blightwalker', 'Braindeath', 'Demon'},
			[10] = {'Betrayed Wraith', 'Betrayed Wraith'}
		},
		[8289] = {
			[5] = {'Plaguesmith', 'Plaguesmith', 'Blightwalker'},
			[10] = {'Dark Torturer', 'Blightwalker'}
		},
		[8290] = {
			[5] = {'Banshee', 'Plaguesmith', 'Hellhound'},
			[10] = {'Grim Reaper'}
		},
		[8291] = {
			[5] = {'Plaguesmith', 'Hellhound', 'Hellhound'},
			[10] = {'Undead Dragon', 'Hand of Cursed Fate'}
		}
	},
	storages = {
		[8288] = Storage.demonOak.axeBlowsBird,
		[8289] = Storage.demonOak.axeBlowsLeft,
		[8290] = Storage.demonOak.axeBlowsRight,
		[8291] = Storage.demonOak.axeBlowsFace
	},  
	DEMON_OAK_POSITION = Position(877, 1036, 7),
	DEMON_OAK_KICK_POSITION = Position(877, 1025, 7)
}

local function getRandomSummonPosition()
	return config.summonPositions[math.random(#config.summonPositions)]
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not table.contains(config.demonOakIds, target.itemid) then
		return true
	end

	local totalProgress = 0
	for k, v in pairs(config.storages) do
		totalProgress = totalProgress + math.max(0, player:getStorageValue(v))
	end

	local spectators, hasMonsters = Game.getSpectators(config.DEMON_OAK_POSITION, false, false, 9, 9, 6, 6), false
	for i = 1, #spectators do
		if spectators[i]:isMonster() then
			hasMonsters = true
			break
		end
	end

	if hasMonsters then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You need to kill all monsters first.')
		return true
	end

	local isDefeated = totalProgress == (#config.demonOakIds * (config.waves + 1))
	if isDefeated then
		player:teleportTo(config.DEMON_OAK_KICK_POSITION)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, 'You have completed the Demon Oak, now you can get your reward in the gravestone.')
		player:setStorageValue(Storage.demonOak.progress, 2)
		return true
	end

	local cStorage = config.storages[target.itemid]
	local progress = math.max(player:getStorageValue(cStorage), 1)
	if progress >= config.waves + 1 then
		toPosition:sendMagicEffect(CONST_ME_POFF)
		return true
	end

	local isLastCut = totalProgress == (#config.demonOakIds * (config.waves + 1) - 1)
	local summons = config.summons[target.itemid]
	if summons and summons[progress] then
		if isLastCut then
			Game.createMonster('Demon', getRandomSummonPosition(), false, true)
		else
			for i = 1, #summons[progress] do
				Game.createMonster(summons[progress][i], getRandomSummonPosition(), false, true)
			end
		end
	elseif math.random(100) >= config.bonebeastChance then
		for i = 1, config.bonebeastCount do
			Game.createMonster('Bonebeast', getRandomSummonPosition(), false, true)
		end
	end

	player:say(isLastCut and 'HOW IS THAT POSSIBLE?!? MY MASTER WILL CRUSH YOU!! AHRRGGG!' or config.sounds[math.random(#config.sounds)], TALKTYPE_MONSTER_YELL, false, player, config.DEMON_OAK_POSITION)
	toPosition:sendMagicEffect(CONST_ME_DRAWBLOOD)
	player:setStorageValue(cStorage, progress + 1)
	player:say('-krrrrak-', TALKTYPE_MONSTER_YELL, false, player, toPosition)
	doTargetCombatHealth(0, player, COMBAT_EARTHDAMAGE, -170, -210, CONST_ME_BIGPLANTS)

	return true
end