-- Sincronizar roupas que o jogador possui com Znote AAC
-- Então é possível ver quais conjuntos completos do jogador
-- em characterprofile.php

local znote_outfit_list = {
	{ -- Female (girl) outfits 
		136,137,138,139,140,141,142,147,148,
		149,150,155,156,157,158,252,269,270,
		279,288,324,329,336,366,431,433,464,
		466,471,513,514,542,575,578,618,620,
		632,635,636,664,666,683,694,696,698,
		724,732,745,749,759,845,852,874,885,
		900
	},
	{ -- Male (boy) outfits 
		128,129,130,131,132,133,134,143,144,
		145,146,151,152,153,154,251,268,273,
		278,289,325,328,335,367,430,432,463,
		465,472,512,516,541,574,577,610,619,
		633,634,637,665,667,684,695,697,699,
		725,733,746,750,760,846,853,873,884,
		899
	}
}

function onLogin(player)
	-- storage_value + 1000 storages (id de roupa mais alta) não deve ser usado em outro script.
	-- Deve ser idêntico ao Znote AAC config.php: $config['EQ_shower'] -> storage_value
	local storage_value = Storage.znoteSyncoutfit
	-- Loop through outfits
	for _, outfit in pairs(znote_outfit_list[player:getSex() + 1]) do
		if player:hasOutfit(outfit, 3) then 
			if player:getStorageValue(storage_value + outfit) ~= 3 then 
				player:setStorageValue(storage_value + outfit, 3) 
			end
		end
	end
	return true
end
