//============================================================================//
// BETTING SYSTEM
//============================================================================//
#define DIALOG_BOXINGEVENT_MENU 		8870
#define DIALOG_BOXINGEVENT_BET 			8871
#define TEAM_HIT_COLOR 0xFFFFFF00
#define TEAM_BLUE_COLOR 0x2641FE00

enum E_TALPKAN_INFO
{
    bool:e_bTalpak,
    bool:e_bLockBet,
    e_iStartTime,
    e_iRedTotalBet,
    e_iRedNumberOfBet,
    e_iRedPlayerid,
    e_iBlueTotalBet,
    e_iBluePlayerid,
    e_iBlueNumberOfBet,
    e_iTalpakArea
}

new TalpakData[E_TALPKAN_INFO];
new Text:gtd_TalpakUI[6];
new PlayerText:ptd_playerBetMessage[MAX_PLAYERS];
new Float:arrTalpakPosition[][4] = {
/*	  X 	 Y 	     Z 		Angle */
	{1041.7264,-902.4476,43.4689,313.9807}, // Red
    {1046.0197,-897.8440,43.4689,140.3924} // Blue
};
new Float:arrTalpakAreaPosition[6] = {
    1043.9049, // Position X
    -899.7435, // Position Y
    43.4689, // Position Z
    100.0, // Range
    0.0, // Virtual World
    0.0 // Interior World
};

