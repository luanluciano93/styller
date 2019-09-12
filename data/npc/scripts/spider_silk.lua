local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local node1 = keywordHandler:addKeyword({'spool of yarn'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Are you interested in exchanging a spool of yarn for 10 giant spider silk?'})
	node1:addChildKeyword({'yes'}, StdModule.changeItem, {npcHandler = npcHandler, cost = 0, removeItem = 5879, removeItemCount = 10, addItem = 5886, addItemCount = 1, text = 'Here you are.'})
	node1:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Allright then. Come back when you are ready.', reset = true})

npcHandler:addModule(FocusModule:new())
