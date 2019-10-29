local potions = {
	[1515] = {id = 7618, charges = 100, value = 5000}, -- health potion
	[1516] = {id = 7620, charges = 100, value = 5600}, -- mana potion
	[1517] = {id = 7588, charges = 100, value = 11500}, -- strong health potion
	[1518] = {id = 7589, charges = 100, value = 9300}, -- strong mana potion
	[1519] = {id = 7591, charges = 100, value = 22500}, -- great health potion
	[1520] = {id = 7590, charges = 100, value = 14400}, -- great mana potion
	[1521] = {id = 8473, charges = 100, value = 37900}, -- ultimate health potion
	[1522] = {id = 8472, charges = 100, value = 22800} -- spirit potion
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local potion = potions[item.actionid]
	if not potion then
		return false
	end

	local potionId = ItemType(potion.id)
	local itemWeight = potionId:getWeight() * potion.charges
	if player:getFreeCapacity() >= itemWeight then
		if not player:removeMoney(potion.value) then
			player:sendCancelMessage("You don't have ".. potion.value .." gold coins to buy ".. potion.charges .." ".. potionId:getName() ..".")
		else
			player:getPosition():sendMagicEffect(CONST_ME_DRAWBLOOD)
			player:addItem(potion.id, potion.charges)
		end
		
	else
		player:sendCancelMessage("You don't have capacity.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end

	item:transform(item.itemid == 1945 and 1946 or 1945)
	return true
end
