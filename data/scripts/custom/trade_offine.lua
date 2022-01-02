-- Revscript Trade Offline by WooX and luanluciano93 --

-- !tradeoff add, ValueInGolds      / ex: !tradeoff add, 5000
-- !tradeoff add, ItemTrade         / ex: !tradeoff add, golden legs
-- !tradeoff add, ItemTrade, Count  / ex: !tradeoff add, event coins, 10
-- !tradeoff buy, AuctionID         / ex: !tradeoff buy, 1943
-- !tradeoff remove, AuctionID      / ex: !tradeoff remove, 1943
-- !tradeoff info, AuctionID        / ex: !tradeoff info, 1943

-- Instalação automática de tabelas se ainda não as tivermos (primeira instalação)
db.query([[
	CREATE TABLE IF NOT EXISTS `trade_off_offers` (
		`id` int unsigned NOT NULL AUTO_INCREMENT,
		`player_id` int NOT NULL,
		`type` tinyint unsigned NOT NULL DEFAULT '0',
		`item_id` smallint unsigned NOT NULL,
		`item_count` smallint unsigned NOT NULL DEFAULT '1',
		`item_charges` int unsigned NOT NULL DEFAULT '0',
		`item_duration` int unsigned NOT NULL DEFAULT '0',
		`item_name` varchar(255) NOT NULL,
		`item_trade` tinyint unsigned NOT NULL DEFAULT '0',
		`cost` bigint unsigned NOT NULL DEFAULT '0',
		`cost_count` smallint unsigned NOT NULL DEFAULT '1',
		`sold` tinyint unsigned NOT NULL DEFAULT '0',
		`date` bigint unsigned NOT NULL,
		PRIMARY KEY (`id`),
		FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
	) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
]])

db.query([[
	CREATE TABLE IF NOT EXISTS `trade_off_container_items` (
		`offer_id` int unsigned NOT NULL,
		`item_id` smallint unsigned NOT NULL,
		`item_charges` int unsigned NOT NULL DEFAULT '0',
		`item_duration` int unsigned NOT NULL DEFAULT '0', 
		`count` smallint unsigned NOT NULL DEFAULT '1',
		FOREIGN KEY (`offer_id`) REFERENCES `trade_off_offers`(`id`) ON DELETE CASCADE,
		KEY `offer_id`(`offer_id`)
	) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8;
]])

local config = STYLLER.tradeOffine

local function retornarItemsdoContainer(uid)
	local container = Container(uid)
	if not container then
		return false
	end

	local itemsdoContainer = {}
	local tamanhoDoContainer = container:getSize()
	for i = (tamanhoDoContainer - 1), 0, -1 do
		local itemDentroDoContainer = container:getItem(i)
		if not itemDentroDoContainer then
			return false
		end

		-- Verifique se há recipientes com itens dentro
		local containerDentroDoContainer = Container(itemDentroDoContainer)
		if containerDentroDoContainer then
			local containerComItemDentroDoContainer = containerDentroDoContainer:getItem(0)
			if containerComItemDentroDoContainer then
				return false
			end
		end

		local cargasDoItemDentroDoContainer = 0
		local duracaoDoItemDentroDoContainer = 0

		local charges = itemDentroDoContainer:getCharges()
		if charges then
			if charges > 0 then
				cargasDoItemDentroDoContainer = charges
			end
		end

		local duration = itemDentroDoContainer:getDuration()
		if duration then
			if duration > 0 then
				duracaoDoItemDentroDoContainer = duration
			end
		end

		if table.contains(config.blockedItems, itemDentroDoContainer:getId()) then
			return false
		end

		local quantidadeDoItemDentroDoContainer = itemDentroDoContainer:getCount()

		local itemDentroDoContainerId = itemDentroDoContainer:getId()
		if not itemDentroDoContainerId then
			return false
		end

		itemsdoContainer[i + 1] = {id = itemDentroDoContainerId, count = quantidadeDoItemDentroDoContainer, charges = cargasDoItemDentroDoContainer, duration = duracaoDoItemDentroDoContainer}
	end
	return itemsdoContainer and itemsdoContainer or false
end

