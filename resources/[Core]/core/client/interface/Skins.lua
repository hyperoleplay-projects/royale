local skinCategories = {
    faca = "faca",
    rifle = "rifle",
    smg = "smg",
    pistol = "pistol"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- isSkinEquipped - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function isSkinEquipped(category)
    for k, v in pairs(LocalPlayer.state.userSkins) do
        if v.skin_category == category and v.skin_status == "true" then
            return true
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BarbeariaClick - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('SkinClick', function(dataR, cb)
    if dataR.type == "Equipar" then
        local skinCategory = skinCategories[LocalPlayer.state.userSkins[dataR['skin'].spawnName].skin_category]
    
        if skinCategory and isSkinEquipped(skinCategory) then
            local errorMessage = "Você já tem uma <b>%s</b> equipada, desequipe-a primeiro."
            
            cb({ status = false })
            return TriggerEvent("Notify", "negado", errorMessage:format(skinCategory))
        end
        controllerApi.sendServerEvent('UpdatePed', { type = "Skin", status = "true", id = dataR['skin'].id })
        cb({ status = true })
    end

    if dataR.type == "Desequipar" then
        controllerApi.sendServerEvent('UpdatePed', { type = "Skin", status = "false", id = dataR['skin'].id })
        cb({ status = true })
    end

end)