/*
	.____     ________     ____________________ 
	|    |   /  _____/  /\ \______   \______   \
	|    |  /   \  ___  \/  |       _/|     ___/
	|    |__\    \_\  \ /\  |    |   \|    |    
	|_______ \______  / \/  | ___|___/|____|
					\/      \/          

				  Legacy Roleplay

		  Community Director & Development
				    Genjii#4764

			  Script Development Team
				    Tiyo#7124


            Disccord Verification System

*/

#define DISCORD_ID	"1152526462725914725"    // Discord Server ID
#define DISCORD_CHANNEL 	"1230130739450740768"    //1230130739450740768 Discord channel ID
#define ROLE_ID		"1322077407632560138"  // Discord Role ID

#define DCMD_STRICT_CASE 
#define DCMD_ALLOW_BOTS 

// Variables
new DCC_Channel:discord_channel;
new DCC_Guild:discord_guild;
new DCC_Role:discord_role;

// Callbacks
public OnGameModeInit()
{
    discord_guild = DCC_FindGuildById(DISCORD_ID);
    discord_channel = DCC_FindChannelById(DISCORD_CHANNEL);
    discord_role = DCC_FindRoleById(ROLE_ID);
	#if defined Verify_OnGameModeInit
        return Verify_OnGameModeInit();
    #else
        return 1;
    #endif
}


CMD:getcode(playerid, params[])
{
	if(PlayerInfo[playerid][pVerified])
	{
		SendClientMessage(playerid, -1, "This account has already been verified in the database");
		return 1;
	}
	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT * FROM users WHERE username = '%e' LIMIT 1;", GetPlayerNameEx(playerid));
	mysql_tquery(connectionID, queryBuffer, "OnPlayerDiscordCode", "d", playerid);
	return 1;
}
DCMD:link(user, channel, params[])
{
    new code;
	if(channel != discord_channel)
    {   
        new channel_name[64], szString[128];
        DCC_GetChannelName(discord_channel, channel_name, sizeof(channel_name));

        format(szString, sizeof(szString), "This command should only be used on #%s!", channel_name);
        SendBotMessage(channel, 0xFF0000, "Wrong Channel", szString, "");
        return 0;
    }
	if(sscanf(params, "i", code)) return SendBotMessage(discord_channel, 0xFF0000, "Error: Invalide Code", "We cannot find a user with this code in the database", "WARNING: Attemping to link an account that is not yours can get your in trouble.");
	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "SELECT * FROM users WHERE code = %i", code);
	mysql_tquery(connectionID, queryBuffer, "OnPlayerDiscordVerified", "dd", _:user, code);
	return 1;
}

forward OnPlayerDiscordCode(playerid);
public OnPlayerDiscordCode(playerid)
{
	new code = 100000 + random(999999);
	PlayerInfo[playerid][pCode] = code; 
	SendMessage(playerid, COLOR_YELLOW, "[Discord Verification]: {FFFFFF}You already have a verification code %d", PlayerInfo[playerid][pCode]);

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET code = %i WHERE uid = %i", PlayerInfo[playerid][pCode], PlayerInfo[playerid][pID]);
	mysql_tquery(connectionID, queryBuffer);
	return 1;
}


forward OnPlayerDiscordVerified(DCC_User:user, code);
public OnPlayerDiscordVerified(DCC_User:user, code)
{
    new playerid = INVALID_PLAYER_ID, user_name[DCC_USERNAME_SIZE], user_id[DCC_ID_SIZE], discord_tag[10];
	new player_name[MAX_PLAYER_NAME], bool:has_role;
	
    DCC_GetUserId(user, user_id, sizeof(user_id));
	new DCC_User:confirmed_user = DCC_FindUserById(user_id);

	new szString[500];
    if(cache_get_row_count(connectionID))
	{
		cache_get_field_content(0, "username", player_name, sizeof(player_name));
		IsDiscordUserVerified(user, has_role);
	
		if(has_role == true)
		{	
            SendBotMessage(discord_channel, 0xFF0000, "Already Verified!", "You are already verified or this code was already used to verify another account", "WARNING: Attemping to link an account that is not yours can get your in trouble.");
			return 1;
		}
		foreach(new i : Player)
		{
			if(!strcmp(player_name, GetPlayerNameEx(i)))
			{
				playerid = i;
				break;
			}
		}
		if(IsPlayerConnected(playerid))
		{
			DCC_GetUserName(confirmed_user, user_name, sizeof(user_name));
			DCC_GetUserDiscriminator(confirmed_user, discord_tag, sizeof(discord_tag));
            DCC_AddGuildMemberRole(discord_guild, confirmed_user, discord_role);
			DCC_SetGuildMemberNickname(discord_guild, confirmed_user, GetPlayerNameEx(playerid));

			format(szString, sizeof(szString), "[Discord Verification]: {FFFFFF}Your account successfully been linked to the discord account "SVRCLR"%s#%s", user_name, discord_tag);
			SendClientMessage(playerid, COLOR_YELLOW, szString);
            
			format(szString, sizeof(szString), "The account **%s** has been successfully linked to your discord account\nYou will now be able access the features in the server and much more\njoining event, weapons, vehicles, jobs, and more.\n\n**Welcome to %s.**", GetRPName(playerid), SERVER_NAME);
			SendBotMessage(discord_channel, 0x00FF00, "Successfully Verified!", szString, ""SERVER_NAME" -!help for more information");

			PlayerInfo[playerid][pVerified] = 1;
			mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE users SET discord_name = '%s', discord_tag = '%s', verified_id = '%e', verified = %i WHERE uid = %i", user_name, discord_tag, user_id, PlayerInfo[playerid][pVerified], PlayerInfo[playerid][pID]);
            mysql_tquery(connectionID, queryBuffer);
		}
		else 
		{
			SendBotMessage(discord_channel, 0xFF0000, "Error: Invalide Code", "We cannot find a user with this code in the database", "WARNING: Attemping to link an account that is not yours can get your in trouble.");		
		}
	}
	else
	{
        SendBotMessage(discord_channel, 0xFF0000, "Error: Invalide Code", "We cannot find a user with this code in the database", "WARNING: Attemping to link an account that is not yours can get your in trouble.");
    }
	return 1;
}

// functions
IsDiscordUserVerified(DCC_User:user, &bool:has_role) {
	DCC_HasGuildMemberRole(discord_guild, user, discord_role, has_role);
}

IsAccountVerified(playerid) {
    return PlayerInfo[playerid][pVerified];
}

forward SendBotMessage(DCC_Channel:channel, color, const title[], const message[], const footer[]);
public SendBotMessage(DCC_Channel:channel, color, const title[], const message[], const footer[]) {
    new DCC_Embed:embed= DCC_CreateEmbed(title);
    DCC_SetEmbedColor(embed, color);
    DCC_SetEmbedDescription(embed, message);
    DCC_SetEmbedFooter(embed, footer);
    DCC_SendChannelEmbedMessage(channel, embed);
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit Verify_OnGameModeInit
#if defined Verify_OnGameModeInit
    forward Verify_OnGameModeInit();
#endif