local function durationTimeString(durationTime)
	if not durationTime then
		return false
	end

	local duration = durationTime / 1000
	if duration > 0 then
		local frase = 'that will expire in '
		if duration >= 86400 then
			local days = math.floor(duration / 86400)
			local hours = math.floor((duration % 86400) / 3600)
			frase = frase .. days .. ' day' ..(days ~= 1 and 's' or '')
			if hours > 0 then
				frase = frase .. ' and '.. hours .. ' hour' ..(hours ~= 1 and 's' or '')
			end
		elseif duration >= 3600 then
			local hours = math.floor(duration / 3600)
			local minutes = math.floor((duration % 3600) / 60)
			frase = frase .. hours .. ' hour' ..(hours ~= 1 and 's' or '')
			if minutes > 0 then
				frase = frase .. ' and '.. minutes .. ' minute' ..(minutes ~= 1 and 's' or '')
			end
		elseif duration >= 60 then
			local minutes = math.floor(duration / 60)
			local seconds = duration % 60
			frase = frase .. minutes .. ' minute' ..(minutes ~= 1 and 's' or '')
			if seconds > 0 then
				frase = frase .. ' and '.. seconds .. ' second' ..(seconds ~= 1 and 's' or '')
			end
		else
			frase = frase .. duration .. ' second' ..(duration ~= 1 and 's' or '')
		end
		return frase
	end
	return false
end