CreateTalpakGUI()
{
    gtd_TalpakUI[0] = TextDrawCreate(265.000000, 267.000000, "MERON");
	TextDrawFont(gtd_TalpakUI[0], 1);
	TextDrawLetterSize(gtd_TalpakUI[0], 0.329165, 1.149999);
	TextDrawTextSize(gtd_TalpakUI[0], 350.000000, 96.500000);
	TextDrawSetOutline(gtd_TalpakUI[0], 1);
	TextDrawSetShadow(gtd_TalpakUI[0], 0);
	TextDrawAlignment(gtd_TalpakUI[0], 2);
	TextDrawColor(gtd_TalpakUI[0], -1);
	TextDrawBackgroundColor(gtd_TalpakUI[0], 255);
	TextDrawBoxColor(gtd_TalpakUI[0], -16776961);
	TextDrawUseBox(gtd_TalpakUI[0], 1);
	TextDrawSetProportional(gtd_TalpakUI[0], 1);
	TextDrawSetSelectable(gtd_TalpakUI[0], 0);

	gtd_TalpakUI[1] = TextDrawCreate(365.000000, 267.000000, "WALA");
	TextDrawFont(gtd_TalpakUI[1], 1);
	TextDrawLetterSize(gtd_TalpakUI[1], 0.329165, 1.149999);
	TextDrawTextSize(gtd_TalpakUI[1], 350.000000, 96.500000);
	TextDrawSetOutline(gtd_TalpakUI[1], 1);
	TextDrawSetShadow(gtd_TalpakUI[1], 0);
	TextDrawAlignment(gtd_TalpakUI[1], 2);
	TextDrawColor(gtd_TalpakUI[1], -1);
	TextDrawBackgroundColor(gtd_TalpakUI[1], 255);
	TextDrawBoxColor(gtd_TalpakUI[1], 65535);
	TextDrawUseBox(gtd_TalpakUI[1], 1);
	TextDrawSetProportional(gtd_TalpakUI[1], 1);
	TextDrawSetSelectable(gtd_TalpakUI[1], 0);

	gtd_TalpakUI[2] = TextDrawCreate(265.000000, 282.000000, "_");
	TextDrawFont(gtd_TalpakUI[2], 1);
	TextDrawLetterSize(gtd_TalpakUI[2], 0.600000, 10.300003);
	TextDrawTextSize(gtd_TalpakUI[2], 303.000000, 96.500000);
	TextDrawSetOutline(gtd_TalpakUI[2], 1);
	TextDrawSetShadow(gtd_TalpakUI[2], 0);
	TextDrawAlignment(gtd_TalpakUI[2], 2);
	TextDrawColor(gtd_TalpakUI[2], -1);
	TextDrawBackgroundColor(gtd_TalpakUI[2], 255);
	TextDrawBoxColor(gtd_TalpakUI[2], 135);
	TextDrawUseBox(gtd_TalpakUI[2], 1);
	TextDrawSetProportional(gtd_TalpakUI[2], 1);
	TextDrawSetSelectable(gtd_TalpakUI[2], 0);

	gtd_TalpakUI[3] = TextDrawCreate(365.000000, 282.000000, "_");
	TextDrawFont(gtd_TalpakUI[3], 1);
	TextDrawLetterSize(gtd_TalpakUI[3], 0.600000, 10.300003);
	TextDrawTextSize(gtd_TalpakUI[3], 303.000000, 96.500000);
	TextDrawSetOutline(gtd_TalpakUI[3], 1);
	TextDrawSetShadow(gtd_TalpakUI[3], 0);
	TextDrawAlignment(gtd_TalpakUI[3], 2);
	TextDrawColor(gtd_TalpakUI[3], -1);
	TextDrawBackgroundColor(gtd_TalpakUI[3], 255);
	TextDrawBoxColor(gtd_TalpakUI[3], 135);
	TextDrawUseBox(gtd_TalpakUI[3], 1);
	TextDrawSetProportional(gtd_TalpakUI[3], 1);
	TextDrawSetSelectable(gtd_TalpakUI[3], 0);

	gtd_TalpakUI[4] = TextDrawCreate(265.000000, 306.000000, "~r~Total Bet~n~~y~$100,000,000");
	TextDrawFont(gtd_TalpakUI[4], 1);
	TextDrawLetterSize(gtd_TalpakUI[4], 0.183332, 1.000000);
	TextDrawTextSize(gtd_TalpakUI[4], 400.000000, 96.000000);
	TextDrawSetOutline(gtd_TalpakUI[4], 1);
	TextDrawSetShadow(gtd_TalpakUI[4], 0);
	TextDrawAlignment(gtd_TalpakUI[4], 2);
	TextDrawColor(gtd_TalpakUI[4], -1);
	TextDrawBackgroundColor(gtd_TalpakUI[4], 255);
	TextDrawBoxColor(gtd_TalpakUI[4], 0);
	TextDrawUseBox(gtd_TalpakUI[4], 1);
	TextDrawSetProportional(gtd_TalpakUI[4], 1);
	TextDrawSetSelectable(gtd_TalpakUI[4], 0);

	gtd_TalpakUI[5] = TextDrawCreate(365.000000, 306.000000, "~b~Total Bet~n~~y~$100,000,000");
	TextDrawFont(gtd_TalpakUI[5], 1);
	TextDrawLetterSize(gtd_TalpakUI[5], 0.183332, 1.000000);
	TextDrawTextSize(gtd_TalpakUI[5], 400.000000, 96.000000);
	TextDrawSetOutline(gtd_TalpakUI[5], 1);
	TextDrawSetShadow(gtd_TalpakUI[5], 0);
	TextDrawAlignment(gtd_TalpakUI[5], 2);
	TextDrawColor(gtd_TalpakUI[5], -1);
	TextDrawBackgroundColor(gtd_TalpakUI[5], 255);
	TextDrawBoxColor(gtd_TalpakUI[5], 0);
	TextDrawUseBox(gtd_TalpakUI[5], 1);
	TextDrawSetProportional(gtd_TalpakUI[5], 1);
	TextDrawSetSelectable(gtd_TalpakUI[5], 0);

    /*
	gtd_TalpakRedWinUI[0] = TextDrawCreate(228.000000, 340.000000, "ld_pool:ball");
	TextDrawFont(gtd_TalpakRedWinUI[0], 4);
	TextDrawLetterSize(gtd_TalpakRedWinUI[0], 0.600000, 2.000000);
	TextDrawTextSize(gtd_TalpakRedWinUI[0], 17.000000, 17.000000);
	TextDrawSetOutline(gtd_TalpakRedWinUI[0], 1);
	TextDrawSetShadow(gtd_TalpakRedWinUI[0], 0);
	TextDrawAlignment(gtd_TalpakRedWinUI[0], 1);
	TextDrawColor(gtd_TalpakRedWinUI[0], 9109759);
	TextDrawBackgroundColor(gtd_TalpakRedWinUI[0], 255);
	TextDrawBoxColor(gtd_TalpakRedWinUI[0], 50);
	TextDrawUseBox(gtd_TalpakRedWinUI[0], 1);
	TextDrawSetProportional(gtd_TalpakRedWinUI[0], 1);
	TextDrawSetSelectable(gtd_TalpakRedWinUI[0], 0);

	gtd_TalpakRedWinUI[1] = TextDrawCreate(256.000000, 340.000000, "ld_pool:ball");
	TextDrawFont(gtd_TalpakRedWinUI[1], 4);
	TextDrawLetterSize(gtd_TalpakRedWinUI[1], 0.600000, 2.000000);
	TextDrawTextSize(gtd_TalpakRedWinUI[1], 17.000000, 17.000000);
	TextDrawSetOutline(gtd_TalpakRedWinUI[1], 1);
	TextDrawSetShadow(gtd_TalpakRedWinUI[1], 0);
	TextDrawAlignment(gtd_TalpakRedWinUI[1], 1);
	TextDrawColor(gtd_TalpakRedWinUI[1], -1);
	TextDrawBackgroundColor(gtd_TalpakRedWinUI[1], 255);
	TextDrawBoxColor(gtd_TalpakRedWinUI[1], 50);
	TextDrawUseBox(gtd_TalpakRedWinUI[1], 1);
	TextDrawSetProportional(gtd_TalpakRedWinUI[1], 1);
	TextDrawSetSelectable(gtd_TalpakRedWinUI[1], 0);

	gtd_TalpakRedWinUI[2] = TextDrawCreate(285.000000, 340.000000, "ld_pool:ball");
	TextDrawFont(gtd_TalpakRedWinUI[2], 4);
	TextDrawLetterSize(gtd_TalpakRedWinUI[2], 0.600000, 2.000000);
	TextDrawTextSize(gtd_TalpakRedWinUI[2], 17.000000, 17.000000);
	TextDrawSetOutline(gtd_TalpakRedWinUI[2], 1);
	TextDrawSetShadow(gtd_TalpakRedWinUI[2], 0);
	TextDrawAlignment(gtd_TalpakRedWinUI[2], 1);
	TextDrawColor(gtd_TalpakRedWinUI[2], -1);
	TextDrawBackgroundColor(gtd_TalpakRedWinUI[2], 255);
	TextDrawBoxColor(gtd_TalpakRedWinUI[2], 50);
	TextDrawUseBox(gtd_TalpakRedWinUI[2], 1);
	TextDrawSetProportional(gtd_TalpakRedWinUI[2], 1);
	TextDrawSetSelectable(gtd_TalpakRedWinUI[2], 0);

	gtd_TalpakBlueWinUI[0] = TextDrawCreate(326.000000, 340.000000, "ld_pool:ball");
	TextDrawFont(gtd_TalpakBlueWinUI[0], 4);
	TextDrawLetterSize(gtd_TalpakBlueWinUI[0], 0.600000, 2.000000);
	TextDrawTextSize(gtd_TalpakBlueWinUI[0], 17.000000, 17.000000);
	TextDrawSetOutline(gtd_TalpakBlueWinUI[0], 1);
	TextDrawSetShadow(gtd_TalpakBlueWinUI[0], 0);
	TextDrawAlignment(gtd_TalpakBlueWinUI[0], 1);
	TextDrawColor(gtd_TalpakBlueWinUI[0], 9109759);
	TextDrawBackgroundColor(gtd_TalpakBlueWinUI[0], 255);
	TextDrawBoxColor(gtd_TalpakBlueWinUI[0], 50);
	TextDrawUseBox(gtd_TalpakBlueWinUI[0], 1);
	TextDrawSetProportional(gtd_TalpakBlueWinUI[0], 1);
	TextDrawSetSelectable(gtd_TalpakBlueWinUI[0], 0);

	gtd_TalpakRedWinUI[1] = TextDrawCreate(356.000000, 340.000000, "ld_pool:ball");
	TextDrawFont(gtd_TalpakRedWinUI[1], 4);
	TextDrawLetterSize(gtd_TalpakRedWinUI[1], 0.600000, 2.000000);
	TextDrawTextSize(gtd_TalpakRedWinUI[1], 17.000000, 17.000000);
	TextDrawSetOutline(gtd_TalpakRedWinUI[1], 1);
	TextDrawSetShadow(gtd_TalpakRedWinUI[1], 0);
	TextDrawAlignment(gtd_TalpakRedWinUI[1], 1);
	TextDrawColor(gtd_TalpakRedWinUI[1], -1);
	TextDrawBackgroundColor(gtd_TalpakRedWinUI[1], 255);
	TextDrawBoxColor(gtd_TalpakRedWinUI[1], 50);
	TextDrawUseBox(gtd_TalpakRedWinUI[1], 1);
	TextDrawSetProportional(gtd_TalpakRedWinUI[1], 1);
	TextDrawSetSelectable(gtd_TalpakRedWinUI[1], 0);

	gtd_TalpakRedWinUI[2] = TextDrawCreate(385.000000, 340.000000, "ld_pool:ball");
	TextDrawFont(gtd_TalpakRedWinUI[2], 4);
	TextDrawLetterSize(gtd_TalpakRedWinUI[2], 0.600000, 2.000000);
	TextDrawTextSize(gtd_TalpakRedWinUI[2], 17.000000, 17.000000);
	TextDrawSetOutline(gtd_TalpakRedWinUI[2], 1);
	TextDrawSetShadow(gtd_TalpakRedWinUI[2], 0);
	TextDrawAlignment(gtd_TalpakRedWinUI[2], 1);
	TextDrawColor(gtd_TalpakRedWinUI[2], -1);
	TextDrawBackgroundColor(gtd_TalpakRedWinUI[2], 255);
	TextDrawBoxColor(gtd_TalpakRedWinUI[2], 50);
	TextDrawUseBox(gtd_TalpakRedWinUI[2], 1);
	TextDrawSetProportional(gtd_TalpakRedWinUI[2], 1);
	TextDrawSetSelectable(gtd_TalpakRedWinUI[2], 0);*/
}

