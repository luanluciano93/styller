local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local Topic, count, transfer = {}, {}, {}

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end

local lastSound = 0
function onThink()
	if lastSound < os.time() then
		lastSound = (os.time() + 5)
		if math.random(100) < 25 then
			Npc():say("Better deposit your money in the bank where it's safe.", TALKTYPE_SAY)
		end
	end
	npcHandler:onThink()
end

local function getCount(s)
	local b, e = s:find('%d+')
	return b and e and math.min(4294967295, tonumber(s:sub(b, e))) or -1
end

local function getMoneyWeight(money)
	local gold = money
	local crystal = math.floor(gold / 10000)
	gold = gold - crystal * 10000
	local platinum = math.floor(gold / 100)
	gold = gold - platinum * 100
	return (ItemType(2160):getWeight() * crystal) + (ItemType(2152):getWeight() * platinum) + (ItemType(2148):getWeight() * gold)
end

local function findPlayer(name)
	local resultId = db.storeQuery("SELECT `name` FROM `players` WHERE `name` = " .. db.escapeString(name))
	if resultId == false then
		return false
	end

	local playerName = result.getString(resultId, "name")
	result.free(resultId)
	return playerName
end

function greet(cid)
	Topic[cid], count[cid], transfer[cid] = nil, nil, nil
	return true
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
	local player = Player(cid)
	if player:getExhaustion() > 0 then
		npcHandler:say('You need to wait a time.', cid)
		Topic[cid] = nil
	
	elseif msgcontains(msg, 'balance') then
		npcHandler:say('Your account balance is ' .. getPlayerBalance(cid) .. ' gold.', cid)
		Topic[cid] = nil

	elseif msgcontains(msg, 'deposit') and msgcontains(msg, 'all') then
		if player:getMoney() == 0 then
			npcHandler:say('You don\'t have any gold with you.', cid)
			Topic[cid] = nil
		else
			count[cid] = player:getMoney()
			npcHandler:say('Would you really like to deposit ' .. count[cid] .. ' gold?', cid)
			Topic[cid] = 2
		end
	
	elseif msgcontains(msg, 'deposit') then
		if getCount(msg) == 0 then
			npcHandler:say('You are joking, aren\'t you??', cid)
			Topic[cid] = nil
		elseif getCount(msg) ~= -1 then
			if player:getMoney() >= getCount(msg) then
				count[cid] = getCount(msg)
				npcHandler:say('Would you really like to deposit ' .. count[cid] .. ' gold?', cid)
				Topic[cid] = 2
			else
				npcHandler:say('You do not have enough gold.', cid)
				Topic[cid] = nil
			end
		elseif player:getMoney() == 0 then
			npcHandler:say('You don\'t have any gold with you.', cid)
			Topic[cid] = nil
		else
			npcHandler:say('Please tell me how much gold it is you would like to deposit.', cid)
			Topic[cid] = 1
		end
		
	elseif Topic[cid] == 1 then
		if getCount(msg) == -1 then
			npcHandler:say('Please tell me how much gold it is you would like to deposit.', cid)
			Topic[cid] = 1
		elseif player:getMoney() >= getCount(msg) then
			count[cid] = getCount(msg)
			npcHandler:say('Would you really like to deposit ' .. count[cid] .. ' gold?', cid)
			Topic[cid] = 2
		else
			npcHandler:say('You do not have enough gold.', cid)
			Topic[cid] = nil
		end

	elseif msgcontains(msg, 'yes') and Topic[cid] == 2 then
		if player:removeMoney(count[cid]) then
			player:setBankBalance(player:getBankBalance() + count[cid])
			player:setExhaustion(2)
			npcHandler:say('Alright, we have added the amount of ' .. count[cid] .. ' gold to your balance. You can withdraw your money anytime you want to.', cid)
		else
			npcHandler:say('I am inconsolable, but it seems you have lost your gold. I hope you get it back.', cid)
		end
		Topic[cid] = nil
	
	elseif msgcontains(msg, 'no') and Topic[cid] == 2 then
		npcHandler:say('As you wish. Is there something else I can do for you?', cid)
		Topic[cid] = nil

	elseif msgcontains(msg, 'withdraw') then
		if getCount(msg) == 0 then
			npcHandler:say('Sure, you want nothing you get nothing!', cid)
			Topic[cid] = nil
		elseif getCount(msg) ~= -1 then
			if player:getBankBalance() >= getCount(msg) then
				count[cid] = getCount(msg)
				npcHandler:say('Are you sure you wish to withdraw ' .. count[cid] .. ' gold from your bank account?', cid)
				Topic[cid] = 4
			else
				npcHandler:say('There is not enough gold on your account.', cid)
				Topic[cid] = nil
			end
		elseif player:getBankBalance() == 0 then
			npcHandler:say('You don\'t have any money on your bank account.', cid)
			Topic[cid] = nil
		else
			npcHandler:say('Please tell me how much gold you would like to withdraw.', cid)
			Topic[cid] = 3
		end

	elseif Topic[cid] == 3 then
		if getCount(msg) == -1 then
			npcHandler:say('Please tell me how much gold you would like to withdraw.', cid)
			Topic[cid] = 3
		elseif player:getBankBalance() >= getCount(msg) then
			count[cid] = getCount(msg)
			npcHandler:say('Are you sure you wish to withdraw ' .. count[cid] .. ' gold from your bank account?', cid)
			Topic[cid] = 4
		else
			npcHandler:say('There is not enough gold on your account.', cid)
			Topic[cid] = nil
		end
	
	elseif msgcontains(msg, 'yes') and Topic[cid] == 4 then
		if player:getBankBalance() >= count[cid] then
			if player:getFreeCapacity() >= getMoneyWeight(count[cid]) then
				player:addMoney(count[cid])
				player:setBankBalance(player:getBankBalance() - count[cid])
				player:setExhaustion(2)
				npcHandler:say('Here you are, ' .. count[cid] .. ' gold. Please let me know if there is something else I can do for you.', cid)
			else
                npcHandler:say('Whoah, hold on, you have no room in your inventory to carry all those coins. I don\'t want you to drop it on the floor, maybe come back with a cart!', cid)
            end
		else
			npcHandler:say('There is not enough gold on your account.', cid)
		end
		Topic[cid] = nil
	
	elseif msgcontains(msg, 'no') and Topic[cid] == 4 then
		npcHandler:say('The customer is king! Come back anytime you want to if you wish to withdraw your money.', cid)
		Topic[cid] = nil

	elseif msgcontains(msg, 'transfer') then
		if getCount(msg) == 0 then
			npcHandler:say('Please think about it. Okay?', cid)
			Topic[cid] = nil
		elseif getCount(msg) ~= -1 then
			count[cid] = getCount(msg)
			if player:getBankBalance() >= count[cid] then
				npcHandler:say('Who would you like to transfer ' .. count[cid] .. ' gold to?', cid)
				Topic[cid] = 6
			else
				npcHandler:say('There is not enough gold on your account.', cid)
				Topic[cid] = nil
			end
		else
			npcHandler:say('Please tell me the amount of gold you would like to transfer.', cid)
			Topic[cid] = 5
		end
	
	elseif Topic[cid] == 5 then
		if getCount(msg) == -1 then
			npcHandler:say('Please tell me the amount of gold you would like to transfer.', cid)
			Topic[cid] = 5
		else
			count[cid] = getCount(msg)
			if player:getBankBalance() >= count[cid] then
				npcHandler:say('Who would you like to transfer ' .. count[cid] .. ' gold to?', cid)
				Topic[cid] = 6
			else
				npcHandler:say('There is not enough gold on your account.', cid)
				Topic[cid] = nil
			end
		end
	
	elseif Topic[cid] == 6 then
		if player:getBankBalance() >= count[cid] then
			local arrayDenied = {"accountmanager", "rooksample", "druidsample", "sorcerersample", "knightsample", "paladinsample"}
			if player:getName():lower() == msg:lower() then
				npcHandler:say('Fill in this field with person who receives your gold!', cid)
				Topic[cid] = nil
			elseif table.contains(arrayDenied, string.gsub(msg:lower(), " ", "")) then
                npcHandler:say('This player does not exist.', cid)
                Topic[cid] = nil
			else
				local transferToPlayer = Player(msg):getId()
				if transferToPlayer then
					transfer[cid] = msg
					npcHandler:say('Would you really like to transfer ' .. count[cid] .. ' gold to ' .. getPlayerName(v) .. '?', cid)
					Topic[cid] = 7
				elseif findPlayer(msg):lower() == msg:lower() then
					transfer[cid] = msg
					npcHandler:say('Would you really like to transfer ' .. count[cid] .. ' gold to ' .. findPlayer(msg) .. '?', cid)
					Topic[cid] = 7
				else
					npcHandler:say('This player does not exist.', cid)
					Topic[cid] = nil
				end
			end
		else
			npcHandler:say('There is not enough gold on your account.', cid)
			Topic[cid] = nil
		end
		
	elseif Topic[cid] == 7 and msgcontains(msg, 'yes') then
		if player:getBankBalance() >= count[cid] then
			local transferToPlayer = Player(transfer[cid]):getId()
			if transferToPlayer then
				player:setBankBalance(player:getBankBalance() - count[cid])
				transferToPlayer:setBankBalance(transferToPlayer:getBankBalance() + count[cid])
				player:setExhaustion(2)
				npcHandler:say('Very well. You have transferred ' .. count[cid] .. ' gold to ' .. getPlayerName(v) .. '.', cid)
			elseif findPlayer(transfer[cid]):lower() == transfer[cid]:lower() then
				player:setBankBalance(player:getBankBalance() - count[cid])
				player:setExhaustion(2)
				db.query("UPDATE `players` SET `balance` = `balance` + '" .. count[cid] .. "' WHERE `name` = " .. db.escapeString(transfer[cid]))
				npcHandler:say('Very well. You have transferred ' .. count[cid] .. ' gold to ' .. findPlayer(transfer[cid]) .. '.', cid)
			else
				npcHandler:say('This player does not exist.', cid)
			end
		else
			npcHandler:say('There is not enough gold on your account.', cid)
		end
		Topic[cid] = nil
	
	elseif Topic[cid] == 7 and msgcontains(msg, 'no') then
		npcHandler:say('Alright, is there something else I can do for you?', cid)
		Topic[cid] = nil

	elseif msgcontains(msg, 'change gold') then
		npcHandler:say('How many platinum coins would you like to get?', cid)
		Topic[cid] = 8
	
	elseif Topic[cid] == 8 then
		if getCount(msg) < 1 then
			npcHandler:say('Hmm, can I help you with something else?', cid)
			Topic[cid] = nil
		else
			count[cid] = math.min(500, getCount(msg))
			npcHandler:say('So you would like me to change ' .. count[cid] * 100 .. ' of your gold coins into ' .. count[cid] .. ' platinum coins?', cid)
			Topic[cid] = 9
		end
	
	elseif Topic[cid] == 9 then
		if msgcontains(msg, 'yes') then
			if player:removeItem(2148, count[cid] * 100) then
                player:addItem(2152, count[cid])
				npcHandler:say('Here you are.', cid)
			else
				npcHandler:say('Sorry, you do not have enough gold coins.', cid)
			end
		else
			npcHandler:say('Well, can I help you with something else?', cid)
		end
		Topic[cid] = nil
	
	elseif msgcontains(msg, 'change platinum') then
		npcHandler:say('Would you like to change your platinum coins into gold or crystal?', cid)
		Topic[cid] = 10
	
	elseif Topic[cid] == 10 then
		if msgcontains(msg, 'gold') then
			npcHandler:say('How many platinum coins would you like to change into gold?', cid)
			Topic[cid] = 11
		elseif msgcontains(msg, 'crystal') then
			npcHandler:say('How many crystal coins would you like to get?', cid)
			Topic[cid] = 13
		else
			npcHandler:say('Well, can I help you with something else?', cid)
			Topic[cid] = nil
		end
	
	elseif Topic[cid] == 11 then
		if getCount(msg) < 1 then
			npcHandler:say('Hmm, can I help you with something else?', cid)
			Topic[cid] = nil
		else
			count[cid] = math.min(500, getCount(msg))
			npcHandler:say('So you would like me to change ' .. count[cid] .. ' of your platinum coins into ' .. count[cid] * 100 .. ' gold coins for you?', cid)
			Topic[cid] = 12
		end
	
	elseif Topic[cid] == 12 then
		if msgcontains(msg, 'yes') then
			if player:removeItem(2152, count[cid]) then
                player:addItem(2148, count[cid] * 100)
				npcHandler:say('Here you are.', cid)
			else
				npcHandler:say('Sorry, you do not have enough platinum coins.', cid)
			end
		else
			npcHandler:say('Well, can I help you with something else?', cid)
		end
		Topic[cid] = nil
	
	elseif Topic[cid] == 13 then
		if getCount(msg) < 1 then
			npcHandler:say('Hmm, can I help you with something else?', cid)
			Topic[cid] = nil
		else
			count[cid] = math.min(500, getCount(msg))
			npcHandler:say('So you would like me to change ' .. count[cid] * 100 .. ' of your platinum coins into ' .. count[cid] .. ' crystal coins for you?', cid)
			Topic[cid] = 14
		end
	
	elseif Topic[cid] == 14 then
		if msgcontains(msg, 'yes') then
            if player:removeItem(2152, count[cid] * 100) then
                player:addItem(2160, count[cid])
                npcHandler:say('Here you are.', cid)
			else
				npcHandler:say('Sorry, you do not have enough platinum coins.', cid)
			end
		else
			npcHandler:say('Well, can I help you with something else?', cid)
		end
		Topic[cid] = nil
	
	elseif msgcontains(msg, 'change crystal') then
		npcHandler:say('How many crystal coins would you like to change into platinum?', cid)
		Topic[cid] = 15
	
	elseif Topic[cid] == 15 then
		if getCount(msg) == -1 or getCount(msg) == 0 then
			npcHandler:say('Hmm, can I help you with something else?', cid)
			Topic[cid] = nil
		else
			count[cid] = math.min(500, getCount(msg))
			npcHandler:say('So you would like me to change ' .. count[cid] .. ' of your crystal coins into ' .. count[cid] * 100 .. ' platinum coins for you?', cid)
			Topic[cid] = 16
		end

	elseif Topic[cid] == 16 then
		if msgcontains(msg, 'yes') then
            if player:removeItem(2160, count[cid])  then
                player:addItem(2152, count[cid] * 100)
                npcHandler:say('Here you are.', cid)
			else
				npcHandler:say('Sorry, you do not have enough crystal coins.', cid)
			end
		else
			npcHandler:say('Well, can I help you with something else?', cid)
		end
		Topic[cid] = nil

	elseif msgcontains(msg, 'change') then
		npcHandler:say('There are three different coin types in World: 100 gold coins equal 1 platinum coin, 100 platinum coins equal 1 crystal coin. So if you\'d like to change 100 gold into 1 platinum, simply say \'{change gold}\' and then \'1 platinum\'.', cid)
		Topic[cid] = nil

	elseif msgcontains(msg, 'bank') then
		npcHandler:say('We can change money for you. You can also access your bank account.', cid)
		Topic[cid] = nil
	end

	return true
