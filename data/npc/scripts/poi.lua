local keywordHandler = KeywordHandler:new()
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if msgcontains(msg, "permission") then
		npcHandler:say("You want to Acquire Permissions for The Pits of Inferno Quest? If you want to say {hell}...", cid)
		npcHandler.topic[cid] = 2
	elseif msgcontains(msg, 'rules') then
		npcHandler:say("What do you want to know? Something about the three different {GENERAL} rules or the {PRICES}? Maybe you also want to know what happens when you die?", cid)
		npcHandler.topic[cid] = 1
	elseif npcHandler.topic[cid] == 1 then
		if msgcontains(msg, 'general') then
			npcHandler:say("Remember that if you die, it is YOUR problem and you won\'t be able to get back to your corpse and your backpack. If you enter in inquisition or you win or you go to temple.", cid)
			npcHandler.topic[cid] = 0
		elseif msgcontains(msg, 'prices') then
			npcHandler:say("A great pits of inferno cost 300000 gold coins.", cid)
			npcHandler.topic[cid] = 0
		end
	elseif msgcontains(msg, "hell") and npcHandler.topic[cid] == 2 then
		npcHandler:say("You really want to pay 300000 gold coins in the permissions pits of inferno quest, knowing you back there dead?", cid)
		npcHandler.topic[cid] = 3
	elseif msgcontains(msg, "yes") and npcHandler.topic[cid] == 3 then
		local player = Player(cid)
		if player:getStorageValue(Storage.pitsOfInferno.permission) == -1 then
			if not player:removeMoney(300000) then
				npcHandler:say("You do not have enough money!", cid)
			else
				npcHandler:say("As you wish! You can pass the door now...", cid)
				player:setStorageValue(Storage.pitsOfInferno.permission, 1)
			end
		else
			npcHandler:say("As you wish! You can pass the door now and enter the door...", cid)
		end
		npcHandler.topic[cid] = 0
	elseif(msgcontains(msg, 'no') and table.contains({1}, talkState[talkUser])) then
		npcHandler.topic[cid] = 0
		selfSay('Ok then.', cid)
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())