local trade_offline_talkaction = TalkAction("!tradeoff")
function trade_offline_talkaction.onSay(player, words, param)
	if param == '' then
		player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Command param required.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local posicao = player:getPosition()
	local tile = Tile(posicao)
	if not tile then
		player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Invalid player position.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	if not tile:hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You must be in the protection zone to use these commands.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	local aguardar = player:getStorageValue(config.aguardarStorage) - os.time()
	if aguardar > 0 then
		player:sendCancelMessage("You're exhausted.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	texto = string.lower(param)
	local palavra = texto:splitTrimmed(",")

	player:setStorageValue(config.aguardarStorage, 10 + os.time())

	if not table.contains({"add", "remove", "active", "info", "buy"}, palavra[1]) then
		player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Invalid parameters. Trade offline commands:" .. "\n"
			.. "!tradeoff add, ValueInGolds" .. "\n"
			.. "!tradeoff add, ItemTrade" .. "\n"
			.. "!tradeoff add, ItemTrade, Count" .. "\n"
			.. "!tradeoff remove, AuctionID" .. "\n"
			.. "!tradeoff active" .. "\n"
			.. "!tradeoff info, AuctionID" .. "\n"
			.. "!!tradeoff buy, AuctionID")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
		return false
	end

	-- !tradeoff add
	if palavra[1] == "add" then

		if player:getLevel() < config.levelParaAddOferta and not player:getGroup():getAccess() then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have required level ".. config.levelParaAddOferta .." to add offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertas = 0
		local playerId = player:getGuid()
		local pesquisaBancoDeDados = db.storeQuery("SELECT `id` FROM `trade_off_offers` WHERE `player_id` = " .. playerId .." AND `sold` = 0")
		if pesquisaBancoDeDados ~= false then
			repeat
				ofertas = ofertas + 1
			until not result.next(pesquisaBancoDeDados)
			result.free(pesquisaBancoDeDados)
		end

		if ofertas >= config.maxOfertasPorPlayer and not player:getGroup():getAccess() then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Sorry you can't add more offers (max. " .. config.maxOfertasPorPlayer .. ")")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please enter the value of the offer or the item you want to buy. Ex: !tradeoff add, sellForValue, !tradeoff add, sellForItem or !tradeoff add, sellForItem, sellForCountItem")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemOfertado = player:getSlotItem(CONST_SLOT_AMMO)
		if not itemOfertado then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] To create an offer the item must be in the ammunition slot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemOfertadoId = itemOfertado:getId()
		if itemOfertadoId == 0 then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] To create an offer the item must be in the ammunition slot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemOfertadoItemType = ItemType(itemOfertadoId)

		if not itemOfertadoItemType:isPickupable() then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You cannot add this item type as an offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if itemOfertadoItemType:isCorpse() then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You cannot add a corpse as an offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if table.contains(config.blockedItems, itemOfertadoId) then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] This item is blocked.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local mensagemPagamento = ""
		local itemComoPagamento = 0
		local addPagamento
		local quantidadeDoItemComoPagamento = 1

		-- !tradeoff add, valor
		if isNumber(palavra[2]) then

			if table.contains(config.goldItems, itemOfertadoId) then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can't trade gold for gold.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local dinheiroComoPagamento = tonumber(palavra[2])
			if dinheiroComoPagamento < 1 then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The offer must have a value greater than 0.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if dinheiroComoPagamento > config.precoLimite then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The offer may not exceed the value of "..config.precoLimite.." gold coins.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			addPagamento = dinheiroComoPagamento
			mensagemPagamento = "for ".. dinheiroComoPagamento .." gold coins."

		else -- !tradeoff add, item

			local itemComoPagamentoItemType = ItemType(palavra[2])
			local itemIdComoPagamento = itemComoPagamentoItemType:getId()
			if not itemIdComoPagamento then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] This item does not exist, check if it's name is correct.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if itemIdComoPagamento == 0 then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] This item does not exist, check if it's name is correct.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if table.contains(config.goldItems, itemIdComoPagamento) then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] To sell for gold insert only the amount instead of item name.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if table.contains(config.blockedItems, itemIdComoPagamento) then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] This payment item is blocked.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if itemIdComoPagamento == itemOfertadoId then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can not trade equal items.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if itemComoPagamentoItemType:isCorpse() then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can't ask for a corpse as payment")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if not itemComoPagamentoItemType:isMovable() or not itemComoPagamentoItemType:isPickupable() then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You cannot request this type of payment item.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			-- !tradeoff add, item, count
			if palavra[3] then
				if not itemComoPagamentoItemType:isStackable() then
					player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can only select the quantity with stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end

				if not isNumber(palavra[3]) then
					player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can only receive from 1 to 100 stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end

				quantidadeDoItemComoPagamento = tonumber(palavra[3])
				if quantidadeDoItemComoPagamento < 1 or quantidadeDoItemComoPagamento > 100 then
					player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can only receive from 1 to 100 stackable items.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end

			itemComoPagamento = 1
			addPagamento = itemIdComoPagamento

			local artigoDoItemComoPagamento = (palavra[3] and quantidadeDoItemComoPagamento or (itemComoPagamentoItemType:getArticle() ~= "" and itemComoPagamentoItemType:getArticle() or ""))
			local nomeDoItemComoPagamento = (palavra[3] and quantidadeDoItemComoPagamento and itemComoPagamentoItemType:getPluralName() or itemComoPagamentoItemType:getName())
			mensagemPagamento = "for ".. artigoDoItemComoPagamento .. " ".. nomeDoItemComoPagamento .."."
		end

		local quantidadeDoItemOfertado = itemOfertadoItemType:isStackable() and itemOfertado:getCount() or 1
		local nomeDoItemOfertado = (quantidadeDoItemOfertado > 1 and itemOfertadoItemType:getPluralName() or itemOfertadoItemType:getName())

		local itemsDoContainer = {}
		local itemOfertadoIsContainer = itemOfertadoItemType:isContainer()
		if itemOfertadoIsContainer then
			itemsDoContainer = retornarItemsdoContainer(itemOfertado.uid)
			if not itemsDoContainer then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You cannot use blocked items inside containers and you cannot use container with items inside container.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
		end

		local tipoDeOferta = 1 -- no container
		if #itemsDoContainer > 0 then
			tipoDeOferta = 2 -- container
		end

		local cargasDoItemOfertado = 0
		local duracaoDoItemOfertado = 0

		local charges = itemOfertado:getCharges()
		if charges then
			if charges > 0 then
				cargasDoItemOfertado = charges
			end
		end

		local duration = itemOfertado:getDuration()
		if duration then
			if duration > 0 then
				duracaoDoItemOfertado = duration
			end
		end

		if player:getMoney() < config.valuePerOffer then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You need ".. config.valuePerOffer .." gold coins to add an offer in trade offline.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local inserirNoBancoDeDados = "INSERT INTO `trade_off_offers` (`id`, `player_id`, `type`, `item_id`, `item_count`, `item_charges`, `item_duration`, `item_name`, `item_trade`, `cost`, `cost_count`, `sold`, `date`) VALUES (NULL, "
			.. playerId ..", ".. tipoDeOferta ..", ".. itemOfertadoId ..", ".. quantidadeDoItemOfertado ..", ".. cargasDoItemOfertado ..", ".. duracaoDoItemOfertado ..", ".. db.escapeString(nomeDoItemOfertado) ..", "
			.. itemComoPagamento ..", " .. addPagamento ..", ".. quantidadeDoItemComoPagamento ..", 0, ".. os.time() ..")"

		local mensagemContainer = ""
		if tipoDeOferta == 2 then -- Container
			if #itemsDoContainer == 0 then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can not have containers with items inside the main container.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			db.query(inserirNoBancoDeDados)

			for i = 1, #itemsDoContainer do
				db.query("INSERT INTO trade_off_container_items (offer_id, item_id, item_charges, item_duration, count) VALUES (LAST_INSERT_ID(), "
				..itemsDoContainer[i].id..", "..itemsDoContainer[i].charges..", "..itemsDoContainer[i].duration..", "..itemsDoContainer[i].count..")")
			end

			mensagemContainer = " with ".. #itemsDoContainer .." items inside"
		else
			db.query(inserirNoBancoDeDados)
		end

		local artigoDoItemOfertado = (quantidadeDoItemOfertado > 1 and quantidadeDoItemOfertado or (itemOfertado:getArticle() ~= "" and (itemOfertado:getArticle().. " ") or ""))

		player:sendTextMessage(config.successMsgType, "[TRADE OFF] You announced ".. artigoDoItemOfertado .. "".. nomeDoItemOfertado .."".. mensagemContainer .." "
		.. mensagemPagamento .." Check out the offer id on the website.")

		player:removeTotalMoney(config.valuePerOffer)
		itemOfertado:remove()

	-- !tradeoff remove
	elseif palavra[1] == "remove" then
		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please enter the offerID you want to remove.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		-- !tradeoff remove, offerID
		if not isNumber(palavra[2]) then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertaID = tonumber(palavra[2])
		local ofertaBancoDeDados = db.storeQuery("SELECT * FROM `trade_off_offers` WHERE `id` = ".. ofertaID .." AND `sold` = 0")
		if not ofertaBancoDeDados then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerIdBancoDeDados = result.getNumber(ofertaBancoDeDados, "player_id")
		local playerId = player:getGuid()
		if playerId ~= playerIdBancoDeDados then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can not remove someone else's offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local cidadeId = player:getTown():getId()
		local depot = player:getDepotChest(cidadeId, true)
		if not depot then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The city you live in has no depot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemID = result.getNumber(ofertaBancoDeDados, "item_id")
		local quantidadeDoItem = result.getNumber(ofertaBancoDeDados, "item_count")
		local cargasDoItem = result.getNumber(ofertaBancoDeDados, "item_charges")
		local duracaoDoItem = result.getNumber(ofertaBancoDeDados, "item_duration")								
		result.free(ofertaBancoDeDados)

		local item
		if duracaoDoItem > 0 then
			item = Game.createItem(itemID)
			item:setAttribute(ITEM_ATTRIBUTE_DURATION, duracaoDoItem)
		elseif cargasDoItem > 0 then
			item = Game.createItem(itemID)
			item:setAttribute(ITEM_ATTRIBUTE_CHARGES, cargasDoItem)
		else
			item = Game.createItem(itemID, quantidadeDoItem)
		end

		local itemRemovidoItemType = ItemType(itemID)
		local itemRemovidoIsContainer = itemRemovidoItemType:isContainer()
		if itemRemovidoIsContainer then
			local selecionarItensDentroDoContainer = db.storeQuery("SELECT * FROM `trade_off_container_items` WHERE `offer_id` = ".. ofertaID)
			if selecionarItensDentroDoContainer ~= false then
				repeat
					local idDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_id")
					local cargasDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_charges")
					local duracaoDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_duration")
					local quantidadeDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "count")

					local itemDentroDoContainer
					if duracaoDoItemDentroDoContainer > 0 then
						itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer)
						itemDentroDoContainer:setAttribute(ITEM_ATTRIBUTE_DURATION, duracaoDoItemDentroDoContainer)
					elseif cargasDoItemDentroDoContainer > 0 then
						itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer)
						itemDentroDoContainer:setAttribute(ITEM_ATTRIBUTE_CHARGES, cargasDoItemDentroDoContainer)
					else
						itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer, quantidadeDoItemDentroDoContainer)
					end

					item:addItemEx(itemDentroDoContainer)

				until not result.next(selecionarItensDentroDoContainer)
				result.free(selecionarItensDentroDoContainer)

				db.query("DELETE FROM `trade_off_container_items` WHERE `offer_id` = ".. ofertaID)
			end
		end

		local parcel = Game.createItem(ITEM_PARCEL)
		parcel:addItemEx(item)

		db.query("DELETE FROM `trade_off_offers` WHERE `id` = ".. ofertaID)

		local cidadeNome = Town(cidadeId):getName()
		local carta = Game.createItem(2598)
		carta:setAttribute(ITEM_ATTRIBUTE_TEXT, "[TRADE OFF] You canceled your offer with ID: ".. ofertaID ..".")
		parcel:addItemEx(carta)
		depot:addItemEx(parcel)

		player:sendTextMessage(config.successMsgType, "[TRADE OFF] You canceled your offer with ID: ".. ofertaID ..", the respective offer items were sent to ".. cidadeNome .." depot.")

		return false

	-- !tradeoff active
	elseif palavra[1] == "active" then

		local playerId = player:getGuid()
		local selecionarOfertasNoBancoDeDados = db.storeQuery("SELECT * FROM `trade_off_offers` WHERE `player_id` = ".. playerId .." AND `sold` = 0")
		if selecionarOfertasNoBancoDeDados ~= false then
			local mensagemOfertas = ""
			while selecionarOfertasNoBancoDeDados ~= false do
				local ofertaID = result.getNumber(selecionarOfertasNoBancoDeDados, "id")
				if not result.next(selecionarOfertasNoBancoDeDados) then
					mensagemOfertas = mensagemOfertas .. ofertaID
					break
				else
					mensagemOfertas = mensagemOfertas .. ofertaID .. ", "
				end
			end
			result.free(selecionarOfertasNoBancoDeDados)
			player:sendTextMessage(config.successMsgType, "[TRADE OFF] Active offers ID: ".. mensagemOfertas ..".")
		else
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have any active offers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end

		return false

	-- !tradeoff info
	elseif palavra[1] == "info" then
		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please enter the offerID you want to know about.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not isNumber(palavra[2]) then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertaID = tonumber(palavra[2])
		local selecionarOfertas = db.storeQuery("SELECT * FROM `trade_off_offers` WHERE `id` = ".. ofertaID .." AND `sold` = 0")
		if not selecionarOfertas then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerID = result.getNumber(selecionarOfertas, "player_id")
		local tipoDeOferta = result.getNumber(selecionarOfertas, "type")
		local itemID = result.getNumber(selecionarOfertas, "item_id")
		local quantidadeDoItemInfo = result.getNumber(selecionarOfertas, "item_count")
		local itemCharges = result.getNumber(selecionarOfertas, "item_charges")
		local itemDuration = result.getNumber(selecionarOfertas, "item_duration")
		local isTrade = result.getNumber(selecionarOfertas, "item_trade")
		local cost = result.getNumber(selecionarOfertas, "cost")
		local costCount = result.getNumber(selecionarOfertas, "cost_count")
		local addedDate = result.getNumber(selecionarOfertas, "date")
		result.free(selecionarOfertas)

		local normalItem = true
		local itemInfoItemType = ItemType(itemID)
		local artigoDoItemInfo = (quantidadeDoItemInfo > 1 and quantidadeDoItemInfo or (itemInfoItemType:getArticle() ~= "" and itemInfoItemType:getArticle() or ""))
		local nomeDoItemInfo = (quantidadeDoItemInfo > 1 and itemInfoItemType:getPluralName() or itemInfoItemType:getName())

		local itemDuracaoOuCarga = ""
		if itemDuration > 0 then
			normalItem = false
			local duration = durationTimeString(itemDuration)
			if not duration	then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Item with duration time invalid.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
			itemDuracaoOuCarga = " with ".. duration .." left"
		elseif itemCharges > 0 then
			normalItem = false
			local plural = itemCharges > 1 and "s" or ""
			itemDuracaoOuCarga = " with ".. itemCharges .." charge".. plural .." left"
		end

		local mensagem = "[TRADE OFF] Information:\n\n"
		mensagem = mensagem .. "OFFER: ".. artigoDoItemInfo .." ".. nomeDoItemInfo .. (normalItem and "" or (itemDuracaoOuCarga ~= "" and itemDuracaoOuCarga or ""))

		if itemInfoItemType:isContainer() then
			local quantidadeNoContainer = 0
			local itensContainerBancoDeDados = db.storeQuery("SELECT * FROM `trade_off_container_items` WHERE `offer_id` = ".. ofertaID)
			if itensContainerBancoDeDados ~= false then
				local itemsContainerMessage = "("
				while itensContainerBancoDeDados ~= false do
					quantidadeNoContainer = quantidadeNoContainer + 1
					local subID = result.getNumber(itensContainerBancoDeDados, "item_id")
					local subCharges = result.getNumber(itensContainerBancoDeDados, "item_charges")
					local subDuration = result.getNumber(itensContainerBancoDeDados, "item_duration")
					local subItemCount = result.getNumber(itensContainerBancoDeDados, "count")

					normalItem = true
					local subItemInfo = ItemType(subID)
					local subItemArtigo = (subItemCount > 1 and subItemCount or (subItemInfo:getArticle() ~= "" and subItemInfo:getArticle() or ""))
					local subItemName = (subItemCount > 1 and subItemInfo:getPluralName() or subItemInfo:getName())

					itemDuracaoOuCarga = ""
					if subDuration > 0 then
						normalItem = false
						local duration = durationTimeString(subDuration)
						if not duration	then
							player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Container item with duration time invalid.")
							player:getPosition():sendMagicEffect(CONST_ME_POFF)
							return false
						end
						itemDuracaoOuCarga = " with ".. duration .." left"
					elseif subCharges > 0 then
						normalItem = false
						local plural = subCharges > 1 and "s" or ""
						itemDuracaoOuCarga = " with ".. subCharges .." charge".. plural .." left"
					end

					if not result.next(itensContainerBancoDeDados) then
						itemsContainerMessage = itemsContainerMessage .. subItemArtigo .. " " .. subItemName .. (normalItem and "" or (itemDuracaoOuCarga ~= "" and itemDuracaoOuCarga or "")) ..").\n"
						break
					else
						itemsContainerMessage = itemsContainerMessage .. subItemArtigo .. " " .. subItemName .. (normalItem and "" or (itemDuracaoOuCarga ~= "" and itemDuracaoOuCarga or "")) ..", "
					end
				end

				mensagem = mensagem .." with ".. quantidadeNoContainer .." items inside.\n"
				mensagem = mensagem ..itemsContainerMessage
			end

			result.free(itensContainerBancoDeDados)
		else
			mensagem = mensagem ..".\n"
		end

		local tiposDeOferta = {[1] = "Item", [2] = "Container", [3] = "Trade"}
		local oferta = isTrade > 0 and tiposDeOferta[3] or tiposDeOferta[tipoDeOferta]

		if isTrade == 0 then -- dinheiro como pagamento
			mensagem = mensagem .. "PRICE: ".. cost .." gold coins.\n"
		else -- item como pagamento
			local costItemType = ItemType(cost)
			local costItemCount = (costCount > 1 and costCount or (costItemType:getArticle() ~= "" and costItemType:getArticle() or ""))
			local costItemName = (costCount > 1 and costItemType:getPluralName() or costItemType:getName())
			mensagem = mensagem .. "PRICE: ".. costItemCount .." ".. costItemName ..".\n"
		end

		mensagem = mensagem .. "TYPE: ".. oferta ..".\n"
		mensagem = mensagem .. "ADDED: ".. os.date("%d/%m/%Y at %X%p", addedDate) ..".\n"

		local resultId = db.storeQuery("SELECT `name` FROM `players` WHERE `id` = ".. playerID)
		if not resultId then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Invalid seller name.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local playerName = result.getString(resultId, "name")
		result.free(resultId)

		mensagem = mensagem .. "ADDED BY: ".. playerName ..".\n"

		if config.infoOnPopUp then
			player:popupFYI(mensagem)
		else
			player:sendTextMessage(config.infoMsgType, mensagem)
		end

		return false

	-- !tradeoff buy
	elseif palavra[1] == "buy" then

		if not palavra[2] then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please enter the offerID you want to know about.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if not isNumber(palavra[2]) then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please, insert only numbers.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local ofertaID = tonumber(palavra[2])
		local queryResult = db.storeQuery("SELECT * FROM `trade_off_offers` WHERE `id` = ".. ofertaID .." AND `sold` = 0")
		if not queryResult then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] Please, insert a valid offer ID.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local vendedorId = result.getNumber(queryResult, "player_id")
		local compradorId = player:getGuid()
		if compradorId == vendedorId then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You can not buy your own offer.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		local itemID = result.getNumber(queryResult, "item_id")
		local itemCount = result.getNumber(queryResult, "item_count")
		local itemCharges = result.getNumber(queryResult, "item_charges")
		local itemDuration = result.getNumber(queryResult, "item_duration")
		local isTrade = result.getNumber(queryResult, "item_trade")
		local pagamento = result.getNumber(queryResult, "cost")
		local costCount = result.getNumber(queryResult, "cost_count")
		result.free(queryResult)

		local compradorCidadeId = player:getTown():getId()
		local compradorDepot = player:getDepotChest(compradorCidadeId, true)
		if not compradorDepot then
			player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The city you live in has no depot.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
			return false
		end

		if isTrade == 1 then
			local itemDoSlot = player:getSlotItem(CONST_SLOT_AMMO)
			if not itemDoSlot then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The item requested in the offer must be in the ammunition slot.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local itemDoSlotId = itemDoSlot:getId()
			if itemDoSlotId == 0 then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The item requested in the offer must be in the ammunition slot.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local itemDoPagamento = ItemType(pagamento)
			local itemCostName = (costCount > 1 and itemDoPagamento:getPluralName() or itemDoPagamento:getName())
			local itemCostCount = (costCount > 1 and costCount or (itemDoPagamento:getArticle() ~= "" and itemDoPagamento:getArticle() or ""))

			if player:getItemCount(pagamento) < costCount then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have ".. itemCostCount .." ".. itemCostName .." to buy this offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if itemDoSlot:getCount() < costCount then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have ".. itemCostCount .." ".. itemCostName .." to buy this offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			local cargasDoItemDoSlot = itemDoSlot:getCharges()
			local cargasDoItemDoPagamento = itemDoPagamento:getCharges()

			if cargasDoItemDoSlot and cargasDoItemDoPagamento then
				if cargasDoItemDoSlot < cargasDoItemDoPagamento then
					player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The ".. itemCostName .." needs to be brand new.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end

			local duration = itemDoSlot:getDuration()
			if duration then
				if duration > 0 then
					player:sendTextMessage(config.errorMsgType, "[TRADE OFF] The ".. itemCostName .." needs to be brand new.")
					player:getPosition():sendMagicEffect(CONST_ME_POFF)
					return false
				end
			end

			if itemDoSlot:remove(costCount) then
				db.query("UPDATE `trade_off_offers` SET `sold` = 1 WHERE `id` = ".. ofertaID)
			else
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have ".. itemCostCount .." ".. itemCostName .." to buy this offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
		else
			if player:getTotalMoney() < pagamento then
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have enough money to buy this offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end

			if player:removeTotalMoney(pagamento) then
				db.query("UPDATE `trade_off_offers` SET `sold` = 1 WHERE `id` = ".. ofertaID)
			else
				player:sendTextMessage(config.errorMsgType, "[TRADE OFF] You don't have enough money to buy this offer.")
				player:getPosition():sendMagicEffect(CONST_ME_POFF)
				return false
			end
		end

		local parcel = Game.createItem(ITEM_PARCEL)
		local item
		if itemDuration > 0 then
			item = Game.createItem(itemID)
			item:setAttribute(ITEM_ATTRIBUTE_DURATION, itemDuration)
		elseif itemCharges > 0 then
			item = Game.createItem(itemID)
			item:setAttribute(ITEM_ATTRIBUTE_CHARGES, itemCharges)
		else
			item = Game.createItem(itemID, itemCount)
		end

		if ItemType(itemID):isContainer() then
			local itemsInside = db.storeQuery("SELECT * FROM `trade_off_container_items` WHERE `offer_id` = ".. ofertaID)
			if itemsInside ~= false then
				repeat
					local subID = result.getNumber(itemsInside, "item_id")
					local subCharges = result.getNumber(itemsInside, "item_charges")
					local subDuration = result.getNumber(itemsInside, "item_duration")
					local subCount = result.getNumber(itemsInside, "count")

					local subItem
					if subDuration > 0 then
						subItem = Game.createItem(subID)
						subItem:setAttribute(ITEM_ATTRIBUTE_DURATION, subDuration)
					elseif subCharges > 0 then
						subItem = Game.createItem(subID)
						subItem:setAttribute(ITEM_ATTRIBUTE_CHARGES, subCharges)
					else
						subItem = Game.createItem(subID, subCount)
					end

					item:addItemEx(subItem)

				until not result.next(itemsInside)
				result.free(itemsInside)

				db.query("DELETE FROM trade_off_container_items WHERE offer_id = ".. ofertaID)
			end
		end

		parcel:addItemEx(item)

		local compradorCidadeNome = Town(compradorCidadeId):getName()
		local letter = Game.createItem(2598)
		letter:setAttribute(ITEM_ATTRIBUTE_TEXT, "[TRADE OFF] You bought the offer with ID: ".. ofertaID ..", the respective offer items were sent to ".. compradorCidadeNome .." depot.")
		parcel:addItemEx(letter)
		compradorDepot:addItemEx(parcel)
		player:sendTextMessage(config.successMsgType, "[TRADE OFF] You bought the offer with ID: ".. ofertaID ..", the respective offer items were sent to ".. compradorCidadeNome .." depot.")

		return false
	end

	return false
