new RandomMessagesToSend[][] =
{
         "SERVER: Do you want to donate to our server? Contact the management for more information",
         "SERVER: Do you want to be a member of faction? Just apply in discord server.",
         "SERVER: Do you want to make your gang or join? ? Contact gang leader or appy in discord.",
         "SERVER: Seen a Hacker/Dmer/Rulebreaker? Report on admin used the cmds [/report] or [/rdm]", 
         "SERVER: To avoid being jailed, just follow the rules on the server",
         "SERVER: If you find a bug inside the server, Please report it to our discord community",
         "SERVER: Do you need a license? You can buy a license from law enforcement",
         "SERVER: Too force closed/fc? Try to clear cache your gta application and remove some mods.",
         "SERVER: Join our discord community https://discord.io/asianrealityrp"
};

forward SendRandomMessageToAll();
public SendRandomMessageToAll()
{
    SMA(COLOR_YELLOW2, RandomMessagesToSend[random(sizeof(RandomMessagesToSend))]);
    return 1;
}

public OnGameModeInit()
{
    // Every 5 minutes send a random message to all online players
    SetTimer("SendRandomMessageToAll", 300000, 1); 
    
    #if defined Randommsg_OnGameModeInit
		return Randommsg_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Randommsg_OnGameModeInit
#if defined Randommsg_OnGameModeInit
	forward Randommsg_OnGameModeInit();
#endif
