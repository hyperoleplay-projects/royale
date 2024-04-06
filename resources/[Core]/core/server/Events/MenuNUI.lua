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
    local source = source
    local user_id = vRP.getUserId(source)

    if type == "Clothes" then
        clientAPI.CreateMenuNUI(source, {
            items = Player(source).state.userClothes,
            title = "ROUPAS",
            type = "ROUPAS"
        })
    
        clientAPI.StatusMenuUI(source, true, true, "ROUPAS")
        clientAPI.UpdateClothes(source, vRP.getUData(user_id,"Clothings"), false)
        Player(source).state.clothesNUI = true
    end

    if type == "Barbearia" then
        clientAPI.CreateMenuNUI(source, {
            items = Player(source).state.userBarbearia,
            title = "BARBEARIA",
            type = "BARBEARIA"
        })
    
        clientAPI.StatusMenuUI(source, true, true, "BARBEARIA")
        Player(source).state.barbeariaNUI = true
    end

    if type == "Tatuagem" then
        clientAPI.CreateMenuNUI(source, {
            items = Player(source).state.userTatuagens,
            title = "TATUAGEM",
            type = "TATUAGEM"
        })
    
        clientAPI.StatusMenuUI(source, true, true, "TATUAGEM")
        Player(source).state.TatuagemNUI = true
    end

    if type == "Skins" then
        clientAPI.SendNUI(source, {
            status = true,
            page = "/dashboard/collection",
            dashboard = true,
        })
    end
end