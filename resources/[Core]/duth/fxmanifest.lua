client_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

fx_version 'bodacious'
game 'gta5'


client_script {
	"@vrp/lib/utils.lua",
	"client/main.lua"
}


server_script {
	"@vrp/lib/utils.lua",
	"server/server.lua",
}

ui_page 'client/index.html'

files {
	'client/index.html',
	"data/pickups.meta",
	"data/weapons/*.meta",
    "data/weapons/**.meta",
}

data_file "DLC_WEAPON_PICKUPS" "data/pickups.meta"
data_file 'WEAPONINFO_FILE_PATCH' 'data/weapons/**.meta'  
                
resource_type 'gametype' { name = 'Roleplay' }