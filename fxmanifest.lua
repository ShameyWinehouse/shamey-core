game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

client_scripts {
    'client/*.lua',
}

server_scripts { 
    'server/*.lua',
    "@oxmysql/lib/MySQL.lua",
}

shared_scripts {
    '@jo_libs/init.lua',
    '30log.lua',
    'config.lua',
	'shared.lua',
    'shared/*',
    'shared/**/*',
}

ui_page 'html/ui.html'
files {
	'html/style.css',
	'html/style.js',
	'html/ui.html',
    'html/assets/audio/*',
}

server_exports { 
    'AbsolutelyHasJobInJoblistServer', 
    'AbsolutelyHasJobAndGradeServer', 
    'AbsolutelyHasJobAndGradeInJobMatrixServer',
    'UtilityJobIsInJoblist', 
    'UtilityJobAndGradeIsInJobMatrix',
    'UtilityAbsolutelyJobAndGradeMatch',
    'getWeaponDegradation',
    'findAllPlayersWithJobInJobArray',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
    "jo_libs",
}

jo_libs {
    "hook",
    "me",
    "callback",
    "date",
    "notification",
}


author 'Shamey Winehouse'
description 'License: GPL-3.0-only'