cam = {
    cams = {},


    PointCamAtPedBone = function(name, ped, number)
        PointCamAtPedBone(cam.cams[name], ped, number, 0.0, 0.0, 0.0)

    end,
    CreateCamWithParams = function(name, offset2) 
        local c = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", offset2, 0.0 ,0.0, 0, 60.00, false, 0)
        cam.cams[name] = c 
    end,

    CreateCamLojaClothes = function(name) 
        local c = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -796.4598, 328.463, 190.7135, f(0), f(0), f(90.023139953613), f(45),true,2)
        cam.cams[name] = c 
    end,

    CreateCamAirDrop = function(name) 
        local c = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 716.43,4176.0,40.71+0.8, f(-21), f(0), f(96.38), f(55),true,2)
        cam.cams[name] = c 
    end,


    CreateLobby = function(name) 
        local c = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z+0.7, f(0), f(0), f(Config.CamCoords.w), f(48),true,2)
        cam.cams[name] = c 
    end,

    PointCamAtEntity = function(name, object) 
        if cam.cams[name] ~= nil then
            PointCamAtEntity(cam.cams[name], object, 0,0,0, true)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,
    create = function(name)
        local c = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        cam.cams[name] = c 
    end,

    delete = function(name)
        if cam.cams[name] ~= nil then
            RenderScriptCams(0, 0, 0, 0, 1)
            SetCamActive(cam.cams[name], false)
            DestroyCam(cam.cams[name], false)
            ClearFocus()
            cam.cams[name] = nil
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,    

    setActive = function(name, bool)
        if cam.cams[name] ~= nil then
            SetCamActive(cam.cams[name], bool)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,

    setPos = function(name, pos)
        if cam.cams[name] ~= nil then
            SetFocusPosAndVel(pos.xyz, 0.0, 0.0, 0.0)
            SetCamCoord(cam.cams[name], pos.xyz)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,    

    setFov = function(name, fov)
        if cam.cams[name] ~= nil then
            SetCamFov(cam.cams[name], fov)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,

    lookAtCoords = function(name, pos)
        if cam.cams[name] ~= nil then
            PointCamAtCoord(cam.cams[name], pos.xyz)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,

    attachToEntity = function(name, entity, xOffset, yOffset, zOffset, isRelative)
        if cam.cams[name] ~= nil then
            AttachCamToEntity(cam.cams[name], entity, xOffset, yOffset, zOffset, isRelative)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,

    attachToVehicleBone = function(name, vehicle, boneIndex, relativeRotation, rotX, rotY, rotZ, offX, offY, offZ, fixedDirection)
        if cam.cams[name] ~= nil then
            AttachCamToVehicleBone(cam.cams[name], vehicle, boneIndex, relativeRotation, rotX, rotY, rotZ, offX, offY, offZ, fixedDirection)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,

    render = function(name, render, animation, time)
        if cam.cams[name] ~= nil then
            SetCamActive(cam.cams[name], true)
            RenderScriptCams(render, animation, time, 1, 1)
        else
            -- print("^2WARNING: ^7La cam "..name.." n'éxiste pas !")
        end
    end,

    switchToCam = function(name, newName, time)
        if cam.cams[name] ~= nil then
            if cam.cams[newName] ~= nil then
                SetCamActiveWithInterp(cam.cams[name], cam.cams[newName], time, 1, 1)
            end
        end
    end,

    rotation = function(name, rotX, rotY, rotZ)
        if cam.cams[name] ~= nil then
            SetCamRot(cam.cams[name], rotX, rotY, rotZ, 2)
        end
    end,
    
}
