fx_version "cerulean"

description "Basic React (TypeScript) & Lua Game Scripts Boilerplate"
author "Project Error"
version '1.0.0'
repository 'https://github.com/project-error/fivem-react-boilerplate-lua'

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

client_scripts {
    "@api/utils.lua",
    "@vrp/lib/utils.lua",
    "@vrp/lib/itemList.lua",
    "commonApi/config.lua",
    "commonApi/index.lua",
    "commonApi/game/shared.lua",
    "client/api.lua",
    "client/**/*",
}

server_scripts {
    "@vrp/lib/utils.lua",
    "@vrp/lib/itemList.lua",
    "commonApi/index.lua",
    "commonApi/config.lua",
    "server/Util/function_utils.lua",
    "commonApi/game/shared.lua",
    "server/Server.lua",

    "server/Events.lua",
    "server/Game.lua",
    "server/Ranking.lua",
    "server/Inventory.lua",
    "server/BattlePass.lua",
    "server/Premium.lua",
    "server/Loja.lua",
    
    "server/Api/*",
    "server/Commands/*",
    "server/Events/*",
    "server/DataBase/*",
}        

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**/*.*',
}