CreatePlayerTalpakGUI(playerid)
{
    ptd_playerBetMessage[playerid] = CreatePlayerTextDraw(playerid, 317.000000, 383.000000, "You bet ~y~$832,232,232~w~ on ~b~blue~w~ you will receive ~g~$233,232,231");
    PlayerTextDrawFont(playerid, ptd_playerBetMessage[playerid], 1);
    PlayerTextDrawLetterSize(playerid, ptd_playerBetMessage[playerid], 0.224999, 1.500000);
    PlayerTextDrawTextSize(playerid, ptd_playerBetMessage[playerid], 400.000000, 362.000000);
    PlayerTextDrawSetOutline(playerid, ptd_playerBetMessage[playerid], 1);
    PlayerTextDrawSetShadow(playerid, ptd_playerBetMessage[playerid], 0);
    PlayerTextDrawAlignment(playerid, ptd_playerBetMessage[playerid], 2);
    PlayerTextDrawColor(playerid, ptd_playerBetMessage[playerid], -1);
    PlayerTextDrawBackgroundColor(playerid, ptd_playerBetMessage[playerid], 255);
    PlayerTextDrawBoxColor(playerid, ptd_playerBetMessage[playerid], 0);
    PlayerTextDrawUseBox(playerid, ptd_playerBetMessage[playerid], 1);
    PlayerTextDrawSetProportional(playerid, ptd_playerBetMessage[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, ptd_playerBetMessage[playerid], 0);
}

InitTalpakData()
{
    TalpakData[e_bTalpak] = false;
    TalpakData[e_bLockBet] = false;
    TalpakData[e_iStartTime] = 3; // Seconds
    TalpakData[e_iRedTotalBet] = 0;
    TalpakData[e_iRedNumberOfBet] = 0;
    TalpakData[e_iRedPlayerid] = INVALID_PLAYER_ID;
    TalpakData[e_iBlueTotalBet] = 0;
    TalpakData[e_iBlueNumberOfBet] = 0;
    TalpakData[e_iBluePlayerid] = INVALID_PLAYER_ID;

    if(!IsValidDynamicArea(TalpakData[e_iTalpakArea]))
    {
        TalpakData[e_iTalpakArea] = CreateDynamicSphere(arrTalpakAreaPosition[0], arrTalpakAreaPosition[1], arrTalpakAreaPosition[2], arrTalpakAreaPosition[3], .worldid = floatround(arrTalpakAreaPosition[4]), .interiorid = floatround(arrTalpakAreaPosition[5]));
    }
}

number_boxformat(number)
{
	new i, string[15];
	FIXES_valstr(string, number);
	if(strfind(string, "-") != -1) i = strlen(string) - 4;
	else i = strlen(string) - 3;
	while (i >= 1)
 	{
		if(strfind(string, "-") != -1) strins(string, ",", i + 1);
		else strins(string, ",", i);
		i -= 3;
	}
	return string;
}


Float:CalculateDifferenceSidebet(red, blue)
{

	new Float:diff = red - blue, Float:diff2 = red + blue;
	new Float:diff3 = diff2 / 2;
	new Float:total = diff / diff3 * 100;
    return (total < 0) ? (total *= -1) : (total);
}

TalpakUpdateRedTotalBet(visual = true)
{
    new szString[100];
    format(szString, sizeof(szString), "~r~Total Bet~n~~y~$%s", number_boxformat(TalpakData[e_iRedTotalBet]));
    TextDrawSetString(gtd_TalpakUI[4], szString);
    if(visual)
    {
        foreach(new playerid : Player)
        {
            if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]) && TalpakData[e_bTalpak])
            {
                TextDrawShowForPlayer(playerid, gtd_TalpakUI[4]);
            }
        }
    }
}

