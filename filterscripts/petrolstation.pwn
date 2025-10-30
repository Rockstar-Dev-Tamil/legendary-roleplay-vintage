/* petrolstation.pwn
   Full Filterscript:
   - MySQL load/save
   - /createps, /removeps, /editps
   - /fuelmenu dialog (refuel & vault)
   - /refuel command with timer
   - /depositps /withdrawps commands
   - /robps simple robbery

   By Rockstar!
*/

#include <a_samp>
#include <a_mysql>
#include <streamer>

#define CYAN 0x00FFFFAA


#define MAX_PS 100
#define MYSQL_HOST        "148.113.46.92"
#define MYSQL_USER        "u1223_rqR13P89uw"
#define MYSQL_PASSWORD    "22^Plrebb=!!kAswGZPAvqlT"
#define MYSQL_DATABASE    "s1223_LegendaryRoleplay"

#define THREAD_LOAD_PETROLSTATION 62

// Dialog IDs
#define DIALOG_FUELMENU    1000
#define DIALOG_FUELSAFE    1001
#define DIALOG_PSWITHDRAW  1002
#define DIALOG_PSDEPOSIT   1003
#define DIALOG_FUELPRICE   1004

// Refuel timer interval (ms)
#define REFUEL_TICK_MS 1000

// Robbery cooldown secs per station
#define ROB_COOLDOWN 300

enum e_PS
{
    psID,
    psOwnerID,
    psOwner[MAX_PLAYER_NAME],
    bool:psExists,
    Float:psPosX,
    Float:psPosY,
    Float:psPosZ,
    Float:psPosA,
    psText,
    psLitre,
    psPrice,
    psCash,
    psPickup
};
new PSInfo[MAX_PS][e_PS];
new MySQL:dbHandle;
new queryBuffer[512];

// per-player refuel state
new bool:Refueling[MAX_PLAYERS];
new RefuelVeh[MAX_PLAYERS];
new RefuelAmount[MAX_PLAYERS];
new RefuelStation[MAX_PLAYERS];

// simple vehicle fuel store (per vehicle id)

new vehicleFuel[MAX_VEHICLES];

// robbery cooldowns per station (unix timestamp)
new RobCooldown[MAX_PS];

// ========================= Init / Exit =========================
public OnFilterScriptInit()
{
    print("[PS FS] Initializing PetrolStation FS...");
    dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
    if(dbHandle == MYSQL_INVALID_HANDLE || mysql_errno(dbHandle) != 0)
    {
        print("[PS FS] MySQL connect failed! Check credentials and plugin.");
        return 0;
    }
    mysql_tquery(dbHandle, "SELECT * FROM petrolstation", "OnQueryFinished", "ii", THREAD_LOAD_PETROLSTATION, 0);
    return 1;
}

public OnFilterScriptExit()
{
    // Destroy dynamic stuff if any
    for(new i = 0; i < MAX_PS; i++)
    {
        if(PSInfo[i][psExists])
        {
            if(PSInfo[i][psText] > 0) DestroyDynamic3DTextLabel(PSInfo[i][psText]);
            if(PSInfo[i][psPickup] > 0) DestroyDynamicPickup(PSInfo[i][psPickup]);
        }
    }
    if(dbHandle != MYSQL_INVALID_HANDLE) mysql_close(dbHandle);
    print("[PS FS] Unloaded.");
    return 1;
}

// ========================= MySQL callback =========================
forward OnQueryFinished(threadid, extraid);
public OnQueryFinished(threadid, extraid)
{
    if(threadid == THREAD_LOAD_PETROLSTATION)
    {
        new rows = cache_num_rows();
        if(rows <= 0) { print("[PS FS] No petrol stations found in DB."); return 1; }

        for(new i = 0; i < rows && i < MAX_PS; i++)
        {
            cache_get_field_content(i, "owner", PSInfo[i][psOwner], dbHandle, MAX_PLAYER_NAME);
            PSInfo[i][psID]      = cache_get_field_content_int(i, "id");
            PSInfo[i][psOwnerID] = cache_get_field_content_int(i, "ownerid");
            PSInfo[i][psLitre]   = cache_get_field_content_int(i, "litre");
            PSInfo[i][psPrice]   = cache_get_field_content_int(i, "price");
            PSInfo[i][psCash]    = cache_get_field_content_int(i, "cash");
            PSInfo[i][psPosX]    = cache_get_field_content_float(i, "pos_x");
            PSInfo[i][psPosY]    = cache_get_field_content_float(i, "pos_y");
            PSInfo[i][psPosZ]    = cache_get_field_content_float(i, "pos_z");
            PSInfo[i][psPosA]    = cache_get_field_content_float(i, "pos_a");
            PSInfo[i][psExists]  = true;

            // Create 3D label & pickup
            ReloadPS(i);
        }
        printf("[PS FS] Loaded %d petrol stations.", rows);
    }
    return 1;
}

