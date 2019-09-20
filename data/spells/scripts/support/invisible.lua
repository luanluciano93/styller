local combat = Combat()
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local condition = Condition(CONDITION_INVISIBLE)
condition:setParameter(CONDITION_PARAM_TICKS, 200000)
combat:addCondition(condition)

function onCastSpell(creature, variant)
	if creature:getStorageValue(Storage.events) > 0 then
		creature:sendCancelMessage("You can not use spell in the event.")
		creature:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	else
		return combat:execute(creature, variant)
	end
end