end

keywordHandler:addKeyword({'money'}, StdModule.say, {npcHandler = npcHandler, text = 'We can {change} money for you. You can also access your {bank account}.'})
keywordHandler:addKeyword({'change'}, StdModule.say, {npcHandler = npcHandler, text = 'There are three different coin types in World: 100 gold coins equal 1 platinum coin, 100 platinum coins equal 1 crystal coin. So if you\'d like to change 100 gold into 1 platinum, simply say \'{change gold}\' and then \'1 platinum\'.'})
keywordHandler:addKeyword({'bank'}, StdModule.say, {npcHandler = npcHandler, text = 'We can {change} money for you. You can also access your {bank account}.'})
keywordHandler:addKeyword({'advanced'}, StdModule.say, {npcHandler = npcHandler, text = 'Your bank account will be used automatically when you want to {rent} a house or place an offer on an item on the {market}. Let me know if you want to know about how either one works.'})
keywordHandler:addKeyword({'help'}, StdModule.say, {npcHandler = npcHandler, text = 'You can check the {balance} of your bank account, {deposit} money or {withdraw} it. You can also {transfer} money to other characters, provided that they have a vocation.'})
keywordHandler:addKeyword({'functions'}, StdModule.say, {npcHandler = npcHandler, text = 'You can check the {balance} of your bank account, {deposit} money or {withdraw} it. You can also {transfer} money to other characters, provided that they have a vocation.'})
keywordHandler:addKeyword({'basic'}, StdModule.say, {npcHandler = npcHandler, text = 'You can check the {balance} of your bank account, {deposit} money or {withdraw} it. You can also {transfer} money to other characters, provided that they have a vocation.'})
keywordHandler:addKeyword({'job'}, StdModule.say, {npcHandler = npcHandler, text = 'I work in this bank. I can change money for you and help you with your bank account.'})

npcHandler:setCallback(CALLBACK_GREET, greet)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Welcome |PLAYERNAME|! What business do you have in the bank today? Please let me know if you need any {help}.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye, |PLAYERNAME|.")
npcHandler:addModule(FocusModule:new())