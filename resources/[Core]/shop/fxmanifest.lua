fx_version 'adamant'
game 'gta5'

server_script 'config.lua'

shared_scripts {
    'shared/*'
}

version '1.8.1'

lua54 'yes'

server_scripts {
    'server/connection/*',
    'server/core/*',
    'server/ext/**/*', -- Lazy load all extensions
    'server/*', -- inject essential code
    'server/plugins/*', -- plugins always in last
}

client_scripts {
    'client/*'
}

files { 'html/*' }
ui_page 'html/index.html'