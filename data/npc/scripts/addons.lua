local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|. Will you help me? If you do, I'll reward you with nice addons! Just say {addons} or {help} if you don't know what to do.")

function playerBuyAddonNPC(cid, message, keywords, parameters, node)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)    
	local addonNode = node:getParent()
	local addoninfo = addonNode:getParameters()

	if parameters.confirm then
        if player:hasOutfit(addoninfo.outfit_male, addoninfo.addon) or player:hasOutfit(addoninfo.outfit_female, addoninfo.addon) then
			npcHandler:say('You already have this addon!', cid)
			npcHandler:resetNpc()
			return true
		end
		
		local items_number = 0
        local itemsTable = addoninfo.items
		if player:getSex() == 0 and (addoninfo.outfit_female == 138 or addoninfo.outfit_female == 141) then
			itemsTable = addoninfo.itemsFemale
		end
		
		if table.maxn(itemsTable) > 0 then
            for i = 1, table.maxn(itemsTable) do
                local item = itemsTable[i]
				if player:getItemCount(item[1]) >= item[2] then
                    items_number = items_number + 1
                end
            end
        end
        
		if player:getMoney() >= addoninfo.cost and (items_number == table.maxn(itemsTable)) then
            if player:removeMoney(addoninfo.cost) then
				if table.maxn(itemsTable) > 0 then
					for i = 1, table.maxn(itemsTable) do
						local item = itemsTable[i]
						if not player:removeItem(item[1],item[2]) then
							npcHandler:resetNpc()
							return true
						end
					end
				end

				if player:getSex() == 0 then
					if addoninfo.outfit_female == 138 then
						addoninfo.outfit_male = 133
					elseif addoninfo.outfit_female == 141 then
						addoninfo.outfit_male = 130
					end
				elseif player:getSex() == 1 then
					if addoninfo.outfit_male == 133 then
						addoninfo.outfit_female = 138
					elseif addoninfo.outfit_male == 130 then
						addoninfo.outfit_female = 141
					end
				end

				player:addOutfitAddon(addoninfo.outfit_male, addoninfo.addon)
				player:addOutfitAddon(addoninfo.outfit_female, addoninfo.addon)
				npcHandler:say('Here you are.', cid)
			end
        else
            npcHandler:say('You do not have needed items or cash!', cid)
        end
        npcHandler:resetNpc()
        return true

	elseif parameters.decline then
        npcHandler:say('Not interested? Maybe other addon?', cid)
        npcHandler:resetNpc()
        return true
	else
		local itemsTable = parameters.items
		if player:getSex() == 0 and (parameters.outfit_female == 138 or parameters.outfit_female == 141) then
			itemsTable = parameters.itemsFemale
		end

		local items_list = ''
		if table.maxn(itemsTable) > 0 then
			for i = 1, table.maxn(itemsTable) do
				local item = itemsTable[i]
				items_list = items_list .. item[2] .. ' ' .. ItemType(item[1]):getName()
				if i ~= table.maxn(itemsTable) then
					items_list = items_list .. ', '
				end
			end
		end
		
		local text = ''
		if parameters.cost > 0 and table.maxn(itemsTable) then
			text = items_list .. ' and ' .. parameters.cost .. ' gp'
		elseif (parameters.cost > 0) then
			text = parameters.cost .. ' gp'
		elseif table.maxn(itemsTable) then
			text = items_list
		end
		npcHandler:say('Did you bring me ' .. text .. ' for ' .. keywords[1] .. '?', cid)

		return true
	end

	return false
end

local noNode = KeywordNode:new({'no'}, playerBuyAddonNPC, {decline = true})
local yesNode = KeywordNode:new({'yes'}, playerBuyAddonNPC, {confirm = true})

