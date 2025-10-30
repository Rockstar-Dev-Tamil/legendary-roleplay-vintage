CMD:cbug(playerid, params[])
{
     SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s was auto-kicked by %s Reason: Illegal cleo command", GetRPName(playerid), SERVER_ANTICHEAT);
     Kick(playerid);
     return 1;
}
