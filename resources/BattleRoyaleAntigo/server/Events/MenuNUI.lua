-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
ClientMenuNUI = Tunnel.getInterface("MenuNUI")
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function reMapData(game_data)
	-- print(dump(game_data))
	-- RED
	local cntRed = 0
	local _redList = game_data
	game_data = {}
	for k,v in pairs(_redList) do
		cntRed = cntRed + 1
		game_data[cntRed] = v
	end
	return game_data
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OpenMenuNUI - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.OpenMenuNUI(type) 
    local user_id = vRP.getUserId(source)

    if type == "Clothes" then
        ClientMenuNUI.CreateMenuNUI(source, {
            items = reMapData(Player(source).state.userClothes),
            title = "ROUPAS",
            description = "COLOCAR DESCRIÇÃO AQUI",
            type = "ROUPAS"
        })
    
        ClientMenuNUI.StatusMenuUI(source, true, true)
        ClientMenuNUI.UpdateClothes(source, vRP.getUData(user_id,"Clothings"), false)
        Player(source).state.clothesNUI = true
        TriggerClientEvent("BuildUI", source, "LobbyInfos", { status = false })
    end

    if type == "Barbearia" then
        ClientMenuNUI.CreateMenuNUI(source, {
            items = reMapData(Player(source).state.userBarbearia),
            title = "BARBEARIA",
            description = "COLOCAR DESCRIÇÃO AQUI",
            type = "Barbearia"
        })
    
        ClientMenuNUI.StatusMenuUI(source, true, true)
        Player(source).state.barbeariaNUI = true
        TriggerClientEvent("BuildUI", source, "LobbyInfos", { status = false })
    end

    if type == "Tatuagem" then
        ClientMenuNUI.CreateMenuNUI(source, {
            items = reMapData(Player(source).state.userTatuagens),
            title = "TATUAGEM",
            description = "COLOCAR DESCRIÇÃO AQUI",
            type = "Tatuagem"
        })
    
        ClientMenuNUI.StatusMenuUI(source, true, true)
        Player(source).state.TatuagemNUI = true
        TriggerClientEvent("BuildUI", source, "LobbyInfos", { status = false })
    end

    if type == "Skins" then
        ClientMenuNUI.CreateMenuNUI(source, {
            items = reMapData(Player(source).state.userSkins),
            title = "SKINS",
            description = "COLOCAR DESCRIÇÃO AQUI",
            type = "Skins"
        })
    
        ClientMenuNUI.StatusMenuUI(source, true, false)
        -- Player(source).state.TatuagemNUI = true
        TriggerClientEvent("BuildUI", source, "LobbyInfos", { status = false })
    end


    -- if type == "AirDrop" then
    --     ClientMenuNUI.CreateMenuNUI(source, {
    --         items = reMapData(Config.AirDropItems),
    --         title = "AIRDROP",
    --         description = "Personalize sua própria caixa de air drop e solicite-a durante as partidas! Utilize seus Duth Points para adicionar itens valiosos!",
    --         type = "AirDrop"
    --     })
    
    --     ClientMenuNUI.StatusMenuUI(source, true, false)
    --     clientAPI.CreateTable(source, reMapData(Player(source).state.userAirDrop))
    --     -- Player(source).state.TatuagemNUI = true
    --     TriggerClientEvent("BuildUI", source, "LobbyInfos", { status = false })
    -- end
end