-- citizen
local outfit_node = keywordHandler:addKeyword({'first citizen addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5878,100}}, outfit_female = 136, outfit_male = 128, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second citizen addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5890,100}, {5902,50}, {2480,1}}, outfit_female = 136, outfit_male = 128, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- hunter
local outfit_node = keywordHandler:addKeyword({'first hunter addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5947,1}, {5876,100}, {5948,100}, {5891,5}, {5887,1}, {5889,1}, {5888,1}}, outfit_female = 137, outfit_male = 129, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second hunter addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5875,1}}, outfit_female = 137, outfit_male = 129, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- mage
local outfit_node = keywordHandler:addKeyword({'first mage addon'}, playerBuyAddonNPC, {premium = false, cost = 0, itemsFemale = {{5958,1}}, items = {{2182,1}, {2186,1}, {2185,1}, {8911,1}, {2181,1}, {2183,1}, {2190,1}, {2191,1}, {2188,1}, {8921,1}, {2189,1}, {2187,1}, {2392,30}, {5809,1}, {2193,20}}, outfit_female = 138, outfit_male = 130, addon = 1}) 
outfit_node:addChildKeywordNode(yesNode) 
outfit_node:addChildKeywordNode(noNode) 
local outfit_node = keywordHandler:addKeyword({'second mage addon'}, playerBuyAddonNPC, {premium = false, cost = 0, itemsFemale = {{5894,70}, {5911,20}, {5883,40}, {5922,35}, {5879,10}, {5881,60}, {5882,40}, {2392,3}, {5905,30}}, items = {{5903,1}}, outfit_female = 138, outfit_male = 130, addon = 2}) 
outfit_node:addChildKeywordNode(yesNode) 
outfit_node:addChildKeywordNode(noNode) 

-- knight
local outfit_node = keywordHandler:addKeyword({'first knight addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5880,100}, {5892,1}}, outfit_female = 139, outfit_male = 131, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second knight addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5893,100}, {5924,1}, {5885,1}, {5887,1}}, outfit_female = 139, outfit_male = 131, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- nobleman
local outfit_node = keywordHandler:addKeyword({'first nobleman addon'}, playerBuyAddonNPC, {premium = false, cost = 150000, items = {}, outfit_female = 140, outfit_male = 132, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second nobleman addon'}, playerBuyAddonNPC, {premium = false, cost = 150000, items = {}, outfit_female = 140, outfit_male = 132, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- noblewoman
local outfit_node = keywordHandler:addKeyword({'first noblewoman addon'}, playerBuyAddonNPC, {premium = false, cost = 150000, items = {}, outfit_female = 140, outfit_male = 132, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second noblewoman addon'}, playerBuyAddonNPC, {premium = false, cost = 150000, items = {}, outfit_female = 140, outfit_male = 132, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- summoner
local outfit_node = keywordHandler:addKeyword({'first summoner addon'}, playerBuyAddonNPC, {premium = false, cost = 0, itemsFemale = {{2182,1}, {2186,1}, {2185,1}, {8911,1}, {2181,1}, {2183,1}, {2190,1}, {2191,1}, {2188,1}, {8921,1}, {2189,1}, {2187,1}, {2392,30}, {5809,1}, {2193,20}}, items = {{5958,1}}, outfit_female = 141, outfit_male = 133, addon = 1}) 
outfit_node:addChildKeywordNode(yesNode) 
outfit_node:addChildKeywordNode(noNode) 
local outfit_node = keywordHandler:addKeyword({'second summoner addon'}, playerBuyAddonNPC, {premium = false, cost = 0, itemsFemale = {{5903,1}}, items = {{5894,70}, {5911,20}, {5883,40}, {5922,35}, {5879,10}, {5881,60}, {5882,40}, {2392,3}, {5905,30}}, outfit_female = 141, outfit_male = 133, addon = 2}) 
outfit_node:addChildKeywordNode(yesNode) 
outfit_node:addChildKeywordNode(noNode) 

-- warrior
local outfit_node = keywordHandler:addKeyword({'first warrior addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5925,100}, {5899,100}, {5884,1}, {5919,1}}, outfit_female = 142, outfit_male = 134, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second warrior addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5880,100}, {5887,1}}, outfit_female = 142, outfit_male = 134, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- barbarian
local outfit_node = keywordHandler:addKeyword({'first barbarian addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5884,1}, {5885,1}, {5910,50}, {5911,50}, {5886,10}}, outfit_female = 147, outfit_male = 143, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second barbarian addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5880,100}, {5892,1}, {5893,50}, {5876,50}}, outfit_female = 147, outfit_male = 143, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- druid
local outfit_node = keywordHandler:addKeyword({'first druid addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5896,50}, {5897,50}}, outfit_female = 148, outfit_male = 144, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second druid addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5906,100}, {5938,1}, {5940,1}}, outfit_female = 148, outfit_male = 144, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- wizard
local outfit_node = keywordHandler:addKeyword({'first wizard addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{2536,1}, {2492,1}, {2488,1}, {2123,1}}, outfit_female = 149, outfit_male = 145, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second wizard addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5922,50}}, outfit_female = 149, outfit_male = 145, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- oriental
local outfit_node = keywordHandler:addKeyword({'first oriental addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5945,1}}, outfit_female = 150, outfit_male = 146, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second oriental addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5883,100}, {5895,100}, {5891,2}, {5912,100}}, outfit_female = 150, outfit_male = 146, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- pirate
local outfit_node = keywordHandler:addKeyword({'first pirate addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6098,100}, {6126,100}, {6097,100}}, outfit_female = 155, outfit_male = 151, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second pirate addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6101,1}, {6102,1}, {6100,1}, {6099,1}}, outfit_female = 155, outfit_male = 151, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- assassin
local outfit_node = keywordHandler:addKeyword({'first assassin addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5912,50}, {5910,50}, {5911,50}, {5913,50}, {5914,50}, {5909,50}, {5886,10}}, outfit_female = 156, outfit_male = 152, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second assassin addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5804,1}, {5930,1}}, outfit_female = 156, outfit_male = 152, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- beggar
local outfit_node = keywordHandler:addKeyword({'first beggar addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6107,1}}, outfit_female = 157, outfit_male = 153, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second beggar addon'}, playerBuyAddonNPC, {premium = false, cost = 20000, items = {{5883,100}}, outfit_female = 157, outfit_male = 153, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- shaman
local outfit_node = keywordHandler:addKeyword({'first shaman addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{3955,5}, {5015,1}}, outfit_female = 158, outfit_male = 154, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second shaman addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{3966,5}, {3967,5}}, outfit_female = 158, outfit_male = 154, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- norseman
local outfit_node = keywordHandler:addKeyword({'first norseman addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{7290,5}}, outfit_female = 252, outfit_male = 251, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second norseman addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{7290,10}}, outfit_female = 252, outfit_male = 251, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- norsewoman
local outfit_node = keywordHandler:addKeyword({'first norsewoman addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{7290,5}}, outfit_female = 252, outfit_male = 251, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second norsewoman addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{7290,10}}, outfit_female = 252, outfit_male = 251, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- jester
local outfit_node = keywordHandler:addKeyword({'first jester addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5912,50}, {5913,50}, {5914,50}, {5909,50}}, outfit_female = 270, outfit_male = 273, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second jester addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{5912,50}, {5910,50}, {5911,50}, {5912,50}}, outfit_female = 270, outfit_male = 273, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- nightmare
local outfit_node = keywordHandler:addKeyword({'first nightmare addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6500,1500}}, outfit_female = 269, outfit_male = 268, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second nightmare addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6500,1500}}, outfit_female = 269, outfit_male = 268, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

-- brotherhood
local outfit_node = keywordHandler:addKeyword({'first brotherhood addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6500,1500}}, outfit_female = 279, outfit_male = 278, addon = 1})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)
local outfit_node = keywordHandler:addKeyword({'second brotherhood addon'}, playerBuyAddonNPC, {premium = false, cost = 0, items = {{6500,1500}}, outfit_female = 279, outfit_male = 278, addon = 2})
outfit_node:addChildKeywordNode(yesNode)
outfit_node:addChildKeywordNode(noNode)

keywordHandler:addKeyword({'addons'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'I can give you {citizen}, {hunter}, {knight}, {mage}, {nobleman}, {summoner}, {warrior}, {barbarian}, {druid}, {wizard}, {oriental}, {pirate}, {assassin}, {beggar}, {shaman}, {norseman}, {nighmare}, {jester}, {yalaharian}, {brotherhood}, {warmaster} and {wayfarer} addons. If in doubt say {help}!'})
keywordHandler:addKeyword({'help'}, StdModule.say, {npcHandler = npcHandler, onlyFocus = true, text = 'To buy the first addon say \'first NAME addon\', for the second addon say \'second NAME addon\'.'})
 
npcHandler:addModule(FocusModule:new())