/*

    Legacy Roleplay
            By Legacy Gaming Development Team

    Airbreak Hack
            Main.pwn

*/

public OnPlayerAirbreak(playerid)
{
	if((gAnticheat) && PlayerInfo[playerid][pAdmin] < 2 && !PlayerInfo[playerid][pKicked])
	{
	    PlayerInfo[playerid][pACWarns]++;

	    if(PlayerInfo[playerid][pACWarns] < 2)
	    {
	        SendAdminMessage(COLOR_YELLOW, "AdmWarning: %s[%i] is possibly using airbreak hacks.", GetRPName(playerid), playerid);
	        Log_Write("log_cheat", "%s (uid: %i) possibly used airbreak.", GetPlayerNameEx(playerid), PlayerInfo[playerid][pID]);
		}
		else
		{
		    SendMessageToAll(COLOR_LIGHTRED, "AdmCmd: %s was autobanned by %s, reason: Airbreak", GetRPName(playerid), SERVER_ANTICHEAT);
		    BanPlayer(playerid, SERVER_ANTICHEAT, "Airbreak");
		}
	}
	return 1;
}