TalpakUpdateBlueTotalBet(visual = true)
{
    new szString[100];
    format(szString, sizeof(szString), "~b~Total Bet~n~~y~$%s", number_boxformat(TalpakData[e_iBlueTotalBet]));
    TextDrawSetString(gtd_TalpakUI[5], szString);

    if(visual)
    {
        foreach(new playerid : Player)
        {
            if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]) && TalpakData[e_bTalpak])
            {
                TextDrawShowForPlayer(playerid, gtd_TalpakUI[5]);
            }
        }
    }
}

ShowTalpakGUIToPlayers()
{
    foreach(new playerid : Player)
    {
        if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]) && TalpakData[e_bTalpak])
        {
            for(new i = 0; i < sizeof(gtd_TalpakUI); i++)
            {
                TextDrawShowForPlayer(playerid, gtd_TalpakUI[i]);
            }
        }
    }
}

ShowTalpakGUIToAPlayer(playerid)
{

    if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]) && TalpakData[e_bTalpak])
    {
        for(new i = 0; i < sizeof(gtd_TalpakUI); i++)
        {
            TextDrawShowForPlayer(playerid, gtd_TalpakUI[i]);
        }
    }
}


HideTalpakGUI(playerid)
{
    for(new i = 0; i < sizeof(gtd_TalpakUI); i++)
    {
        TextDrawHideForPlayer(playerid, gtd_TalpakUI[i]);
    }

    PlayerTextDrawHide(playerid, ptd_playerBetMessage[playerid]);
}


