-- Config Custom--

CUSTOM = {
	-- actions
	dailyReward = {
		-- [dia] = {itemId, itemCount, "ordem"},
		[1] = {2160, 1, "first"},
		[2] = {2160, 2, "second"},
		[3] = {2160, 3, "third"},
		[4] = {2160, 4, "fourth"},
		[5] = {2160, 5, "fifth"},
		[6] = {12328, 6, "sixth"}, -- stamina refill
		[7] = {2160, 7, "seventh"}
	},
	
	-- creaturescripts
	freeBlessMaxLevel = 50,
	maxAccPorIp = 4,

	-- globalevents
	lottery = {
		interval = "3 hour",
		rewards = { -- {item_id, item_count},
			{2160, 50}, -- 50 crystal coins
			{2472, 1}, -- magic plater armor
			{2470, 1}, -- golden legs
		},
		website = true
	},

	-- movements
	trainersConfig = {
		first_room_pos = Position(985, 858, 9), -- posicao da primeira pos (linha 1 coluna 1)
		distX= 12, -- distancia em X entre cada sala (de uma mesma linha)
		distY= 10, -- distancia em Y entre cada sala (de uma mesma coluna)
		rX= 6, -- numero de colunas
		rY= 8 -- numero de linhas
	},

	-- talkactions
	warSystem = {
		frags = {min = 1, max = 100, standard = 1},
		daysMaxToInviteWar = 30,
	},
	buyHouse = { 
		level = 150,
		onlyPremium = false
	},
	aolValue = 10000,
	allBlessValue = 50000,
	playerTalkactionsCommands = "Player commands:" .. "\n"
		.. "!buyhouse" .. "\n"
		.. "!sellhouse" .. "\n"
		.. "!leavehouse" .. "\n"
		.. "!serverinfo" .. "\n"
		.. "!online" .. "\n"
		.. "!save" .. "\n"
		.. "!kills" .. "\n"
		.. "!aol" .. "\n"
		.. "!bless" .. "\n"
		.. "!addon" .. "\n"
		.. "!tradeoff" .. "\n"
		.. "!shop" .. "\n"
		.. "!war" .. "\n"
		.. "!report" .. "\n"
		.. "!guild" .. "\n"
		.. "!guildpoints" .. "\n"
		.. "!uptime",
	valueForSendGuildBroadcast = 1000,

	tradeOffine = {
		aguardarStorage = Storage.tradeoff_delay,
		levelParaAddOferta = 50,
		maxOfertasPorPlayer = 5,
		precoLimite = 2000000000, -- 2kkk
		goldItems = {
			2148,
			2152,
			2160
		},
		infoOnPopUp = true,
		infoMsgType = MESSAGE_STATUS_CONSOLE_BLUE,
		errorMsgType = MESSAGE_STATUS_CONSOLE_RED,
		successMsgType = MESSAGE_INFO_DESCR,

		valuePerOffer = 500,
		blockedItems = {
			9933,
			2167 -- energy ring
		},
		diasParaRemoverAOferta = 7
	},
	
	guildPoints = {
		executeInterval = 24, -- em horas
		minimumLevel = 80,
		membersNeeded = 4,
		checkDifferentIps = true,
		minimumDifferentIps = 4,
		pointAmount = 10,
		accountStorage = 9999
	}
}
