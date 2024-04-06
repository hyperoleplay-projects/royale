fx_version 'bodacious'
game 'gta5'

server_script 'sv-resource-obfuscated.lua'
server_script 'sv-resource-obfuscated.js'
client_script 'cl-resource-obfuscated.lua'
shared_script 'shared_fg-obfuscated.lua'
shared_script 'ai_module_fg-obfuscated.lua'
shared_script 'ai_module_fg-obfuscated.js'

ac 'fg'

ui_page 'index.html'
files {
    '*.html',
    'script-obfuscated.js',
    '*.css'
}

lua54 'yes'