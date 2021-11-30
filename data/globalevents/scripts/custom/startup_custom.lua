function onStartup()

	-- Check offers in auction system
	local days = 7
	local expires = os.time() - (days * 86400)
	local resultId = db.storeQuery("SELECT `id` FROM `auction_system` WHERE `date` <= " .. expires)
	if resultId ~= false then
		local offers_deleted = 0
		repeat
			local auctionId = result.getNumber(resultId, "id")
			db.asyncQuery("DELETE FROM `auction_system` WHERE `id` = " .. auctionId)
			offers_deleted = offers_deleted + 1
		until not result.next(resultId)
		result.free(resultId)
		print(">> Auction system: ".. offers_deleted .." offers deleted.")
	end
end
