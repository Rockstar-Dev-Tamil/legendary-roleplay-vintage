#define MAX_SAFEZONES		50

enum szInfo
{
    szID,
	szExists,
	Float:szPosX,
 	Float:szPosY,
 	Float:szPosZ,
 	Float:szPosA,
 	szSize,
 	szIcon,
 	szLabel,
 	szPickup,
 	Text3D: szTextID,
};
new SafezoneInfo[MAX_SAFEZONES][szInfo];

GetNearbySafezone(playerid)
{
	for(new i = 0; i < MAX_SAFEZONES; i ++)
	{
	    if(SafezoneInfo[i][szExists] && IsPlayerInRangeOfPoint(playerid, 3.0, SafezoneInfo[i][szPosX], SafezoneInfo[i][szPosY], SafezoneInfo[i][szPosZ]))
	    {
	        return i;
	    }
	}
	return -1;
}

ReloadSafezone(szid)
{
	new string[500];
	if(SafezoneInfo[szid][szExists])
	{
	    DestroyDynamic3DTextLabel(SafezoneInfo[szid][szTextID]);
	    DestroyDynamicObject(SafezoneInfo[szid][szPickup]);

	    if(SafezoneInfo[szid][szLabel])
	    {
			format(string, sizeof(string), "Greenzone [%i]\nGreenzone Meter: %i\n\nYour damage within this area is disabled\n", szid, SafezoneInfo[szid][szSize]);
			SafezoneInfo[szid][szTextID] = CreateDynamic3DTextLabel(string, -1, SafezoneInfo[szid][szPosX], SafezoneInfo[szid][szPosY], SafezoneInfo[szid][szPosZ]+0.5,30.0);
	    }
	    SafezoneInfo[szid][szPickup] = CreateDynamicPickup(SafezoneInfo[szid][szIcon], 1, SafezoneInfo[szid][szPosX], SafezoneInfo[szid][szPosY], SafezoneInfo[szid][szPosZ]);
	}
}

forward OnAdminCreateSafezone(playerid, sz, size, Float:x, Float:y, Float:z, Float:a);
public OnAdminCreateSafezone(playerid, sz, size, Float:x, Float:y, Float:z, Float:a)
{
    SafezoneInfo[sz][szID] = cache_insert_id(connectionID);
	SafezoneInfo[sz][szExists] = 1;
    SafezoneInfo[sz][szPosX] = x;
    SafezoneInfo[sz][szPosY] = y;
    SafezoneInfo[sz][szPosZ] = z;
    SafezoneInfo[sz][szPosA] = a;
    SafezoneInfo[sz][szSize] = size;
    SafezoneInfo[sz][szIcon] = 19134;
    SafezoneInfo[sz][szPickup] = -1;
	SafezoneInfo[sz][szTextID] = Text3D:INVALID_3DTEXT_ID;
    SafezoneInfo[sz][szLabel] = 1;

	ReloadSafezone(sz);
	SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s %s has created Safezone at %s.", GetStaffRank(playerid), GetRPName(playerid), GetZoneName(x, y, z));
}

forward LoadSafezones();
public LoadSafezones()
{
	new rows = cache_get_row_count(connectionID);
	for(new i = 0; i < rows && i < MAX_SAFEZONES; i ++)
	{
		SafezoneInfo[i][szID] = cache_get_field_content_int(i, "id");
		SafezoneInfo[i][szSize] = cache_get_field_content_int(i, "size");
		SafezoneInfo[i][szPosX] = cache_get_field_content_float(i, "pos_x");
		SafezoneInfo[i][szPosY] = cache_get_field_content_float(i, "pos_y");
		SafezoneInfo[i][szPosZ] = cache_get_field_content_float(i, "pos_z");
		SafezoneInfo[i][szPosA] = cache_get_field_content_float(i, "pos_r");
		SafezoneInfo[i][szLabel] = cache_get_field_content_int(i, "label");
		SafezoneInfo[i][szIcon] = cache_get_field_content_int(i, "icon");
		SafezoneInfo[i][szPickup] = -1;
		SafezoneInfo[i][szTextID] = Text3D:INVALID_3DTEXT_ID;
		SafezoneInfo[i][szExists] = 1;
		ReloadSafezone(i);
	}
	printf("[Script] %i safezones loaded", rows);
}

CMD:createsz(playerid, params[])
{
    new Float:x, Float:y, Float:z, Float:a, size;
	if(PlayerInfo[playerid][pAdmin] < 6)
	{
	    return SCM(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");
	}
    if(sscanf(params, "i[32]", size))
	{
	    SendClientMessage(playerid, COLOR_SYNTAX, "USAGE: /createsz [size]");
		SendClientMessage(playerid, COLOR_WHITE, "** NOTE: The safezone will be created at the coordinates you are standing on.");
		return 1;
	}
    GetPlayerPos(playerid, x, y, z);
 	GetPlayerFacingAngle(playerid, a);
    for(new i = 0; i < MAX_SAFEZONES; i ++)
	{
		if(!SafezoneInfo[i][szExists])
		{
		    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "INSERT INTO safezones (size, pos_x, pos_y, pos_z, pos_r) VALUES('%i', '%f', '%f', '%f', '%f')", size, x, y, z, a);
		    mysql_tquery(connectionID, queryBuffer, "OnAdminCreateSafezone", "iiiffff", playerid, i, size, x, y, z, a);
		    return 1;
		}
	}

	SendClientMessage(playerid, COLOR_GREY, "Safezone slots are currently full. Ask developers to increase the internal limit.");
	return 1;
}

CMD:removesz(playerid, params[])
{
	new loc;

	if(PlayerInfo[playerid][pAdmin] < 6)
	{
	    return SCM(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");
	}
	if(sscanf(params, "i", loc))
	{
	    return SendClientMessage(playerid, COLOR_SYNTAX, "USAGE: /removesz [ID] (/nearest)");
	}
	if(!(0 <= loc < MAX_SAFEZONES) || !SafezoneInfo[loc][szExists])
	{
	    return SendClientMessage(playerid, COLOR_GREY, "Invalid Safezone or Static.");
	}
    DestroyDynamic3DTextLabel(SafezoneInfo[loc][szTextID]);
    DestroyDynamicPickup(SafezoneInfo[loc][szPickup]);

	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "DELETE FROM safezones WHERE id = %i", SafezoneInfo[loc][szID]);
	mysql_tquery(connectionID, queryBuffer);
	SafezoneInfo[loc][szExists] = false;
	SafezoneInfo[loc][szID] = 0;

	SM(playerid, COLOR_WHITE, "** You have removed safezone [%i].", loc);
	return 1;
}
