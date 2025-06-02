fx_version 'cerulean'
game 'gta5'

author 'GrossBean'
description 'Gross Bean Juice "Lemonaid" Bar Job for QBCore Framework'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/*.png'
}

shared_scripts {
    '@qb-core/shared.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-inventory',
    'qb-menu',
    'qb-management'
}
