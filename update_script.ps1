$path = "c:\Legendary Roleplay\gamemodes\lrpop3-1 (1)-1-1-1.pwn"
$content = [System.IO.File]::ReadAllText($path)

# 1. Define AUTO_DESTROYVEH_TIME
$content = $content.Replace('#define WEATHER_TIME  1// 1 hr', '#define WEATHER_TIME  1// 1 hr' + [Environment]::NewLine + '#define AUTO_DESTROYVEH_TIME 60 // 60 minutes')

# 2. Implement AutomaticDestroyVeh and fix DestroyVeh header
$targetDestroyVeh = 'forward DestroyVeh(playerid);' + [Environment]::NewLine + 'public DestroyVeh(playerid)'
$replacementDestroyVeh = 'forward AutomaticDestroyVeh();' + [Environment]::NewLine + 'public AutomaticDestroyVeh()' + [Environment]::NewLine + '{' + [Environment]::NewLine + '    new count = 0;' + [Environment]::NewLine + '    for(new i = 1; i < MAX_VEHICLES; i ++)' + [Environment]::NewLine + '    {' + [Environment]::NewLine + '        if(adminVehicle{i})' + [Environment]::NewLine + '        {' + [Environment]::NewLine + '            DestroyVehicle(i);' + [Environment]::NewLine + '            adminVehicle{i} = false;' + [Environment]::NewLine + '            count++;' + [Environment]::NewLine + '        }' + [Environment]::NewLine + '    }' + [Environment]::NewLine + '    if(count > 0)' + [Environment]::NewLine + '    {' + [Environment]::NewLine + '        SendClientMessageToAll(COLOR_YELLOW, "[SYSTEM]: "WHITE"server destroyed all admin spawned vehicles.");' + [Environment]::NewLine + '    }' + [Environment]::NewLine + '    return 1;' + [Environment]::NewLine + '}' + [Environment]::NewLine + [Environment]::NewLine + 'forward DestroyVeh(playerid);' + [Environment]::NewLine + 'public DestroyVeh(playerid)'
$content = $content.Replace($targetDestroyVeh, $replacementDestroyVeh)

# 3. Fix syntax error in SendClientMessageToAll
$targetMessage = 'SendClientMessageToAll(COLOR_YELLOW, "[SYSTEM]: "WHITE"server destroyed all admin spawned vehicles.";'
$replacementMessage = 'SendClientMessageToAll(COLOR_YELLOW, "[SYSTEM]: "WHITE"server destroyed all admin spawned vehicles.");'
$content = $content.Replace($targetMessage, $replacementMessage)

# 4. Add SetTimer in OnGameModeInit
$targetTimer = 'SetTimer("ChangeWeather", WEATHER_TIME * 30000 * 30, 1);'
$replacementTimer = 'SetTimer("ChangeWeather", WEATHER_TIME * 30000 * 30, 1);' + [Environment]::NewLine + '	SetTimer("AutomaticDestroyVeh", AUTO_DESTROYVEH_TIME * 60000, 1);'
$content = $content.Replace($targetTimer, $replacementTimer)

[System.IO.File]::WriteAllText($path, $content)
