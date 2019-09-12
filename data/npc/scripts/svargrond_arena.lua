local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

function enterArena(cid, message, keywords, parameters, node)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player, cost, levelneeded, levelname  = Player(cid), 0, 0, ''
	if player:getStorageValue(Storage.svargrondArena.difficulty) < 1 then
		cost = 20000
		levelname = 'greenshore'
		levelneeded = 30
	elseif player:getStorageValue(Storage.svargrondArena.difficulty) == 1 then
		cost = 50000
		levelname = 'scrapper'
		levelneeded = 50
	elseif player:getStorageValue(Storage.svargrondArena.difficulty) == 2 then
		cost = 80000
		levelname = 'warlord'
		levelneeded = 80
	end
	
	if string.lower(keywords[1]) == 'yes' and parameters.prepare ~= 1 then
		if player:getLevel() >= levelneeded then
			if not player:removeMoney(cost) then
				npcHandler:say('You don\'t have ' .. cost .. ' gp! Come back when you will be ready!', cid)
			else
				npcHandler:say('Now you can go to test.', cid)
				player:setStorageValue(Storage.svargrondArena.permission, 1)
		    end
		else
			npcHandler:say('You don\'t have ' .. levelneeded .. ' level! Come back when you will be ready!', cid)
		end
		npcHandler:resetNpc()
	elseif string.lower(keywords[1]) == 'no' then
		npcHandler:say('Come back later then!', cid)
		npcHandler:resetNpc()
	else
		if getPlayerStorageValue(cid, Storage.svargrondArena.difficulty) < 3 then
			npcHandler:say('You test will be ' .. levelname .. ' level. If you want enter you must pay ' .. cost .. ' gp and have ' .. levelneeded .. ' level. Wanna try?', cid)
		else
			npcHandler:say('You did all arena levels.',cid)
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, 'Hello |PLAYERNAME|! Do you want to make {arena}?')

local yesNode = KeywordNode:new({'yes'}, enterArena, {})
local noNode = KeywordNode:new({'no'}, enterArena, {})

local node1 = keywordHandler:addKeyword({'arena'}, enterArena, {prepare=1})
	node1:addChildKeywordNode(yesNode)
	node1:addChildKeywordNode(noNode)
	
local node1 = keywordHandler:addKeyword({'fight'}, enterArena, {prepare=1})
	node1:addChildKeywordNode(yesNode)
	node1:addChildKeywordNode(noNode)
local node1 = keywordHandler:addKeyword({'yes'}, enterArena, {prepare=1})
	node1:addChildKeywordNode(yesNode)
	node1:addChildKeywordNode(noNode)
npcHandler:addModule(FocusModule:new())