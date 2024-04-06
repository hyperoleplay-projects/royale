AddEventHandler('onClientMapStart',function()
	exports.spawnmanager:setAutoSpawn(true)
	exports.spawnmanager:forceRespawn()
end)

RegisterNUICallback(GetCurrentResourceName(), function()
  TriggerServerEvent(GetCurrentResourceName())
end)
