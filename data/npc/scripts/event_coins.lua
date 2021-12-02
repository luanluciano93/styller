local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local event_coin = 6527
	local shopWindow = {}
	local items = {
		[9693] = {price = 100}
	}

	local onBuy = function(cid, item, subType, amount, ignoreCap, inBackpacks)
		local player = Player(cid)
		if items[item] then
			if not ignoreCap and player:getFreeCapacity() < ItemType(item):getWeight(amount) then
				return player:sendTextMessage(MESSAGE_INFO_DESCR, "You don't have enough cap.")
			end

			if not player:removeItem(event_coin, items[item].price * amount) then
				return player:sendTextMessage(MESSAGE_INFO_DESCR, "You do not have the ".. (items[item].price * amount) .." required event coins. ")
			else	
				player:addItem(item, amount)
			end
		end
		return true
	end

	if msgcontains(msg, "trade") then
		for key, value in pairs(items) do
			table.insert(shopWindow, {id = key, subType = 0, buy = value.price, sell = 0, name = ItemType(key):getName():lower()})
		end
		openShopWindow(cid, shopWindow, onBuy, onSell)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