TalpakPlayerUpdateBet(playerid)
{
    if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]) && TalpakData[e_bTalpak] && GetPVarType(playerid, "TALPAKAN::Bet") && GetPVarInt(playerid, "TALPAKAN::Bet") > 0)
    {
        new szMessage[100], bet = GetPVarInt(playerid, "TALPAKAN::Bet"), difference = floatround(CalculateDifferenceSidebet(TalpakData[e_iRedTotalBet], TalpakData[e_iBlueTotalBet]) * 100), fee, team = GetPVarInt(playerid, "TALPAKAN::Team");
        switch(team)
        {
            case 1: // Red
            {
                if(difference > 45) difference = 45;
                if(TalpakData[e_iRedTotalBet] > TalpakData[e_iBlueTotalBet] + 1000000)
                {
                    fee = difference * bet / 100;
                }
                else fee =  20 * bet / 100, difference = 20;
            }
            case 2: // Blue
            {
                if(difference > 45) difference = 45;
                if(TalpakData[e_iBlueTotalBet] > TalpakData[e_iRedTotalBet] + 1000000)
                {
                    fee = difference * bet / 100;
                }
                else fee =  20 * bet / 100, difference = 20;
            }
        }
        CreatePlayerTalpakGUI(playerid);
        format(szMessage, sizeof(szMessage), "You bet ~y~$%s~w~ on %s you will receive ~g~$%s (-%d%%)", number_boxformat(bet), (team == 1) ?  ("~r~Meron~w~") : ("~b~Wala~w~") ,number_boxformat((bet * 2) - fee), difference);
        PlayerTextDrawSetString(playerid, ptd_playerBetMessage[playerid], szMessage);
        PlayerTextDrawShow(playerid, ptd_playerBetMessage[playerid]);
    }
}

ShowTalpakBetMenu(playerid, dialogid)
{
    new szDialog[800], szTitle[144], dialog_style, szButton[2][32];
    switch(dialogid)
    {
        case DIALOG_BOXINGEVENT_MENU:
        {
            format(szDialog, sizeof(szDialog), "Player Name\tTeam\tTotal Bet\tNumber of Bets\n\
                %s\t{FF0000}Meron\t$%s\t%s\n\
                %s\t{0000FF}Wala\t$%s\t%s",

                GetPlayerNameEx(TalpakData[e_iRedPlayerid]),
                number_boxformat(TalpakData[e_iRedTotalBet]),
                number_boxformat(TalpakData[e_iRedNumberOfBet]),

                GetPlayerNameEx(TalpakData[e_iBluePlayerid]),
                number_boxformat(TalpakData[e_iBlueTotalBet]),
                number_boxformat(TalpakData[e_iBlueNumberOfBet])
            );

            format(szTitle, sizeof(szTitle), "Luminous Gaming Betting");
            dialog_style = DIALOG_STYLE_TABLIST_HEADERS;
            szButton[0] = "Choose";
            szButton[1] = "Close";

        }
        case DIALOG_BOXINGEVENT_BET:
        {
            new type = GetPVarInt(playerid, "TALPAKAN::Type");
            switch(type)
            {
                case 1:
                {
                    format(szDialog, sizeof(szDialog), "{FFFFFF}You are about to place a bet on %s {FF0000}Meron{FFFFFF}!\n\
                        Minimum Bet:{FFFFFF} $5,000\nMaximum Bet:{FFFFFF} $500,000\n\
                        {FFFF00}----------------------------------------\n\
                        {FF0000}Note: Once you lock your bet you won't able to turn back!\nWe're not responsible of your bet once you get DISCONNECTED from the Server so make sure\nBet Responsibly.\n\n\
                        Total of Bet:{FFFFFF} $%s\nNumber of Bet:{FFFFFF} %s\n\n{FFFF00}Please input your amount of bet below.",
                         GetPlayerNameEx(TalpakData[e_iRedPlayerid]),
                        number_boxformat(TalpakData[e_iRedTotalBet]),
                        number_boxformat(TalpakData[e_iRedNumberOfBet])
                    );
                    format(szTitle, sizeof(szTitle), "Luminous Gaming Betting");
                    dialog_style = DIALOG_STYLE_INPUT;
                    szButton[0] = "Lock Bet";
                    szButton[1] = "Close";
                }
                case 2:
                {
                    format(szDialog, sizeof(szDialog), "{FFFFFF}You are about to place a bet on %s {0000FF}Wala{FFFFFF}!\n\
                        Minimum Bet:{FFFFFF} $5,000\nMaximum Bet:{FFFFFF} $500,000\n\
                        {FFFF00}----------------------------------------\n\
                        {FF0000}Note: Once you lock your bet you won't able to turn back!\nWe're not responsible of your bet once you get DISCONNECTED from the Server so make sure\nBet Responsibly.\n\n\
                        Total of Bet:{FFFFFF} $%s\nNumber of Bet:{FFFFFF} %s\n\n{FFFF00}Please input your amount of bet below.",
                        GetPlayerNameEx(TalpakData[e_iBluePlayerid]),
                        number_boxformat(TalpakData[e_iBlueTotalBet]),
                        number_boxformat(TalpakData[e_iBlueNumberOfBet])
                    );
                    format(szTitle, sizeof(szTitle), "Luminous Gaming Betting");
                    dialog_style = DIALOG_STYLE_INPUT;
                    szButton[0] = "Lock Bet";
                    szButton[1] = "Close";
                }
            }
        }
    }
    return ShowPlayerDialog(playerid, dialogid, dialog_style, szTitle, szDialog, szButton[0], szButton[1]);
}

