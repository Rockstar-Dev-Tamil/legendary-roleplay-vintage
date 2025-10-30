#define MAX_DYNAMIC_ACTORS		50

enum actEnum
{
    actor_ID,
    Text3D:actor_Label,
    actorID,
    actorExists,
    actorName[24],
    actorSkin,
    Float:actorX,
    Float:actorY,
    Float:actorZ,
    Float:actorA,
    actorVW
};
new ActorInfo[MAX_DYNAMIC_ACTORS][actEnum];

ReloadActor(actorid)
{
    if(ActorInfo[actorid][actorExists])
    {
        new string[128], name[24];
    
        strcpy(name, ActorInfo[actorid][actorName], 24);
        
        for(new i = 0, l = strlen(name); i < l; i ++)
        {
            if(name[i] == '_')
            {
                name[i] = ' ';
            }
        }       

        ActorInfo[actorid][actor_ID] = CreateActor(ActorInfo[actorid][actorSkin], ActorInfo[actorid][actorX], ActorInfo[actorid][actorY], ActorInfo[actorid][actorZ], ActorInfo[actorid][actorA]);

        DestroyDynamic3DTextLabel(ActorInfo[actorid][actor_Label]);
        format(string, sizeof(string), "%s", name);
        ActorInfo[actorid][actor_Label] = CreateDynamic3DTextLabel(string, COLOR_WHITE, ActorInfo[actorid][actorX], ActorInfo[actorid][actorY], ActorInfo[actorid][actorZ] + 1, 25.0);

        SetActorVirtualWorld(ActorInfo[actorid][actor_ID], ActorInfo[actorid][actorVW]);
    }
}

forward LoadDynamicActor();
public LoadDynamicActor()
{
	new rows = cache_get_row_count(connectionID);
	for(new i = 0; i < rows && i < MAX_SAFEZONES; i ++)
	{
		ActorInfo[i][actorExists] = 1;
        ActorInfo[i][actorID] = cache_get_field_content_int(i, "id");
        cache_get_field_content(i, "name", ActorInfo[i][actorName], connectionID, 24);
        ActorInfo[i][actorSkin] = cache_get_field_content_int(i, "skin");
        ActorInfo[i][actorX] = cache_get_field_content_float(i, "x");
        ActorInfo[i][actorY] = cache_get_field_content_float(i, "y");
        ActorInfo[i][actorZ] = cache_get_field_content_float(i, "z");
        ActorInfo[i][actorA] = cache_get_field_content_float(i, "a");
        ActorInfo[i][actorVW] = cache_get_field_content_int(i, "world");

        ReloadActor(i);
	}
	printf("[Script] %i actor loaded", rows);
}

forward OnAdminCreateActor(playerid, actorid, name[], skin, Float:x, Float:y, Float:z, Float:angle, world);
public OnAdminCreateActor(playerid, actorid, name[], skin, Float:x, Float:y, Float:z, Float:angle, world)
{
    strcpy(ActorInfo[actorid][actorName], name, MAX_PLAYER_NAME);
    ActorInfo[actorid][actorID] = cache_insert_id(connectionID);
    ActorInfo[actorid][actorSkin] = 299;
    ActorInfo[actorid][actorX] = x;
    ActorInfo[actorid][actorY] = y;
    ActorInfo[actorid][actorZ] = z;
    ActorInfo[actorid][actorA] = angle;
    ActorInfo[actorid][actorVW] = world;
    ActorInfo[actorid][actorExists] = 1;

    ReloadActor(actorid);
    SendAdminMessage(COLOR_LIGHTRED, "AdmCmd: %s %s has created actor %i successfully.", GetStaffRank(playerid), GetRPName(playerid), actorid);
}

CMD:createactor(playerid, params[])
{
    new name[24], world = GetPlayerVirtualWorld(playerid), skin, Float:x, Float:y, Float:z, Float:a;

    if(PlayerInfo[playerid][pAdmin] < 6)
        return SendClientMessage(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");

    if(sscanf(params, "s[24]d", name))
        return SendClientMessage(playerid, COLOR_GREY, "Usage: /createactor [message]");

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    for(new i = 0; i < MAX_DYNAMIC_ACTORS; i ++)
    {
        if(!ActorInfo[i][actorExists])
        {
            mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "INSERT INTO actors (name, skin, x, y, z, a, world) VALUES('%e', %d, %f, %f, %f, %f, %d)", name, skin, x, y, z, a, world);
            mysql_tquery(connectionID, queryBuffer, "OnAdminCreateActor", "iisiffffi", playerid, i, name, skin, x, y, z, a, world);
            return 1;
        }
    }

    SendClientMessage(playerid, COLOR_SYNTAX, "Actor slots are currently full. Ask developers to increase the internal limit.");
    return 1;
}

