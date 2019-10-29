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

	local player = Player(cid)
	if msgcontains(msg, "hallowed axe") then
		npcHandler:say("Do you want to buy a hallowed axe from me por 100000 golds coins and an axe?", cid)
		npcHandler.topic[cid] = 1
	elseif msgcontains(msg, "yes") and npcHandler.topic[cid] == 1 then
		if player:getMoney() >= 100000 and player:getItemCount(2386) >= 1 then
			if not player:removeMoney(100000) then
				print("[ERROR] NPC: Oldrak, FUNCTION: removeMoney, PLAYER: "..player:getName())
			elseif not player:removeItem(2386, 1) then
				print("[ERROR] NPC: Oldrak, FUNCTION: removeItem, PLAYER: "..player:getName())
			else
				npcHandler:say("Here you are. You can now defeat the demon oak with this axe.", cid)
				Npc():getPosition():sendMagicEffect(CONST_ME_YELLOWENERGY)
				player:addItem(8293, 1)
			end
		else
			npcHandler:say("I need 100000 gold coins and an axe to make you a {hallowed axe}.", cid)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, "demon oak") then
		npcHandler:say("Did you defeat the demon oak?", cid)
		npcHandler.topic[cid] = 2
	elseif msgcontains(msg, "yes") and npcHandler.topic[cid] == 2 then
		if player:getStorageValue(Storage.demonOak) >= 1 then
			npcHandler:say('Good job!', cid)
			player:setStorageValue(Storage.demonOak, 2)
		else
			npcHandler:say('Go defeat the demon oak first.', cid)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, "no") then
		npcHandler:say('Ok, thanks.', cid)
		npcHandler.topic[cid] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())