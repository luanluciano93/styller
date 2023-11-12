local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_DEATH)

local function callback(creature, target)
	local min = (creature:getLevel() / 80) + (creature:getMagicLevel() * 0.5) + 7
	local max = (creature:getLevel() / 80) + (creature:getMagicLevel() * 0.9) + 8
	local damage = math.random(math.floor(min), math.floor(max))
	creature:addDamageCondition(target, CONDITION_CURSED,
	                            DAMAGELIST_EXPONENTIAL_DAMAGE, damage)
end

combat:setCallback(CallBackParam.TARGETCREATURE, callback)

function onCastSpell(creature, variant) return combat:execute(creature, variant) end
