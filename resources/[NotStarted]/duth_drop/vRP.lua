Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")

local SERVER = IsDuplicityVersion()
local CLIENT = not SERVER

if SERVER then
    server = {}
    Tunnel.bindInterface(GetCurrentResourceName(),server)
    client = Tunnel.getInterface(GetCurrentResourceName())
else
    client = {}
    Tunnel.bindInterface(GetCurrentResourceName(),client)
    server = Tunnel.getInterface(GetCurrentResourceName())
end