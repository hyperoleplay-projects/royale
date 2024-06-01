shared_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"

fx_version "adamant"
game "gta5"

--lua54 'yes'

dependency "vrp"

ui_page "character-nui/index.html"

files {
    "character-nui/index.html",
    "character-nui/style.css",
    "character-nui/reset.css",
    "character-nui/vue.js",
    "character-nui/**",
}

server_scripts {
  '@vrp/lib/utils.lua',
  'server.lua'
}

client_scripts {
  '@vrp/lib/utils.lua',
  'client.lua'
}
                                                        