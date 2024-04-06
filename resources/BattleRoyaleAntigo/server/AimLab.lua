-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinAimLab - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.JoinAimLab() 
    local source = source
	local user_id = vRP.getUserId(source)

    if not Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane and not Player(source).state.inAimLab then
        Player(source).state.inAimLab = true
        Player(source).state.inDashboard = false
        vRP.clearInventory(user_id)
        clientAPI.killGod(source)
        clientAPI.CloseLobby(source)
        Player(source).state.Buttons = true
        SetPlayerRoutingBucket(source, 100+user_id)
        clientAPI.JoinAimLab(source)
    else
        AddNotify(source, user_id, "AimLab", "Você está na fila de partidas, sai dela antes de entrar no AimLab.", 1200)
    end
end