// ========================= Helpers =========================
stock GetNearbyPS(playerid)
{
    new Float:px,py,pz;
    GetPlayerPos(playerid, px, py, pz);
    for(new i = 0; i < MAX_PS; i++)
    {
        if(PSInfo[i][psExists] && IsPlayerInRangeOfPoint(playerid, 3.0, PSInfo[i][psPosX], PSInfo[i][psPosY], PSInfo[i][psPosZ]))
        {
            return i;
        }
    }
    return -1;
}

ReloadPS(psid)
{
    new tmp[256];
    if(!PSInfo[psid][psExists]) return 0;

    if(PSInfo[psid][psText] > 0) DestroyDynamic3DTextLabel(PSInfo[psid][psText]);
    if(PSInfo[psid][psPickup] > 0) DestroyDynamicPickup(PSInfo[psid][psPickup]);

    if(PSInfo[psid][psOwnerID] == 0)
    {
        format(tmp, sizeof(tmp), "Fuel Station\n"CYAN"(( Type '/refuel' or Click 'Y' ))\n"TEAL"Price: $%i", PSInfo[psid][psPrice]);
    }
    else
    {
        format(tmp, sizeof(tmp), "Fuel Station\nOwned by %s\n"CYAN"(( Type '/refuel' or Click 'Y' ))\n"TEAL"Price: $%i", PSInfo[psid][psOwner], PSInfo[psid][psPrice]);
    }
    PSInfo[psid][psText] = CreateDynamic3DTextLabel(tmp, 0xFFFFFFFF, PSInfo[psid][psPosX], PSInfo[psid][psPosY], PSInfo[psid][psPosZ] + 0.5, 12.0);
    PSInfo[psid][psPickup] = CreateDynamicPickup(1650, 1, PSInfo[psid][psPosX], PSInfo[psid][psPosY], PSInfo[psid][psPosZ]);
    return 1;
}

SetPSOwner(psid, playerid)
{
    if(!PSInfo[psid][psExists]) return 0;

    if(playerid == INVALID_PLAYER_ID)
    {
        strcpy(PSInfo[psid][psOwner], "Nobody", MAX_PLAYER_NAME);
        PSInfo[psid][psOwnerID] = 0;
    }
    else
    {
        GetPlayerName(playerid, PSInfo[psid][psOwner], MAX_PLAYER_NAME);
        PSInfo[psid][psOwnerID] = PlayerInfo[playerid][pID]; // note: your GM must define PlayerInfo/pID mapping; else adjust
    }

    mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET ownerid=%d, owner='%s' WHERE id=%d",
        PSInfo[psid][psOwnerID], PSInfo[psid][psOwner], PSInfo[psid][psID]);
    mysql_tquery(dbHandle, queryBuffer);

    ReloadPS(psid);
    return 1;
}

