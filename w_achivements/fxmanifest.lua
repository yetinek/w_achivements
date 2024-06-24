fx_version "bodacious"
game "gta5"
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server.lua'
}

client_scripts {
	"config.lua",
	"client.lua"
}

ui_page 'html/index.html'

files {
    'html/index.html',
	'html/assets/*.css',
	'html/assets/*.js',
	'html/assets/*.png',
	'html/assets/*.wav',
}