EndTalpakEvent()
{
    if(IsPlayerConnected(TalpakData[e_iRedPlayerid]))
    {
        SetPlayerColor(TalpakData[e_iRedPlayerid], TEAM_HIT_COLOR);
        SetPlayerSkin(TalpakData[e_iRedPlayerid], PlayerInfo[TalpakData[e_iRedPlayerid]][pSkin]);

        SetPlayerPos(TalpakData[e_iRedPlayerid], GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldX"), GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldY"), GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldZ"));
        SetPlayerHealth(TalpakData[e_iRedPlayerid], GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldHealth"));

        if(GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldArmor") > 0.0) {
            SetPlayerArmour(TalpakData[e_iRedPlayerid], GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldArmor"));
        }
        else SetPlayerArmour(TalpakData[e_iRedPlayerid], 0);

        SetPlayerVirtualWorld(TalpakData[e_iRedPlayerid], GetPVarInt(TalpakData[e_iRedPlayerid], "TALPAKAN::OldVW"));
        SetPlayerInterior(TalpakData[e_iRedPlayerid], GetPVarInt(TalpakData[e_iRedPlayerid], "TALPAKAN::OldInt"));
        //PlayerInfo[TalpakData[e_iRedPlayerid]][pVW] = GetPVarInt(TalpakData[e_iRedPlayerid], "TALPAKAN::OldVW");
        //PlayerInfo[TalpakData[e_iRedPlayerid]][pInt] = GetPVarInt(TalpakData[e_iRedPlayerid], "TALPAKAN::OldInt");
        //Player_StreamPrep(TalpakData[e_iRedPlayerid], GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldX"), GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldY"), GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldZ"), FREEZE_TIME);

        SetPlayerPos(TalpakData[e_iRedPlayerid], GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldX"), GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldY"), GetPVarFloat(TalpakData[e_iRedPlayerid], "TALPAKAN::OldZ"));
        //SetPlayerFightingStyle(TalpakData[e_iRedPlayerid], PlayerInfo[TalpakData[e_iRedPlayerid]][pFightStyle]);

        SetPlayerWeapons(TalpakData[e_iRedPlayerid]);

    }

    if(IsPlayerConnected(TalpakData[e_iBluePlayerid]))
    {
        SetPlayerColor(TalpakData[e_iBluePlayerid], TEAM_HIT_COLOR);
        SetPlayerSkin(TalpakData[e_iBluePlayerid], PlayerInfo[TalpakData[e_iBluePlayerid]][pSkin]);

        SetPlayerPos(TalpakData[e_iBluePlayerid], GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldX"), GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldY"), GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldZ"));
        SetPlayerHealth(TalpakData[e_iBluePlayerid], 100);

        if(GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldArmor") > 0.0) {
            SetPlayerArmour(TalpakData[e_iBluePlayerid], GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldArmor"));
        }
        else SetPlayerArmour(TalpakData[e_iBluePlayerid], 0);

        SetPlayerVirtualWorld(TalpakData[e_iBluePlayerid], GetPVarInt(TalpakData[e_iBluePlayerid], "TALPAKAN::OldVW"));
        SetPlayerInterior(TalpakData[e_iBluePlayerid], GetPVarInt(TalpakData[e_iBluePlayerid], "TALPAKAN::OldInt"));
        //PlayerInfo[TalpakData[e_iBluePlayerid]][pVW] = GetPVarInt(TalpakData[e_iBluePlayerid], "TALPAKAN::OldVW");
        //PlayerInfo[TalpakData[e_iBluePlayerid]][pInt] = GetPVarInt(TalpakData[e_iBluePlayerid], "TALPAKAN::OldInt");
        //Player_StreamPrep(TalpakData[e_iBluePlayerid], GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldX"), GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldY"), GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldZ"), FREEZE_TIME);
        SetPlayerPos(TalpakData[e_iBluePlayerid], GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldX"), GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldY"), GetPVarFloat(TalpakData[e_iBluePlayerid], "TALPAKAN::OldZ"));
        //SetPlayerFightingStyle(TalpakData[e_iBluePlayerid], PlayerInfo[TalpakData[e_iBluePlayerid]][pFightStyle]);

        SetPlayerWeapons(TalpakData[e_iBluePlayerid]);

    }
    foreach(new playerid : Player)
    {
        DeletePVar(playerid, "TALPAKAN::Bet");
        DeletePVar(playerid, "TALPAKAN::Team");
        HideTalpakGUI(playerid);
    }
    InitTalpakData();
}

forward TalpakDelayTick();
public TalpakDelayTick()
{
    new szMessage[144];
    if(!TalpakData[e_bTalpak]) return 1;

    if(!IsPlayerConnected(TalpakData[e_iRedPlayerid]) || !IsPlayerConnected(TalpakData[e_iBluePlayerid]))
    {
        SendClientMessageToAll(COLOR_WHITE, "Talpakan match ended due to the opposite side has disconnected.");
        EndTalpakEvent();
        return 1;
    }

    if(TalpakData[e_iStartTime] <= 0)
    {
        foreach(new playerid : Player)
        {
            if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]))
            {
                format(szMessage, sizeof(szMessage), "~y~Match Start!~n~~r~Meron~w~ VS ~b~Wala~n~~g~Fight!");
                GameTextForPlayer(playerid, szMessage, 3500, 4);
            }
        }

        TalpakData[e_iStartTime] = 0;
        TalpakData[e_bLockBet] = true;
        TogglePlayerControllable(TalpakData[e_iRedPlayerid], true);
        TogglePlayerControllable(TalpakData[e_iBluePlayerid], true);
        SetPlayerColor(TalpakData[e_iRedPlayerid], COLOR_RED);
        SetPlayerColor(TalpakData[e_iBluePlayerid], TEAM_BLUE_COLOR);
        return 1;
    }

    TalpakData[e_iStartTime]--;

    new szString[100];
    foreach(new playerid : Player)
    {
        if(IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]))
        {
            format(szString, sizeof(szString), "~y~Match between~n~~r~Meron~w~ VS ~b~Wala~n~~y~%d~w~ seconds before it start.", TalpakData[e_iStartTime]);
		    GameTextForPlayer(playerid, szString, 1000, 4);
        }
    }
    SetTimer("TalpakDelayTick", 1000, false);
    return 1;
}