// ========================= Commands =========================
CMD:createps(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 6) return SCM(playerid, COLOR_SYNTAX, "You are not authorized.");
    if(strlen(params) == 0)
    {
        SendClientMessage(playerid, COLOR_WHITE, "USAGE: /createps confirm");
        return 1;
    }
    if(!strcmp(params, "confirm", true))
    {
        new Float:x,y,z,a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        // find free slot
        for(new i = 0; i < MAX_PS; i++)
        {
            if(!PSInfo[i][psExists])
            {
                PSInfo[i][psExists] = true;
                strcpy(PSInfo[i][psOwner], "Nobody", MAX_PLAYER_NAME);
                PSInfo[i][psOwnerID] = 0;
                PSInfo[i][psLitre] = 500;
                PSInfo[i][psPrice] = 3;
                PSInfo[i][psCash] = 0;
                PSInfo[i][psPosX] = x;
                PSInfo[i][psPosY] = y;
                PSInfo[i][psPosZ] = z;
                PSInfo[i][psPosA] = a;

                mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer),
                    "INSERT INTO petrolstation (ownerid, owner, litre, price, cash, pos_x, pos_y, pos_z, pos_a) VALUES (%d, '%s', %d, %d, %d, %f, %f, %f, %f)",
                    PSInfo[i][psOwnerID], PSInfo[i][psOwner], PSInfo[i][psLitre], PSInfo[i][psPrice], PSInfo[i][psCash],
                    PSInfo[i][psPosX], PSInfo[i][psPosY], PSInfo[i][psPosZ], PSInfo[i][psPosA]);
                mysql_tquery(dbHandle, queryBuffer, "OnAdminCreatePS", "i", playerid);

                ReloadPS(i);
                SM(playerid, COLOR_TEAL, "** Fuel Station created.");
                return 1;
            }
        }
        return SCM(playerid, COLOR_GREY, "Petrol Station slots are full.");
    }
    return SCM(playerid, COLOR_SYNTAX, "Usage: /createps confirm");
}

CMD:removeps(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 6) return SCM(playerid, COLOR_SYNTAX, "You are not authorized.");
    new id;
    if(sscanf(params, "i", id)) return SCM(playerid, COLOR_SYNTAX, "Usage: /removeps [slotid]");
    if(!(0 <= id && id < MAX_PS) || !PSInfo[id][psExists]) return SCM(playerid, COLOR_GREY, "Invalid Petrol Station.");

    if(PSInfo[id][psText] > 0) DestroyDynamic3DTextLabel(PSInfo[id][psText]);
    if(PSInfo[id][psPickup] > 0) DestroyDynamicPickup(PSInfo[id][psPickup]);

    mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "DELETE FROM petrolstation WHERE id=%d", PSInfo[id][psID]);
    mysql_tquery(dbHandle, queryBuffer);

    PSInfo[id][psExists] = false;
    PSInfo[id][psID] = 0;
    SM(playerid, COLOR_WHITE, "** You have removed Petrol Station %d.", id);
    return 1;
}

CMD:editps(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 6) return SCM(playerid, COLOR_SYNTAX, "You are not authorized.");
    new id; new option[16]; new param[32];
    if(sscanf(params, "is[16]s[32]", id, option, param)) return SCM(playerid, COLOR_SYNTAX, "Usage: /editps [slotid] [owner|price|litre] [value]");
    if(!(0 <= id && id < MAX_PS) || !PSInfo[id][psExists]) return SCM(playerid, COLOR_SYNTAX, "Invalid Petrol Station.");

    if(!strcmp(option, "owner", true))
    {
        new targetid;
        if(sscanf(param, "i", targetid)) return SCM(playerid, COLOR_SYNTAX, "Usage: /editps [slotid] owner [playerid]");
        if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_SYNTAX, "Player not connected.");
        GetPlayerName(targetid, PSInfo[id][psOwner], MAX_PLAYER_NAME);
        PSInfo[id][psOwnerID] = PlayerInfo[targetid][pID];
        mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET ownerid=%d, owner='%s' WHERE id=%d", PSInfo[id][psOwnerID], PSInfo[id][psOwner], PSInfo[id][psID]);
        mysql_tquery(dbHandle, queryBuffer);
        ReloadPS(id);
        SM(playerid, COLOR_AQUA, "** Changed owner of station %d.", id);
        return 1;
    }
    else if(!strcmp(option, "price", true))
    {
        new val;
        if(sscanf(param, "i", val)) return SCM(playerid, COLOR_SYNTAX, "Usage: /editps [slotid] price [value]");
        if(val < 0 || val > 100) return SCM(playerid, COLOR_SYNTAX, "Price must be 0-100.");
        PSInfo[id][psPrice] = val;
        mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET price=%d WHERE id=%d", val, PSInfo[id][psID]);
        mysql_tquery(dbHandle, queryBuffer);
        ReloadPS(id);
        SM(playerid, COLOR_AQUA, "** Changed price of station %d to $%d.", id, val);
        return 1;
    }
    else if(!strcmp(option, "litre", true))
    {
        new val;
        if(sscanf(param, "i", val)) return SCM(playerid, COLOR_SYNTAX, "Usage: /editps [slotid] litre [value]");
        PSInfo[id][psLitre] = val;
        mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET litre=%d WHERE id=%d", val, PSInfo[id][psID]);
        mysql_tquery(dbHandle, queryBuffer);
        ReloadPS(id);
        SM(playerid, COLOR_AQUA, "** Changed litre of station %d to %d.", id, val);
        return 1;
    }
    return SCM(playerid, COLOR_SYNTAX, "Unknown option.");
}

