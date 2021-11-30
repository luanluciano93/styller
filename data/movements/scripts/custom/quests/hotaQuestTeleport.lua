local config = {
	[2021] = {room = Position(1050, 1015, 8), exit = Position(1069, 985, 8)},
	[2022] = {room = Position(1064, 985, 8), exit = Position(1081, 1009, 8)},
	[2023] = {room = Position(1087, 1009, 8), exit = Position(1101, 986, 8)},
	[2024] = {room = Position(1095, 986, 8), exit = Position(1117, 1006, 8)},
	[2025] = {room = Position(1118, 1009, 8), exit = Position(1119, 987, 8)},
	[2026] = {room = Position(1124, 987, 8), exit = Position(1151, 1009, 8)},
	[2027] = {room = Position(1151, 1012, 8), exit = Position(1159, 985, 8)},
	[2028] = {room = Position(1159, 986, 8), exit = Position(1181, 1018, 8)}
}

function onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local hota = config[item.uid]
	if not hota then
		return true
	end

	local spectators, hasMonsters = Game.getSpectators(hota.room, false, false, 10, 10, 7, 7), false
	for i = 1, #spectators do
		if spectators[i]:isMonster() then
			if spectators[i]:getName():lower() ~= "magicthrower" then
				hasMonsters = true
				break
			end
		end
	end

	if hasMonsters then
		player:sendCancelMessage("You need to kill all monsters first.")
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return true
	end

	player:teleportTo(hota.exit)
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end
