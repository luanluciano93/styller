local uids = {
	[7003] = {vocations = {1, 5, 9}, vocationName = "Master Sorcerers"},
	[7004] = {vocations = {2, 6, 10}, vocationName = "Elder Druids"},
	[7005] = {vocations = {3, 7, 11}, vocationName = "Royal Paladins"},
	[7006] = {vocations = {4, 8, 12}, vocationName = "Elite Knights"}
}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local uidDoor = uids[item.uid]
	if uidDoor then
		if table.contains(uidDoor.vocations, player:getVocation():getId()) then
			item:transform(itemId + 1)
			player:teleportTo(toPosition, true)
		else
			player:sendTextMessage(MESSAGE_INFO_DESCR, "Only ".. uidDoor.vocationName .."  may open this door.")
		end
	end
	return true
end