CMD:talpak(playerid, params[])
{
    if(PlayerInfo[playerid][pEventMod] < 1)
	    return SCM(playerid, COLOR_SYNTAX, "You are not authorized to use this command.");

	new blueplayerid, redplayerid, delay;
	if(sscanf(params, "uudddd", blueplayerid, redplayerid, delay))
		return SendClientMessage(playerid, COLOR_LIGHTBLUE, "Usage: "WHITE"/talpak [blue playerid] [red playerid] [delay]");

    if(!IsPlayerConnected(blueplayerid))
        return SendClientMessage(playerid, COLOR_GRAD1, "That player isn't connected!");

    if(!IsPlayerConnected(redplayerid))
        return SendClientMessage(playerid, COLOR_GRAD1, "That player isn't connected!");

    if(TalpakData[e_bTalpak])
        return SendClientMessage(playerid, COLOR_GRAD1, "There's already on going Talpak Event!");

    if(delay < 10 || delay > 120)
        return SendClientMessage(playerid, COLOR_GRAD1, "Delay cannot be higher than 120 Seconds and lower than 10 seconds");

    if(!IsPlayerInDynamicArea(redplayerid, TalpakData[e_iTalpakArea]))
        return SendClientMessage(playerid, COLOR_GRAD1, "That player isn't inside of the talpak arena!");

    if(!IsPlayerInDynamicArea(blueplayerid, TalpakData[e_iTalpakArea]))
        return SendClientMessage(playerid, COLOR_GRAD1, "That player isn't inside of the talpak arena!");

    new szString[128];

    // Red
    SetPlayerSkin(redplayerid, 80);
    for(new x;x < 9;x++) RemovePlayerAttachedObject(redplayerid, x);

    SetPVarInt(redplayerid, "TALPAKAN::IsIn", 1);

    new Float:oldX, Float:oldY, Float:oldZ, Float:oldHealth, Float:oldArmor;
    GetPlayerPos(redplayerid, oldX, oldY, oldZ);

    SetPVarFloat(redplayerid, "TALPAKAN::OldX", oldX);
    SetPVarFloat(redplayerid, "TALPAKAN::OldY", oldY);
    SetPVarFloat(redplayerid, "TALPAKAN::OldZ", oldZ);

    GetPlayerHealth(redplayerid,oldHealth);
    GetPlayerArmour(redplayerid,oldArmor);

    SetPVarInt(redplayerid, "TALPAKAN::OldInt", GetPlayerInterior(redplayerid));
    SetPVarInt(redplayerid, "TALPAKAN::OldVW", GetPlayerVirtualWorld(redplayerid));
    SetPVarFloat(redplayerid, "TALPAKAN::OldHealth", oldHealth);
    SetPVarFloat(redplayerid, "TALPAKAN::OldArmor", oldArmor);


    SetPlayerColor(redplayerid, COLOR_RED);
    SetPlayerFightingStyle(redplayerid, 5);
    SetPlayerHealth(redplayerid, 100.0);
    SetPlayerArmour(redplayerid, 100.0);

    SetPlayerPos(redplayerid, arrTalpakPosition[0][0], arrTalpakPosition[0][1], arrTalpakPosition[0][2]); // Change this position for Red

    SetPlayerFacingAngle(redplayerid, arrTalpakPosition[0][3]);
    TogglePlayerControllable(redplayerid, false);


    format(szString, sizeof(szString), "* You're not able to move at this moment, please wait till the round start in %d seconds", delay);
    SendClientMessage(redplayerid, COLOR_YELLOW, szString);

    ResetPlayerWeapons(redplayerid);

    // Blue
    SetPlayerSkin(blueplayerid, 81);
    for(new x;x < 9;x++) RemovePlayerAttachedObject(blueplayerid, x);


    SetPVarInt(blueplayerid, "TALPAKAN::IsIn", 1);
    GetPlayerPos(blueplayerid, oldX, oldY, oldZ);

    SetPVarFloat(blueplayerid, "TALPAKAN::OldX", oldX);
    SetPVarFloat(blueplayerid, "TALPAKAN::OldY", oldY);
    SetPVarFloat(blueplayerid, "TALPAKAN::OldZ", oldZ);

    GetPlayerHealth(blueplayerid,oldHealth);
    GetPlayerArmour(blueplayerid,oldArmor);
    SetPVarInt(blueplayerid, "TALPAKAN::OldInt", GetPlayerInterior(blueplayerid));
    SetPVarInt(blueplayerid, "TALPAKAN::OldVW", GetPlayerVirtualWorld(blueplayerid));
    SetPVarFloat(blueplayerid, "TALPAKAN::OldHealth", oldHealth);
    SetPVarFloat(blueplayerid, "TALPAKAN::OldArmor", oldArmor);

    SetPlayerColor(blueplayerid, TEAM_BLUE_COLOR);
    SetPlayerHealth(blueplayerid, 100.0);
    SetPlayerArmour(blueplayerid, 100.0);
    SetPlayerPos(blueplayerid, arrTalpakPosition[1][0], arrTalpakPosition[1][1], arrTalpakPosition[1][2]);
    SetPlayerFacingAngle(blueplayerid, arrTalpakPosition[0][3]);
    SetPlayerFightingStyle(blueplayerid, 5);
    TogglePlayerControllable(blueplayerid, false);

    format(szString, sizeof(szString), "You're not able to move at this moment, please wait till the round start in %d seconds", delay);
    SendClientMessage(blueplayerid, COLOR_YELLOW, szString);

    ResetPlayerWeapons(blueplayerid);

    TalpakData[e_bTalpak] = true;
    TalpakData[e_bLockBet] =  false;

    TalpakData[e_iRedPlayerid] = redplayerid;
    TalpakData[e_iRedTotalBet] = 0;

    TalpakData[e_iBluePlayerid] = blueplayerid;

    TalpakData[e_iBlueTotalBet] = 0;

    TalpakData[e_iStartTime] = delay;
    TalpakUpdateRedTotalBet(false);
    TalpakUpdateBlueTotalBet(false);

    ShowTalpakGUIToPlayers();

    new szMessage[128];
	format(szMessage, sizeof(szMessage), "%s as {FF0000}Meron{FFFFFF} vs %s as {0000FF}Wala{FFFFFF} match starts in %d Seconds.", GetPlayerNameEx(TalpakData[e_iRedPlayerid]), GetPlayerNameEx(TalpakData[e_iBluePlayerid]), TalpakData[e_iStartTime]);
	SendClientMessageToAll(COLOR_WHITE, szMessage);
    SendClientMessageToAll(COLOR_WHITE, "You can now start betting . (/bet)");

    SetTimer("TalpakDelayTick", 1000, false);
	return 1;
}

