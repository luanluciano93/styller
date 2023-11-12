local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_EARTHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_CARNIPHILA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_SMALLEARTH)

local function callback(player, level, magicLevel)
	level = math.min(level, 20)
	magicLevel = math.min(magicLevel, 20)
	local min = (level / 5) + (magicLevel * 0.4) + 2
	local max = (level / 5) + (magicLevel * 0.8) + 5
	return -min, -max
end

combat:setCallback(CallBackParam.LEVELMAGICVALUE, callback)

function onCastSpell(creature, variant) return combat:execute(creature, variant) end
