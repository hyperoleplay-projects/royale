-- function src.CreateTable() 
--     -- 715.02,4175.56,40.71,277.8

--     local model = GetHashKey("prop_rub_table_02")
--     RequestModel(model)
--     while not HasModelLoaded(model) do
--       Citizen.Wait(0)
--     end

--     -- Crie o objeto no local desejado
--     local object = CreateObject(model, 715.02, 4175.56, 40.71, true, true, true)

--     -- Defina a rotação do objeto (opcional)
--     SetEntityRotation(object, 0.0, 0.0, 277.8, 2, true)
-- end

-- RegisterCommand("airdrop", function() 
--     local model = GetHashKey("prop_rub_table_02")
--     RequestModel(model)
--     while not HasModelLoaded(model) do
--       Citizen.Wait(0)
--     end

--     -- Crie o objeto no local desejado
--     local object = CreateObject(model, 714.33, 4176.2-0.5, 40.71-1, true, true, true)

--     -- Defina a rotação do objeto (opcional)
--     SetEntityRotation(object, 0.0, 0.0, 277.8, 2, true)
--     cam.CreateCamAirDrop("CAM_AIRDROP")
--     cam.setActive("CAM_AIRDROP")
--     cam.render("CAM_AIRDROP", true, false, 0)


--     local pickupHash = GetHashKey('PICKUP_HEALTH_STANDARD')
--     local pickup = CreatePickupRotate(pickupHash, 714.23, 4174.88, 41.53 -0.75, 0, 0, 0, 512, 1, 1, 1, pickupHash)
--     local pickup2 = CreatePickupRotate(GetHashKey('PICKUP_ARMOUR_STANDARD'), 714.68, 4174.99, 41.53 -0.75, 0, 0, 0, 512, 1, 1, 1, GetHashKey('PICKUP_ARMOUR_STANDARD'))

-- end)

-- -- Item 1 = 714.23,4174.88,41.53,320.32
-- -- Item 2 = 714.68,4174.99,41.53,274.97
-- -- Item 3 = 714.36,4175.65,41.52,280.63
-- -- Item 4 = 713.91,4176.35,41.53,249.45
-- -- Item 5 = 714.51,4176.44,41.53,272.13