CMD:removeactor(playerid, params[])
{
    new actorid;

    if(PlayerInfo[playerid][pAdmin] < 6)
        return SendClientMessage(playerid, COLOR_GREY, "You are not authorized to use this command.");

    if(sscanf(params, "i", actorid))
        return SendClientMessage(playerid, COLOR_GREY, "Usage: /removeactor [actorid]");

    if(!(0 <= actorid < MAX_DYNAMIC_ACTORS) || !ActorInfo[actorid][actorExists])
        return SendClientMessage(playerid, COLOR_GREY, "Invalid actor.");

    DestroyDynamic3DTextLabel(ActorInfo[actorid][actor_Label]);
    DestroyActor(ActorInfo[actorid][actor_ID]);

    if(IsValidActor(ActorInfo[actorid][actor_ID])) {
        DestroyActor(ActorInfo[actorid][actor_ID]);
    }

    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "DELETE FROM actors WHERE id = %i", ActorInfo[actorid][actorID]);
    mysql_tquery(connectionID, queryBuffer);

    ActorInfo[actorid][actorExists] = 0;
    ActorInfo[actorid][actorID] = 0;

    SendMessage(playerid, COLOR_SERVER, "** You have removed actor %i.", actorid);
    return 1;
}

CMD:editactor(playerid, params[])
{
    new actorid, option[14], param[32];

    if(PlayerInfo[playerid][pAdmin] < 6)
        return SendClientMessage(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");

    if(sscanf(params, "is[14]S()[32]", actorid, option, param))
    {
        SendClientMessage(playerid, COLOR_GREY, "Usage: /editactor [actorid] [option]");
        SendClientMessage(playerid, COLOR_GREY2, "List of options: Message, Skin");
        return 1;
    }
    if(!(0 <= actorid < MAX_DYNAMIC_ACTORS) || !ActorInfo[actorid][actorExists])
        return SendClientMessage(playerid, COLOR_SYNTAX, "Invalid actor.");

    if(!strcmp(option, "message", true))
    {
        new name[24];

        if(sscanf(param, "s[24]", name))
            return SendClientMessage(playerid, COLOR_GREY, "Usage: /editactor [actorid] [name] [name of actor]");

        strcpy(ActorInfo[actorid][actorName], name, 24);

        mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE actors SET name = '%e' WHERE id = %i", ActorInfo[actorid][actorName], ActorInfo[actorid][actorID]);
        mysql_tquery(connectionID, queryBuffer);

        ReloadActor(actorid);
        SendMessage(playerid, COLOR_SERVER, "** You've changed the name of Actor %i to %s.", actorid, name);
    }
    else if(!strcmp(option, "skin", true))
    {
        new skin;

        if(sscanf(param, "d", skin))
            return SendClientMessage(playerid, COLOR_GREY, "Usage: /editactor [actorid] [skin id]");

        if(skin < 0 || skin == 74 || skin > 311)
            return SendClientMessage(playerid, COLOR_SYNTAX, "Invalid Skin ID.");

        ActorInfo[actorid][actorSkin] = skin;
        SendMessage(playerid, COLOR_SERVER, "** You've changed the skin of Actor %i to %d.", actorid, skin);

        ReloadActor(actorid);
        mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE actors SET skin = %d WHERE id = %i", ActorInfo[actorid][actorSkin], ActorInfo[actorid][actorID]);
        mysql_tquery(connectionID, queryBuffer);
    }
    return 1;
}

CMD:gotoactor(playerid, params[])
{
    new actorid;

    if(PlayerInfo[playerid][pAdmin] < 6)
    {
        return SendClientMessage(playerid, COLOR_GREY, "You are not authorized to use this command.");
    }

    if(sscanf(params, "i", actorid))
    {
        return SendClientMessage(playerid, COLOR_SYNTAX, "USAGE: /gotoactor [actorid]");
    }
    if(!(0 <= actorid < MAX_DYNAMIC_ACTORS) || !ActorInfo[actorid][actorExists])
    {
        return SendClientMessage(playerid, COLOR_GREY, "Invalid actor.");
    }

    GameTextForPlayer(playerid, "~w~Teleported", 5000, 1);

    SetPlayerPos(playerid, ActorInfo[actorid][actorX], ActorInfo[actorid][actorY], ActorInfo[actorid][actorZ]);
    SetPlayerVirtualWorld(playerid, ActorInfo[actorid][actorVW]);
    SetCameraBehindPlayer(playerid);

    return 1;
}