// ========================= Fuel menu & dialogs =========================
CMD:fuelmenu(playerid, params[])
{
    new ps = GetNearbyPS(playerid);
    if(ps == -1) return SCM(playerid, COLOR_SYNTAX, "You need to be at a gas station.");
    if(PSInfo[ps][psOwnerID] == PlayerInfo[playerid][pID])
    {
        ShowPlayerDialog(playerid, DIALOG_FUELMENU, DIALOG_STYLE_LIST, "Fuel Menu", "Refuel\nFuelStation Info\nFuel Vault\nFuel Price", "Select", "Cancel");
    }
    else
    {
        ShowPlayerDialog(playerid, DIALOG_FUELMENU, DIALOG_STYLE_LIST, "Fuel Menu", "Refuel\nFuelStation Info", "Select", "Cancel");
    }
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_FUELMENU)
    {
        if(!response) return 1;
        new ps = GetNearbyPS(playerid);
        if(ps == -1) return SCM(playerid, COLOR_SYNTAX, "You are not near any petrol station.");

        if(listitem == 0) // Refuel
        {
            // Start refuel via command /refuel too
            CMD_refuel(playerid, "");
            return 1;
        }
        else if(listitem == 1) // Info
        {
            new info[256];
            format(info, sizeof(info), "Petrol Station ID: %d\nOwner: %s\nPrice: $%d\nLitres: %d\nVault: $%d", PSInfo[ps][psID], PSInfo[ps][psOwner], PSInfo[ps][psPrice], PSInfo[ps][psLitre], PSInfo[ps][psCash]);
            ShowPlayerDialog(playerid, DIALOG_FUELSAFE, DIALOG_STYLE_MSGBOX, "Station Info", info, "Close", "");
            return 1;
        }
        else if(listitem == 2) // Vault
        {
            // Only owner can access full vault menu
            if(PSInfo[ps][psOwnerID] != PlayerInfo[playerid][pID]) return SCM(playerid, COLOR_SYNTAX, "Only station owner can access vault.");
            new vmsg[128];
            format(vmsg, sizeof(vmsg), "Vault Balance: $%s", number_format(PSInfo[ps][psCash]));
            ShowPlayerDialog(playerid, DIALOG_PSWITHDRAW, DIALOG_STYLE_LIST, "Vault", "Deposit\nWithdraw", "Select", "Cancel");
            return 1;
        }
        else if(listitem == 3) // Price
        {
            if(PSInfo[ps][psOwnerID] != PlayerInfo[playerid][pID]) return SCM(playerid, COLOR_SYNTAX, "Only owner can change price.");
            new cur[128];
            format(cur, sizeof(cur), "Enter the Fuel Price (Max 100). Current: $%s", number_format(PSInfo[ps][psPrice]));
            ShowPlayerDialog(playerid, DIALOG_FUELPRICE, DIALOG_STYLE_INPUT, "Change Fuel Price", cur, "Confirm", "Cancel");
            return 1;
        }
    }
    else if(dialogid == DIALOG_FUELPRICE)
    {
        if(!response) return 1;
        new ps = GetNearbyPS(playerid); if(ps == -1) return 1;
        if(!IsNumeric(inputtext))
        {
            ShowPlayerDialog(playerid, DIALOG_FUELPRICE, DIALOG_STYLE_INPUT, "Change Fuel Price", "{FF0000}You must enter a number!", "Confirm", "Cancel");
            return 1;
        }
        new val = strval(inputtext);
        if(val > 100) return SCM(playerid, COLOR_SYNTAX, "Max price is 100.");
        PSInfo[ps][psPrice] = val;
        mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET price=%d WHERE id=%d", val, PSInfo[ps][psID]);
        mysql_tquery(dbHandle, queryBuffer);
        ReloadPS(ps);
        SCM(playerid, COLOR_AQUA, "Fuel price updated to $%d.", val);
        return 1;
    }
    else if(dialogid == DIALOG_PSWITHDRAW)
    {
        if(!response) return 1;
        new ps = GetNearbyPS(playerid); if(ps == -1) return 1;
        if(PSInfo[ps][psOwnerID] != PlayerInfo[playerid][pID]) return SCM(playerid, COLOR_SYNTAX, "Only owner can access vault.");
        // listitem 0 = Deposit, 1 = Withdraw
        if(listitem == 0)
        {
            ShowPlayerDialog(playerid, DIALOG_PSDEPOSIT, DIALOG_STYLE_INPUT, "Deposit to Vault", "Enter amount to deposit:", "Confirm", "Cancel");
            return 1;
        }
        else if(listitem == 1)
        {
            ShowPlayerDialog(playerid, DIALOG_PSWITHDRAW, DIALOG_STYLE_INPUT, "Withdraw from Vault", "Enter amount to withdraw:", "Confirm", "Cancel");
            return 1;
        }
    }
    else if(dialogid == DIALOG_PSWITHDRAW)
    {
        if(!response) return 1;
        new ps = GetNearbyPS(playerid); if(ps == -1) return 1;
        if(!IsNumeric(inputtext))
        {
            ShowPlayerDialog(playerid, DIALOG_PSWITHDRAW, DIALOG_STYLE_INPUT, "Withdraw from Vault", "{FF0000}You must enter a number!", "Confirm", "Cancel");
            return 1;
        }
        new money = strval(inputtext);
        if(money > PSInfo[ps][psCash]) return SCM(playerid, COLOR_SYNTAX, "Vault doesn't have that much.");
        PSInfo[ps][psCash] -= money;
        GivePlayerCash(playerid, money);
        mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET cash=%d WHERE id=%d", PSInfo[ps][psCash], PSInfo[ps][psID]);
        mysql_tquery(dbHandle, queryBuffer);
        SCM(playerid, COLOR_AQUA, "You withdrew $%s from the vault.", number_format(money));
        return 1;
    }
    else if(dialogid == DIALOG_PSDEPOSIT)
    {
        if(!response) return 1;
        new ps = GetNearbyPS(playerid); if(ps == -1) return 1;
        if(!IsNumeric(inputtext))
        {
            ShowPlayerDialog(playerid, DIALOG_PSDEPOSIT, DIALOG_STYLE_INPUT, "Deposit to Vault", "{FF0000}You must enter a number!", "Confirm", "Cancel");
            return 1;
        }
        new money = strval(inputtext);
        if(money > pData[playerid][pCash]) return SCM(playerid, COLOR_SYNTAX, "You don't have that much cash.");
        PSInfo[ps][psCash] += money;
        GivePlayerCash(playerid, -money);
        mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET cash=%d WHERE id=%d", PSInfo[ps][psCash], PSInfo[ps][psID]);
        mysql_tquery(dbHandle, queryBuffer);
        SCM(playerid, COLOR_AQUA, "You deposited $%s into the vault.", number_format(money));
        return 1;
    }

    return 1;
}

