-----------------------------------------------------------------------------------------------------------------------------------------
--  LoadConfigs - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.LoadConfigs() 
    if LocalPlayer.state.fpsSettings == "true" then
        SetTimecycleModifier("cinema")
    else
        SetTimecycleModifier("default")
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  fps - Function
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fps",function()
    if LocalPlayer.state.fpsSettings == "true" then
        SetTimecycleModifier("default")
        serverAPI.SetFpsConfig("false")
    else
        SetTimecycleModifier("cinema")
        serverAPI.SetFpsConfig("true")
    end
end)
