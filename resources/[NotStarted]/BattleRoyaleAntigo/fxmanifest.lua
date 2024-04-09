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
    "server/api.lua",
    "server/Games.lua",
    "server/Ranking.lua",
    "server/Inventory.lua",
    "server/AntiCheat.lua",
    "server/BattlePass.lua",
    "server/AimLab.lua",
    "server/Teams.lua",
    "server/Loja.lua",
    "server/Admin/commands_admin.lua",
    "server/Admin/Groups.lua",
    "server/Commands/Pvp_commands.lua",
    "server/Commands/Player_commands.lua",
    "server/Events/BarbershopInit.lua",
    "server/Events/BanControl.lua",
    "server/Events/MenuNUI.lua",
    "server/Events/DiscordSync.lua",
    "server/DataBase/prepares.database.lua",
}        


ui_page 'web/build/index.html'


files {
	'web/build/index.html',
	'web/build/**/*',
}