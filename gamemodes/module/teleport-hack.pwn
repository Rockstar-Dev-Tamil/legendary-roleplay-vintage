/*

    Legacy Roleplay
            By Legacy Gaming Development Team

    Airbreak Hack
            Main.pwn

*/

public OnPlayerTeleport(playerid, Float:distance)
{
	if((gAnticheat) && PlayerInfo[playerid][pAdmin] < 2 && !PlayerInfo[playerid][pKicked] && InsideTut[playerid] == 0)
	{
	    if(!IsPlayerInRangeOfPoint(playerid, 3.0, PlayerInfo[playerid][pPosX], PlayerInfo[playerid][pPosY], PlayerInfo[playerid][pPosZ]))
	    {
		    PlayerInfo[playerid][pACWarns]++;

		    if(PlayerInfo[playerid][pACWarns] < 2)
		    {
	    	    SendAdminMessage(COLOR_YELLOW, "AdmWarning: %s[%i] is possibly teleport hacking (distance: %.1f).", GetRPName(playerid), playerid, distance);
	        	Log_Write("log_cheat", "%s (uid: %i) possibly teleport hacked (distance: %.1f)", GetPlayerNameEx(playerid), PlayerInfo[playerid][pID], distance);
			}
			else
			{
		    	SendMessageToAll(COLOR_LIGHTRED, "AdmCmd: %s was autokicked by %s, reason: Teleport hacks", GetRPName(playerid), SERVER_ANTICHEAT);
		    	KickPlayer(playerid);
			}
		}
	}

	return 1;
}