CMD:endfight(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 7)
          return SendClientMessage(playerid, COLOR_GREY, "You are not authorized to use this command.");

    if(!PlayerInfo[playerid][pAdminDuty])
        return SendClientMessage(playerid, COLOR_GREY, "You must be on duty to use this command");

    if(!TalpakData[e_bTalpak])
        return SendClientMessage(playerid, COLOR_GRAD1, "There were no active talpakan on going in the arena.");

    new szMessage[128];
	format(szMessage, sizeof(szMessage), "The talpakan fight ended by Administrator %s", GetPlayerNameEx(playerid));
	SendClientMessageToAll(COLOR_WHITE, szMessage);

    foreach(new extraid : Player)
    {
        if(GetPVarType(extraid, "TALPAKAN::Team") && GetPVarInt(extraid, "TALPAKAN::Bet") > 0)
        {
            GivePlayerCash(extraid, GetPVarInt(extraid, "TALPAKAN::Bet"));
            SendClientMessage(extraid, COLOR_YELLOW, "Talpakan: Your bet has been refunded due to administrator end the match.");
        }
    }

    EndTalpakEvent();
    InitTalpakData();
    return 1;
}

CMD:bet(playerid, params[])
{
    if(!IsPlayerInDynamicArea(playerid, TalpakData[e_iTalpakArea]))
        return  SendClientMessage(playerid, COLOR_GRAD1, "You're not inside of the talpak arena!");

    if(!TalpakData[e_bTalpak])
        return  SendClientMessage(playerid, COLOR_GRAD1, "There we're no ongoing talpakan in the Arena!");

    if(TalpakData[e_bLockBet])
        return SendClientMessage(playerid, COLOR_GRAD1, "You can no longer place a sidebet as the talpak round has started!");

    if(GetPVarType(playerid, "TALPAKAN::Team"))
        return SendClientMessage(playerid, COLOR_GRAD1, "You already place a bet on a team!");

    if(TalpakData[e_iRedPlayerid] == playerid)
        return SendClientMessage(playerid, COLOR_GRAD1, "You cannot place a bet while participating.");

    if(TalpakData[e_iBluePlayerid] == playerid)
        return SendClientMessage(playerid, COLOR_GRAD1, "You cannot place a bet while participating.");

    ShowTalpakBetMenu(playerid, DIALOG_BOXINGEVENT_MENU);
    return 1;
}
