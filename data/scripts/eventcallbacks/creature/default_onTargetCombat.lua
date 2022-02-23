local ec = EventCallback

-- Regen Stamina in Trainer
local staminaBonus = {
    period = 180000, -- Period in milliseconds
    bonus = 1, -- gain stamina
    events = {}
}

local function addStamina(name)
    local player = Player(name)
    if not player then
        staminaBonus.events[name] = nil
    else
        local target = player:getTarget()
        if not target or target:getName() ~= "Trainer" then
            staminaBonus.events[name] = nil
        else
            player:setStamina(player:getStamina() + staminaBonus.bonus)
            staminaBonus.events[name] = addEvent(addStamina, staminaBonus.period, name)
        end
    end
end

ec.onTargetCombat = function(self, target)
	if not self then
		return true
	end

	if self:isPlayer() and target:isPlayer() then

		dofile('data/lib/custom/battlefield.lua')
		dofile('data/lib/custom/zombie.lua')
		dofile('data/lib/custom/duca.lua')
		dofile('data/lib/custom/capturetheflag.lua')

		-- Battlefield event
		if self:getStorageValue(BATTLEFIELD.storage) > 0 then
			if self:getStorageValue(BATTLEFIELD.storage) == target:getStorageValue(BATTLEFIELD.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end

		-- Zombie event
		if self:getStorageValue(ZOMBIE.storage) > 0 then
			if self:getStorageValue(ZOMBIE.storage) == target:getStorageValue(ZOMBIE.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end

		-- Duca event
		if self:getStorageValue(DUCA.storage) > 0 then
			if self:getStorageValue(DUCA.storage) == target:getStorageValue(DUCA.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end

		-- Capture the Flag event
		if self:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			if self:getStorageValue(CAPTURETHEFLAG.storage) == target:getStorageValue(CAPTURETHEFLAG.storage) then
				return RETURNVALUE_YOUMAYNOTATTACKTHISPLAYER
			end
		end
	end

	-- Regen Stamina in Trainer
	if self:isPlayer() then
		if target and target:getName() == "Trainer" then
			local name = self:getName()
			if not staminaBonus.events[name] then
				staminaBonus.events[name] = addEvent(addStamina, staminaBonus.period, name)
			end
		end
	end

	return true
end

ec:register()
