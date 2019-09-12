local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local node1 = keywordHandler:addKeyword({'soft boots'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Do you want to repair your worn soft boots for 20000 gold coins?'})
	node1:addChildKeyword({'yes'}, StdModule.changeItem, {npcHandler = npcHandler, cost = 20000, removeItem = 10021, removeItemCount = 1, addItem = 2640, addItemCount = 1, text = 'Here you are.'})
	node1:addChildKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'Allright then. Come back when you are ready.', reset = true})

npcHandler:addModule(FocusModule:new())
