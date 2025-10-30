#include <a_samp>

#if defined include_g_Stamina
    #endinput
#else
	#define include_g_Stamina
#endif




#if !defined STAMINA_DEFAULT_RECOVERYTIME
	#define STAMINA_DEFAULT_RECOVERYTIME    (4000)
#endif

forward OnPlayerStaminaOver(playerid);

stock IsPlayerRunning(playerid)
{
    if(!IsPlayerConnected(playerid) || IsPlayerInAnyVehicle(playerid) || IsPlayerExhausted(playerid)) return 0;

    new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);
    if(keys & KEY_SPRINT && GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_USEJETPACK) return 1;
    else return 0;
}


stock IsPlayerExhausted(playerid) // Check if the player is exhausted
{
	if(GetPVarInt(playerid, "Exhausted") == 1) return true;
	else return false;
}


forward SetPlayerExhausted(playerid, bool:Exhausted);
public SetPlayerExhausted(playerid, bool:Exhausted)
{
	if(Exhausted) 
	{
		TogglePlayerControllable(playerid,0);
		TogglePlayerControllable(playerid,1);

		ApplyAnimation(playerid, "FAT", "IDLE_tired", 4.1, 0, 1, 1, 0, STAMINA_DEFAULT_RECOVERYTIME, 1);

		SetPVarInt(playerid, "Exhausted", 1);
		SetTimerEx("SetPlayerExhausted", STAMINA_DEFAULT_RECOVERYTIME, false, "ib", playerid, false);
	}
	else SetPVarInt(playerid, "Exhausted", 0), ClearAnimations(playerid);
	return 1;
}


stock GetPlayerStamina(playerid)
{
	if(!IsPlayerConnected(playerid) || GetPVarType(playerid, "MAX_Stamina") == PLAYER_VARTYPE_NONE) return -1;
	new stamina = GetPVarInt(playerid, "Stamina");
	return stamina;
}


stock GetPlayerMaxStamina(playerid)
{
	if(!IsPlayerConnected(playerid) || GetPVarType(playerid, "MAX_Stamina") == PLAYER_VARTYPE_NONE) return -1;
	new maxstamina = GetPVarInt(playerid, "MAX_Stamina");
	return maxstamina;
}


stock GivePlayerStamina(playerid, value)
{
	new stamina = GetPVarInt(playerid, "Stamina");

	if(stamina == -1) return 1;
	if(stamina + value == 0) return CallLocalFunction("OnPlayerStaminaOver", "i", playerid);
	if(stamina + value <= GetPVarInt(playerid, "MAX_Stamina")) 
	{
		stamina = stamina+value;
		SetPVarInt(playerid, "Stamina", stamina);
		return 1;
	}
	else return 0;
}


stock GivePlayerMaxStamina(playerid, value)
{
	new maxstamina = GetPVarInt(playerid, "MAX_Stamina"), stamina = GetPVarInt(playerid, "Stamina");

	maxstamina = maxstamina + value;
	SetPVarInt(playerid, "MAX_Stamina", maxstamina);

	if(stamina > maxstamina)stamina = maxstamina, SetPVarInt(playerid, "Stamina", stamina);

	return 1;
}


stock SetPlayerStamina(playerid, value)
{
	if(value > GetPVarInt(playerid, "MAX_Stamina")) return SetPVarInt(playerid, "Stamina", GetPVarInt(playerid, "MAX_Stamina"));
	else if(value == 0) OnPlayerStaminaOver(playerid);
	SetPVarInt(playerid, "Stamina", value);
	return 1;
}


stock SetPlayerMaxStamina(playerid, value)
{
	new stamina = GetPlayerStamina(playerid), max_stamina = value;

	if(stamina > max_stamina) stamina = max_stamina, SetPVarInt(playerid, "Stamina", stamina);
	SetPVarInt(playerid, "MAX_Stamina", max_stamina);
	return 1;
}

stock GivePlayerSprintVelocity(playerid, Float:value)
{
	if(value == 0.0) return 1;
	else if(value > 0.0)
	{
		new Float:x, Float:y, Float:Z;

		GetPlayerVelocity(playerid, x, y, z);
		SetPlayerVelocity(playerid, x*value, y*value, z*value);
	}
	else if(value < 0.0) // if Subtract
	{
		GetPlayerVelocity(playerid, x, y, z);
		SetPlayerVelocity(playerid, x/value, y/value, z/value);
	}
	SetPVarFloat(playerid, "Sprint_Velocity", value);
		return 1;
}

stock GetPlayerSprintVelocity(playerid)
{
	if(!IsPlayerConnected(playerid)) return -1;
	new Float:velocity = GetPVarFloat(playerid, "Sprint_Velocity");
	return Float:velocity;
}