// ========================= Refuel mechanic (command + timer) =========================
CMD:refuel(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID) return SCM(playerid, COLOR_SYNTAX, "You must be in a vehicle to refuel.");
    new ps = GetNearbyPS(playerid);
    if(ps == -1) return SCM(playerid, COLOR_SYNTAX, "You need to be at a petrol station to refuel.");

    if(Refueling[playerid])
    {
        Refueling[playerid] = false;
        RefuelVeh[playerid] = INVALID_VEHICLE_ID;
        RefuelAmount[playerid] = 0;
        RefuelStation[playerid] = -1;
        return SCM(playerid, COLOR_AQUA, "Refueling stopped.");
    }

    // start refueling
    Refueling[playerid] = true;
    RefuelVeh[playerid] = vehicleid;
    RefuelAmount[playerid] = 0;
    RefuelStation[playerid] = ps;
    SetTimerEx("RefuelTick", REFUEL_TICK_MS, true, "i", playerid);
    SCM(playerid, COLOR_AQUA, "Refueling started. Type /refuel again to stop.");
    return 1;
}

public RefuelTick(playerid)
{
    if(!Refueling[playerid]) { KillTimerEx("RefuelTick", "i", playerid); return 1; }
    if(!IsPlayerConnected(playerid)) { Refueling[playerid] = false; return 1; }

    new vehicleid = RefuelVeh[playerid];
    if(!IsValidVehicle(vehicleid) || GetPlayerVehicleID(playerid) != vehicleid)
    {
        Refueling[playerid] = false;
        SCM(playerid, COLOR_SYNTAX, "Refuel canceled (not in same vehicle).");
        return 1;
    }

    new ps = RefuelStation[playerid];
    if(ps == -1 || !PSInfo[ps][psExists]) { Refueling[playerid] = false; return 1; }

    // increment vehicle fuel and cost
    if(vehicleid >= 0 && vehicleid < MAX_VEHICLES)
    {
        vehicleFuel[vehicleid]++;
        RefuelAmount[playerid] += PSInfo[ps][psPrice];

        // if full or player broke
        if(vehicleFuel[vehicleid] >= 100 || pData[playerid][pCash] < RefuelAmount[playerid])
        {
            // finalize
            AddPointMoney(POINT_FUEL, RefuelAmount[playerid]); // optional: uses your point system
            GivePlayerCash(playerid, -RefuelAmount[playerid]);
            PSInfo[ps][psCash] += RefuelAmount[playerid];

            mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET cash=%d, litre=%d WHERE id=%d",
                PSInfo[ps][psCash], max(0, PSInfo[ps][psLitre] - vehicleFuel[vehicleid]), PSInfo[ps][psID]);
            mysql_tquery(dbHandle, queryBuffer);

            SCM(playerid, COLOR_AQUA, "Refuel completed. You paid $%s.", number_format(RefuelAmount[playerid]));
            Refueling[playerid] = false;
            RefuelVeh[playerid] = INVALID_VEHICLE_ID;
            RefuelAmount[playerid] = 0;
            RefuelStation[playerid] = -1;
            ReloadPS(ps);
            return 1;
        }
    }
    return 1;
}

