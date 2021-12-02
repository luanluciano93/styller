local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)
	npcHandler:onCreatureAppear(cid)
end
function onCreatureDisappear(cid)
	npcHandler:onCreatureDisappear(cid)
end
function onCreatureSay(cid, type, msg)
	npcHandler:onCreatureSay(cid, type, msg)
end
function onThink()
	npcHandler:onThink()
end

local voices = {
	{ text = 'Hum hum, huhum' },
	{ text = 'Silly lil\' human' }
}

npcHandler:addModule(VoiceModule:new(voices))

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if msgcontains(msg, "amulet") then
		npcHandler:say("Me can do unbroken but Big Ben want gold 5000 and Big Ben need a lil' time to make it unbroken. Yes or no??", cid)
		npcHandler.topic[cid] = 9

	elseif msgcontains(msg, "yes") then

		-- Crown Armor
		if npcHandler.topic[cid] == 4 then
			if player:removeItem(2487, 1) then
				npcHandler:say("Cling clang!", cid)
				npcHandler.topic[cid] = 0
				player:addItem(5887, 1)
			end
		-- Dragon Shield
		elseif npcHandler.topic[cid] == 5 then
			if player:removeItem(2516, 1) then
				npcHandler:say("Cling clang!", cid)
				npcHandler.topic[cid] = 0
				player:addItem(5889, 1)
			end
		-- Devil Helmet
		elseif npcHandler.topic[cid] == 6 then
			if player:removeItem(2462, 1) then
				npcHandler:say("Cling clang!", cid)
				npcHandler.topic[cid] = 0
				player:addItem(5888, 1)
			end
		-- Giant Sword
		elseif npcHandler.topic[cid] == 7 then
			if player:removeItem(2393, 1) then
				npcHandler:say("Cling clang!", cid)
				npcHandler.topic[cid] = 0
				player:addItem(5892, 1)
			end
		-- Soul Orb
		elseif npcHandler.topic[cid] == 8 then
			if player:getItemCount(5944) > 0 then
				local count = player:getItemCount(5944)
				for i = 1, count do
					if math.random(100) <= 1 then
						player:addItem(6529, 6)
						player:removeItem(5944, 1)
					else
						player:addItem(6529, 3)
						player:removeItem(5944, 1)
					end
				end
				npcHandler:say("Cling clang!", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("You dont have soul orbs!", cid)
				npcHandler.topic[cid] = 0
			end
		elseif npcHandler.topic[cid] == 9 then
			if player:getItemCount(8262) > 0 and player:getItemCount(8263) > 0 and player:getItemCount(8264) > 0 and player:getItemCount(8265) > 0 and player:getMoney() + player:getBankBalance() >= 5000 then
				player:removeItem(8262, 1)
				player:removeItem(8263, 1)
				player:removeItem(8264, 1)
				player:removeItem(8265, 1)
				player:removeMoneyNpc(5000)
				npcHandler:say("Ahh, lil' one wants amulet. Here! Have it! Mighty, mighty amulet lil' one has. Don't know what but mighty, mighty it is!!!", cid)
				player:addItem(8266, 1)
				npcHandler.topic[cid] = 0
			end
		elseif npcHandler.topic[cid] == 11 then
			if player:removeItem(5880, 1) then
				-- player:setStorageValue(Storage.HiddenCityOfBeregar.GearWheel, player:getStorageValue(Storage.HiddenCityOfBeregar.GearWheel) + 1)
				player:addItem(9690, 1)
				npcHandler:say("Cling clang!", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("Lil' one does not have any iron ores.", cid)
			end
			npcHandler.topic[cid] = 0

		elseif npcHandler.topic[cid] == 12 then -- Enchanted Chicken Wing
			if player:removeItem(2195, 1) then
				player:addItem(5891, 1)
				npcHandler:say("Here you are.", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("Sorry but you don't have the item.", cid)
			end
			npcHandler.topic[cid] = 0

		elseif npcHandler.topic[cid] == 13 then -- Flask of Warrior's Sweat
			if player:removeItem(2475, 4) then
				player:addItem(5885, 1)
				npcHandler:say("Here you are.", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("Sorry but you don't have the item.", cid)
			end
			npcHandler.topic[cid] = 0
			
		elseif npcHandler.topic[cid] == 14 then -- Spirit Container
			if player:removeItem(2498, 2) then
				player:addItem(5884, 1)
				npcHandler:say("Here you are.", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("Sorry but you don't have the item.", cid)
			end
			npcHandler.topic[cid] = 0

		elseif npcHandler.topic[cid] == 15 then -- Magic Sulphur
			if player:removeItem(2392, 3) then
				player:addItem(5904, 1)
				npcHandler:say("Here you are.", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("Sorry but you don't have the item.", cid)
			end
			npcHandler.topic[cid] = 0
			
		elseif npcHandler.topic[cid] == 16 then -- Spool of yarn
			if player:removeItem(5879, 10) then
				player:addItem(5886, 1)
				npcHandler:say("Here you are.", cid)
				npcHandler.topic[cid] = 0
			else
				npcHandler:say("Sorry but you don't have the item.", cid)
			end
			npcHandler.topic[cid] = 0
		end

	-- Crown Armor
	elseif msgcontains(msg, "crown armor") or msgcontains(msg, "piece of royal steel") or msgcontains(msg, "royal steel") then
		npcHandler:say("Very noble. Shiny. Me like. But breaks so fast. Me can make from shiny armour. Lil' one want to trade?", cid)
		npcHandler.topic[cid] = 4

	-- Dragon Shield
	elseif msgcontains(msg, "dragon shield") or msgcontains(msg, "piece of draconian steel") or msgcontains(msg, "draconian steel") then
		npcHandler:say("Firy steel it is. Need green ones' breath to melt. Or red even better. Me can make from shield. Lil' one want to trade?", cid)
		npcHandler.topic[cid] = 5

	-- Devil Helmet
	elseif msgcontains(msg, "devil helmet") or msgcontains(msg, "piece of hell steel") or msgcontains(msg, "hell steel") then
		npcHandler:say("Hellsteel is. Cursed and evil. Dangerous to work with. Me can make from evil helmet. Lil' one want to trade?", cid)
		npcHandler.topic[cid] = 6

	-- Giant Sword
	elseif msgcontains(msg, "giant sword") or msgcontains(msg, "huge chunk of crude iron") or msgcontains(msg, "crude iron") or msgcontains(msg, "huge chunk") then
		npcHandler:say("Good iron is. Me friends use it much for fight. Me can make from weapon. Lil' one want to trade?", cid)
		npcHandler.topic[cid] = 7

	-- Soul Orb
	elseif msgcontains(msg, "soul orb") or msgcontains(msg, "infernal bolt") or msgcontains(msg, "infernal") then
		npcHandler:say("Uh. Me can make some nasty lil' bolt from soul orbs. Lil' one want to trade all?", cid)
		npcHandler.topic[cid] = 8

	-- Iron Ore
	elseif msgcontains(msg, "gear wheel") or msgcontains(msg, "iron ore") then
		-- if player:getStorageValue(Storage.HiddenCityOfBeregar.GoingDown) > 0 and player:getStorageValue(Storage.HiddenCityOfBeregar.GearWheel) > 3 then
			npcHandler:say("Uh. Me can make some gear wheel from iron ores. Lil' one want to trade?", cid)
			npcHandler.topic[cid] = 11
		-- end

	-- Boots of Haste
	elseif msgcontains(msg, "enchanted chicken wing") or msgcontains(msg, "boots of haste") or msgcontains(msg, "chicken wing") then
		npcHandler:say('Do you want to trade Boots of haste for Enchanted Chicken Wing?', cid)
		npcHandler.topic[cid] = 12

	-- Warrior Helmet
	elseif msgcontains(msg, "warrior helmet") or msgcontains(msg, "warrior sweat") or msgcontains(msg, "flask of warrior's sweat") then
		npcHandler:say('Do you want to trade 4 Warrior Helmet for Warrior Sweat?', cid)
		npcHandler.topic[cid] = 13

	-- Royal Helmet
	elseif msgcontains(msg, "royal helmet") or msgcontains(msg, "fighting spirit") or msgcontains(msg, "spirit container") then
		npcHandler:say('Do you want to trade 2 Royal Helmet for Fighting Spirit', cid)
		npcHandler.topic[cid] = 14

	-- Fire Sword
	elseif msgcontains(msg, "fire sword") or msgcontains(msg, "magic sulphur") then
		npcHandler:say('Do you want to trade 3 Fire Sword for Magic Sulphur', cid)
		npcHandler.topic[cid] = 15
		
	-- Giant Spider Silk
	elseif msgcontains(msg, "spool of yarn") or msgcontains(msg, "giant spider silk") then
		npcHandler:say('Are you interested in exchanging a spool of yarn for 10 giant spider silk?', cid)
		npcHandler.topic[cid] = 16
	
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Hum Humm! Welcume lil' |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye lil' one.")

npcHandler:addModule(FocusModule:new())
