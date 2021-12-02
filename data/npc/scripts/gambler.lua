local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end

local config = {
    bonusPercent = 2,
    minimumBet = 100,
    maximumBet = 500000
}

local storeMoneyAmount = 0 -- Do not touch [We store the amount cash which got betted here]
local ITEM_BLOCKING = 8046

local function getMoneyAmount(position)
    local moneyAmount = 0
    for _, item in ipairs(Tile(position):getItems()) do
        local itemId = item:getId()
        if itemId == ITEM_GOLD_COIN then
            moneyAmount = moneyAmount + item.type
        elseif itemId == ITEM_PLATINUM_COIN then
            moneyAmount = moneyAmount + item.type * 100
        elseif itemId == ITEM_CRYSTAL_COIN then
            moneyAmount = moneyAmount + item.type * 10000
        end
    end

    return moneyAmount
end

local function handleMoney(cid, position, bonus)
    local npc = Npc(cid)
    if not npc then
        return
    end

    -- Lets remove the cash which was betted
    for _, item in ipairs(Tile(position):getItems()) do
        if table.contains({ITEM_GOLD_COIN, ITEM_PLATINUM_COIN, ITEM_CRYSTAL_COIN, ITEM_BLOCKING}, item:getId()) then
            item:remove()
        end
    end

    -- We lost, no need to continue
    if bonus == 0 then
        npc:say("You lost!", TALKTYPE_SAY)
        position:sendMagicEffect(CONST_ME_POFF)
        return
    end

    -- Cash calculator
    local goldCoinAmount = storeMoneyAmount * bonus
    local crystalCoinAmount = math.floor(goldCoinAmount / 10000)
    goldCoinAmount = goldCoinAmount - crystalCoinAmount * 10000
    local platinumCoinAmount = math.floor(goldCoinAmount / 100)
    goldCoinAmount = goldCoinAmount - platinumCoinAmount * 100

    if goldCoinAmount ~= 0 then
        Game.createItem(ITEM_GOLD_COIN, goldCoinAmount, position)
    end

    if platinumCoinAmount ~= 0 then
        Game.createItem(ITEM_PLATINUM_COIN, platinumCoinAmount, position)
    end

    if crystalCoinAmount ~= 0 then
        Game.createItem(ITEM_CRYSTAL_COIN, crystalCoinAmount, position)
    end

    position:sendMagicEffect(math.random(CONST_ME_FIREWORK_YELLOW, CONST_ME_FIREWORK_BLUE))
    npc:say("You Win!", TALKTYPE_SAY)
end

local function startRollDice(cid, position, number)
    for i = 5792, 5797 do
        local dice = Tile(position):getItemById(i)
        if dice then
            dice:transform(5791 + number)
            break
        end
    end

    local npc = Npc(cid)
    if npc then
        npc:say(string.format("%s rolled a %d", npc:getName(), number), TALKTYPE_MONSTER_SAY)
    end
end

local function executeEvent(cid, dicePosition, number, moneyPosition, bonus)
    local npc = Npc(cid)
    if not npc then
        return
    end
   
    if getMoneyAmount(moneyPosition) ~= storeMoneyAmount then
        npc:say("Where is the money?!", TALKTYPE_SAY)
        return
    end
   
    -- Roll Dice
    addEvent(startRollDice, 400, cid, dicePosition, number)
    dicePosition:sendMagicEffect(CONST_ME_CRAPS)
   
    -- Handle Money
    addEvent(handleMoney, 600, cid, moneyPosition, bonus)
end

local function creatureSayCallback(cid, type, msg)
    if not table.contains({"high", "low", "h", "l"}, msg) then -- Ignore other replies
        return false
    end

    -- Npc Variables
    local npc = Npc()
    local npcPosition = npc:getPosition()

    -- Check if player stand in position
    local playerPosition = Position(npcPosition.x + 2, npcPosition.y, npcPosition.z)
    local topCreature = Tile(playerPosition):getTopCreature()
    if not topCreature then
        npc:say("Please go stand next to me.", TALKTYPE_SAY)
        playerPosition:sendMagicEffect(CONST_ME_TUTORIALARROW)
        playerPosition:sendMagicEffect(CONST_ME_TUTORIALSQUARE)
        return false
    end

    -- Make sure also the player who stand there, is the one who is betting. To keep out people from disturbing
    if topCreature:getId() ~= cid then
        return false
    end

	-- High or Low numbers
    local rollType = 0
    if msgcontains(msg, "low") or msgcontains(msg, "l") then
        rollType = 1
    elseif msgcontains(msg, "high") or msgcontains(msg, "h") then
        rollType = 2
    else
        return false
    end

    -- Check money Got betted
    local moneyPosition = Position(npcPosition.x + 1, npcPosition.y - 1, npcPosition.z)
    storeMoneyAmount = getMoneyAmount(moneyPosition)
    if storeMoneyAmount < config.minimumBet or storeMoneyAmount > config.maximumBet then
        npc:say(string.format("You can only bet min: %d and max: %d gold coins.", config.minimumBet, config.maximumBet), TALKTYPE_SAY)
        return false
    end

	-- Money is betted, lets block them from getting moved // This is one way, else we can set actionid, on the betted cash.
    Game.createItem(ITEM_BLOCKING, 1, moneyPosition)

    -- Roll Number
    local rollNumber = math.random(6)

    -- Win or Lose
    local bonus = 0
    if rollType == 1 and table.contains({1, 2, 3}, rollNumber) then
        bonus = config.bonusPercent
    elseif rollType == 2 and table.contains({4, 5, 6}, rollNumber) then
        bonus = config.bonusPercent
    end
   
    -- Money handle and roll dice
    addEvent(executeEvent, 100, npc:getId(), Position(npcPosition.x, npcPosition.y - 1, npcPosition.z), rollNumber, moneyPosition, bonus)
    return true
end

function onThink()
    -- Anti trash
    local npcPosition = Npc():getPosition()
    local moneyPosition = Position(npcPosition.x + 1, npcPosition.y - 1, npcPosition.z)

    for _, item in ipairs(Tile(moneyPosition):getItems()) do
        local itemId = item:getId()
        if not table.contains({ITEM_GOLD_COIN, ITEM_PLATINUM_COIN, ITEM_CRYSTAL_COIN, ITEM_BLOCKING}, itemId) and ItemType(itemId):isMovable() then
            item:remove()
        end
    end
   
    local dicePosition = Position(npcPosition.x, npcPosition.y - 1, npcPosition.z)
    for _, item in ipairs(Tile(dicePosition):getItems()) do
        local itemId = item:getId()
		if table.contains({ITEM_GOLD_COIN, ITEM_PLATINUM_COIN, ITEM_CRYSTAL_COIN, ITEM_BLOCKING}, itemId) then
			item:moveTo(Position(npcPosition.x + 2, npcPosition.y - 1, npcPosition.z))
        elseif not table.contains({5792, 5793, 5794, 5795, 5796, 5797}, itemId) and ItemType(itemId):isMovable() then
            item:remove()
        end
    end

    npcHandler:onThink()                   
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