// ========================= Robbery (simple) =========================
CMD:robps(playerid, params[])
{
    new ps = GetNearbyPS(playerid);
    if(ps == -1) return SCM(playerid, COLOR_SYNTAX, "You need to be at a petrol station to start a robbery.");
    if(PSInfo[ps][psCash] < 100) return SCM(playerid, COLOR_SYNTAX, "Too little cash in the vault to rob.");

    new now = time();
    if(RobCooldown[ps] > now) return SCM(playerid, COLOR_SYNTAX, "This station is still on cooldown.");

    // Start robbery: simple mechanic - 20s 'hold' with chance to fail if move far away
    SCM(playerid, COLOR_RED, "Robbery started! Stay near the vault for 20 seconds.");
    SetTimerEx("FinishRobbery", 20000, false, "ii", playerid, ps);
    RobCooldown[ps] = now + ROB_COOLDOWN;
    return 1;
}

public FinishRobbery(playerid, ps)
{
    if(!IsPlayerConnected(playerid)) return 1;
    // Must remain in range
    if(!IsPlayerInRangeOfPoint(playerid, 6.0, PSInfo[ps][psPosX], PSInfo[ps][psPosY], PSInfo[ps][psPosZ]))
    {
        SCM(playerid, COLOR_SYNTAX, "You moved too far. Robbery failed.");
        return 1;
    }

    // success with loot = random 20-60% of vault
    new loot = PSInfo[ps][psCash] * (Random(20,60) / 100.0);
    if(loot < 50) loot = min(PSInfo[ps][psCash], 50); // ensure some money
    PSInfo[ps][psCash] -= loot;
    GivePlayerCash(playerid, loot);

    mysql_format(dbHandle, queryBuffer, sizeof(queryBuffer), "UPDATE petrolstation SET cash=%d WHERE id=%d", PSInfo[ps][psCash], PSInfo[ps][psID]);
    mysql_tquery(dbHandle, queryBuffer);

    SCM(playerid, COLOR_RED, "Robbery successful! You got $%s.", number_format(loot));
    SendClientMessageToAll(0xFF0000AA, "Alert: A petrol station robbery has just happened!"); // notify all
    ReloadPS(ps);
    return 1;
}
