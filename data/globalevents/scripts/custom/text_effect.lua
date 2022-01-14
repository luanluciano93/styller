local effects = {
	{position = Position(966, 957, 7), text = "Trainers", effect = 49, say = true, color = math.random(1,255)},
	{position = Position(974, 957, 7), text = "Hunts", effect = 18, say = true, color = math.random(1,255)},
	{position = Position(970, 954, 8), text = "[PREMIUM]", effect = 40, say = true, color = math.random(1,255)},
	{position = Position(970, 957, 8), text = "Daily Reward", effect = 18, say = true, color = math.random(1,255)},
	{position = Position(972, 954, 8), text = "PVP arena", effect = 40, say = true, color = math.random(1,255)},
	{position = Position(970, 956, 7), text = "Events", effect = 40, say = true, color = math.random(1,255)},
}

function onThink(interval)
    for i = 1, #effects do
        local settings = effects[i]
        if settings then
			local spectators = Game.getSpectators(settings.position, false, true, 7, 7, 5, 5)
			if #spectators > 0 then
				if settings.text then
					for i = 1, #spectators do
						if settings.say then
							spectators[i]:say(settings.text, TALKTYPE_MONSTER_SAY, false, spectators[i], settings.position)
						else
							Game.sendAnimatedText(settings.text, settings.position, settings.color)
						end
					end
				end
				if settings.effect then
					settings.position:sendMagicEffect(settings.effect)
				end
			end
		end
    end
  return true
end