end
trade_offline_talkaction:separator(" ")
trade_offline_talkaction:register()

-- creaturescript: onLogin
local trade_offline_login = CreatureEvent("trade_offline_login")
function trade_offline_login.onLogin(player)
	local playerId = player:getGuid()

	local resultId  = db.storeQuery("SELECT * FROM `trade_off_offers` WHERE `player_id` = ".. playerId .." AND `sold` = 1")
	if resultId ~= false then
		repeat
			local ofertaID = result.getNumber(resultId, "id")
			local playerId_database = result.getNumber(resultId, "player_id")
			local isTrade = result.getNumber(resultId, "item_trade")
			local pagamento = result.getNumber(resultId, "cost")
			local costCount = result.getNumber(resultId, "cost_count")

			local cidadeId = player:getTown():getId()
			local depot = player:getDepotChest(cidadeId, true)
			if depot then
				if isTrade == 1 then
					local parcel = Game.createItem(ITEM_PARCEL)
					local carta = Game.createItem(2598)
					local compradorCidadeNome = Town(cidadeId):getName()
					carta:setAttribute(ITEM_ATTRIBUTE_TEXT, "[TRADE OFF] You sold your offer with ID: ".. ofertaID ..".")
					parcel:addItemEx(carta)
					local EnviarPagamento = Game.createItem(pagamento, costCount)
					parcel:addItemEx(EnviarPagamento)
					depot:addItemEx(parcel)
					player:sendTextMessage(config.successMsgType, "[TRADE OFF] You sold your offer with ID: ".. ofertaID .." and your payment went to ".. compradorCidadeNome .." depot.")
					db.asyncQuery("DELETE FROM `trade_off_offers` WHERE `id` = ".. ofertaID)
				else
					if player:setBankBalance(player:getBankBalance() + pagamento) then
						player:sendTextMessage(config.successMsgType, "[TRADE OFF] You sold your offer with ID: ".. ofertaID .." and ".. pagamento .." gold coins were transfered to your bank account.")
						db.asyncQuery("DELETE FROM `trade_off_offers` WHERE `id` = ".. ofertaID)
					else
						player:sendTextMessage(config.errorMsgType, "[TRADE OFF] There was a problem with your bank account.")
						player:getPosition():sendMagicEffect(CONST_ME_POFF)
					end
				end
			else
				print(">> [TRADE OFF] Error in player depot:  ".. player:getName() ..".")
			end

		until not result.next(resultId)
		result.free(resultId)
	end

	local resultId  = db.storeQuery("SELECT * FROM `trade_off_offers` WHERE `player_id` = ".. playerId .." AND `sold` = 2")
	if resultId ~= false then
		repeat
			local cidadeId = player:getTown():getId()
			local depot = player:getDepotChest(cidadeId, true)
			if depot then
				local ofertaID = result.getNumber(resultId, "id")
				local itemID = result.getNumber(resultId, "item_id")
				local quantidadeDoItem = result.getNumber(resultId, "item_count")
				local cargasDoItem = result.getNumber(resultId, "item_charges")
				local duracaoDoItem = result.getNumber(resultId, "item_duration")

				local item
				if duracaoDoItem > 0 then
					item = Game.createItem(itemID)
					item:setAttribute(ITEM_ATTRIBUTE_DURATION, duracaoDoItem)
				elseif cargasDoItem > 0 then
					item = Game.createItem(itemID)
					item:setAttribute(ITEM_ATTRIBUTE_CHARGES, cargasDoItem)
				else
					item = Game.createItem(itemID, quantidadeDoItem)
				end

				local itemRemovidoItemType = ItemType(itemID)
				local itemRemovidoIsContainer = itemRemovidoItemType:isContainer()
				if itemRemovidoIsContainer then
					local selecionarItensDentroDoContainer = db.storeQuery("SELECT * FROM `trade_off_container_items` WHERE `offer_id` = ".. ofertaID)
					if selecionarItensDentroDoContainer ~= false then
						repeat
							local idDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_id")
							local cargasDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_charges")
							local duracaoDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "item_duration")
							local quantidadeDoItemDentroDoContainer = result.getNumber(selecionarItensDentroDoContainer, "count")

							local itemDentroDoContainer
							if duracaoDoItemDentroDoContainer > 0 then
								itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer)
								itemDentroDoContainer:setAttribute(ITEM_ATTRIBUTE_DURATION, duracaoDoItemDentroDoContainer)
							elseif cargasDoItemDentroDoContainer > 0 then
								itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer)
								itemDentroDoContainer:setAttribute(ITEM_ATTRIBUTE_CHARGES, cargasDoItemDentroDoContainer)
							else
								itemDentroDoContainer = Game.createItem(idDoItemDentroDoContainer, quantidadeDoItemDentroDoContainer)
							end

							item:addItemEx(itemDentroDoContainer)

						until not result.next(selecionarItensDentroDoContainer)
						result.free(selecionarItensDentroDoContainer)

						db.query("DELETE FROM `trade_off_container_items` WHERE `offer_id` = ".. ofertaID)
					end
				end

				local parcel = Game.createItem(ITEM_PARCEL)
				parcel:addItemEx(item)

				local cidadeNome = Town(cidadeId):getName()
				local carta = Game.createItem(2598)
				carta:setAttribute(ITEM_ATTRIBUTE_TEXT, "[TRADE OFF] Your offer with ID: ".. ofertaID .." expired.")
				parcel:addItemEx(carta)
				depot:addItemEx(parcel)
				player:sendTextMessage(config.successMsgType, "[TRADE OFF] Your offer with ID: ".. ofertaID .." expired, the respective offer items were sent to ".. cidadeNome .." depot.")

				db.asyncQuery("DELETE FROM `trade_off_offers` WHERE `id` = ".. ofertaID)
			else
				print(">> [TRADE OFF] Error in player depot:  ".. player:getName() ..".")
			end

		until not result.next(resultId)
		result.free(resultId)
	end
	return true
end
trade_offline_login:register()

-- globalevents: onStartup
local trade_offline_globalevents = GlobalEvent("trade_offline_globalevents")
function trade_offline_globalevents.onStartup()
	local timeStamp = os.time() - (86400 * (config.diasParaRemoverAOferta * 24))
	local totalClear = 0
	local resultId = db.storeQuery("SELECT COUNT(*) AS `count` FROM `trade_off_offers` WHERE `sold` = 0 AND `date` <= ".. timeStamp)
	if resultId ~= false then
		totalClear = result.getNumber(resultId, 'count')
		result.free(resultId)
		if totalClear > 0 then
			db.query("UPDATE `trade_off_offers` SET `sold` = 2 WHERE `date` <= ".. timeStamp)
			print(">> [TRADE OFF] ".. totalClear .." deleted offers in system.")
		end
	end
end
trade_offline_globalevents:register()