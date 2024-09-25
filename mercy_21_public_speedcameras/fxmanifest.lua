fx_version 'cerulean'
game 'gta5'
author 'P4NDAzzGaming/tom-osborne/Turtle'
shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  '@qb-core/shared/locale.lua',
  'locales/*.lua',
}
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/main.lua'
}
client_scripts {
  'client/main.lua', 
  'client/disablecam.lua',
}
ui_page('html/index.html')
files {
  'html/index.html'
}

dependencies {
  'bl_ui' -- Name of the bl_ui resource
}

lua54 'yes'

-- Credits
-- Original Creator  https://github.com/P4NDAzzGaming/esx_speedcamera
-- Then this dude tom-osborne pulled it from homie ^ https://github.com/tom-osborne/qb-speedcameras
-- Now here I am ! Hi Thank you for downloading and hope it is fun ! Remember you can add onto this ! :-)