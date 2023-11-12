local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local function callback(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 70) + 438
	local max = (level / 5) + (magicLevel * 92) + 544
	return min, max
end

combat:setCallback(CallBackParam.LEVELMAGICVALUE, callback)

function onCastSpell(creature, variant) return combat:execute(creature, variant) end
