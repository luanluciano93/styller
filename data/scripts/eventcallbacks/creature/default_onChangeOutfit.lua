local ec = EventCallback

ec.onChangeOutfit = function(self, outfit)
	if self:isPlayer() then

		dofile('data/lib/custom/battlefield.lua')
		dofile('data/lib/custom/safezone.lua')
		dofile('data/lib/custom/duca.lua')
		dofile('data/lib/custom/capturetheflag.lua')

		-- Battlefield event, Safezone event, Duca event, Capture the Flag event
		if self:getStorageValue(BATTLEFIELD.storage) > 0 or self:getStorageValue(SAFEZONE.storage) > 0 or self:getStorageValue(DUCA.storage) > 0 or self:getStorageValue(CAPTURETHEFLAG.storage) > 0 then
			self:sendCancelMessage("You can't change your outfit inside the event.")
			return false
		end
	end
	return true
end

ec:register()
