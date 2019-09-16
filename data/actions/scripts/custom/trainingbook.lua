local text = "Information on Offline Training:\n 1. Choose a skill you'd like to train. Shielding is ALWAYS included.\n 2. If you're not sure which statue trains what, read the inscriptions.\n 2. Use a statue to be logged out of the game and train the skills associated with that statue.\n 4. When you log back into the game, your skills will have improved depending on how long you trained.\n 5. You have to be logged out of the game for at least 10 minutes in order for the training to take effect.\n 6. After 12 hours of constant offline training, your skills will not improve any further. Similar to stamina, your training bar will regenerate if you are not training offline."

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:showTextDialog(item.itemid, text)
	return true
end
