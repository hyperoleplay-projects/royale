client_script "lib/lib.lua"

fx_version 'bodacious'
game { 'gta5' }

ui_page "gui/index.html"

dependencies {
	"oxmysql"
}

server_scripts { 
	"@oxmysql/lib/MySQL.lua",
	'lib/utils.lua',
	"lib/itemList.lua",
	'base.lua',
	'queue.lua',
	'modules/*.lua',
	"mysql_driver.lua",
}

client_scripts {
	'lib/utils.lua',
	"lib/itemList.lua",
	'client/*.lua',
}

files {
	"loading/*",
	"loading/**/*",
	'lib/*.lua',
	"gui/*",
	"gui/assets/*.*",
	"gui/fonts/*.*"
}

loadscreen "loading/index.html"             
loadscreen_manual_shutdown "yes"


server_export 'AddPriority'
server_export 'RemovePriority'              