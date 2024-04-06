client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

 fx_version 'bodacious'
game 'gta5'

resource_type 'map' { gameTypes = { fivem = true } }

map 'map.lua'

client_scripts {
    'mapmanager_shared.lua',
    'mapmanager_client.lua',
    'client/empty.lua',
    'spawnmanager.lua'
}

server_scripts {
    'mapmanager_shared.lua',
    'mapmanager_server.lua',
    'server/host_lock.lua'
}

--Map Managers
server_export 'getCurrentGameType'
server_export 'getCurrentMap'
server_export 'changeGameType'
server_export 'changeMap'
server_export 'doesMapSupportGameType'
server_export 'getMaps'
server_export 'roundEnded'
--MapManager
export 'getRandomSpawnPoint'
export 'spawnPlayer'
export 'addSpawnPoint'
export 'removeSpawnPoint'
export 'loadSpawns'
export 'setAutoSpawn'
export 'setAutoSpawnCallback'
export 'forceRespawn'                                                                      