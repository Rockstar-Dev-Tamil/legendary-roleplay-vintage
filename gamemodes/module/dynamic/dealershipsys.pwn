//============================================================================//

// DYNAMIC DEALERSHIP SYSTEM

//============================================================================//

#define MAX_DEALERSHIP_CARS         1000

enum e_Dealership

{

    dcID,

    dcExists,

    dcCompany,

    dcModel,

    dcPrice

};



new DealershipCars[MAX_DEALERSHIP_CARS][e_Dealership];



/*new const vehicleNames[212][] = {

    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",

    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",

    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",

    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Article Trailer", "Previon", "Coach",

    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",

    "Pizzaboy", "Tram", "Article Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",

    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",

    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",

    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",

    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",

    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",

    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain",

    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",

    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",

    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",

    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",

    "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",

    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",

    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Petrol Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",

    "Freight Box", "Article Trailer 3", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Car", "SFPD Car", "LVPD Car",

    "Police Rancher", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",

    "Boxville", "Tiller", "Utility Trailer"

};*/



GetVehicleModelFromName(const string[])

{

    new

        modelid = strval(string);



    if (400 <= modelid <= 611)

    {

        return modelid;

    }

    else

    {

        for (new i = 0; i < sizeof(vehicleNames); i ++)

        {

            if (strfind(vehicleNames[i], string, true) != -1)

            {

                modelid = i + 400;



                return modelid;

            }

        }

    }

    return 0;

}



GetVehicleModelName(modelid)

{

    new string[32];



    if (400 <= modelid <= 611)

        strcpy(string, vehicleNames[modelid - 400]);



    else

        string = "Unknown";



    return string;

}



IsVehicleSpawnSetup(company)

{

    return (BusinessInfo[company][cVehicle][0] != 0.0 && BusinessInfo[company][cVehicle][1] != 0.0 && BusinessInfo[company][cVehicle][2] != 0.0);

}



Dialog:CarPrice(playerid, response, listitem, inputtext[])

{

    new

        company = PlayerInfo[playerid][pCompany];



    if (!IsValidCompanyID(company))

    {

        return 0;

    }

    if (response)

    {

        new amount, modelid = PlayerInfo[playerid][pSelected];



        if (sscanf(inputtext, "i", amount))

        {

            return Dialog_Show(playerid, CarPrice, DIALOG_STYLE_INPUT, "{FFFFFF}Vehicle price", "Please input the price to set for '%s' below.", "Submit", "Cancel", GetVehicleModelName(modelid));

        }

        else if (amount < 1)

        {

            return Dialog_Show(playerid, CarPrice, DIALOG_STYLE_INPUT, "{FFFFFF}Vehicle price", "The price must be above $0.\n\nPlease input the price to set for '%s' below.", "Submit", "Cancel", GetVehicleModelName(modelid));

        }

        else

        {

            new

                id = AddVehicleToDealership(company, modelid, amount);



            if (id == -1)

            {

                return SCM(playerid, COLOR_SYNTAX, "There are no available dealership car slots.");

            }

            else

            {

                SendInfoMessage(playerid, "You have added a %s to company %i.", GetVehicleModelName(modelid), company);

                ShowDealershipEditMenu(playerid, company);

            }

        }

    }

    return 1;

}



Dialog:DealerAdd(playerid, response, listitem, inputtext[])

{

    new

        company = PlayerInfo[playerid][pCompany];



    if (!IsValidCompanyID(company))

    {

        return 0;

    }

    if (response)

    {

        new model[32], modelid;



        if (sscanf(inputtext, "s[32]", model))

        {

            return Dialog_Show(playerid, DealerAdd, DIALOG_STYLE_INPUT, "{FFFFFF}Add Vehicle", "Please enter the model ID or name of the vehicle to add:", "Submit", "Back");

        }

        else if (!(modelid = GetVehicleModelFromName(model)))

        {

            return SCM(playerid, COLOR_SYNTAX, "The specified model doesn't exist.");

        }

        else if (IsVehicleInDealership(company, modelid))

        {

            return SCM(playerid, COLOR_SYNTAX, "This vehicle is already sold at this dealership.");

        }

        else

        {

            PlayerInfo[playerid][pSelected] = modelid;

            Dialog_Show(playerid, CarPrice, DIALOG_STYLE_INPUT, "{FFFFFF}Vehicle price", "Please input the price to set for '%s' below.", "Submit", "Cancel", GetVehicleModelName(modelid));

        }

    }

    return 1;

}



GetNextDealershipCarID()

{

    for (new i = 0; i < MAX_DEALERSHIP_CARS; i ++)

    {

        if (!DealershipCars[i][dcExists])

        {

            return i;

        }

    }

    return -1;

}



ShowDealershipEditMenu(playerid, company)

{

	static

	    string[3072];



	if (BusinessInfo[company][bType] != BUSINESS_DEALERSHIP2)

	{

	    return 0;

	}

	else

	{

	    new

	        index = 0;



	    string = "Add Vehicle";



	    for (new i = 0; i < MAX_DEALERSHIP_CARS; i ++)

    	{

	        if (DealershipCars[i][dcExists] && DealershipCars[i][dcCompany] == BusinessInfo[company][bID])

	        {

    	        format(string, sizeof(string), "%s\n%s (price: %s)", string, GetVehicleModelName(DealershipCars[i][dcModel]), FormatNumber(DealershipCars[i][dcPrice]));

				gListedItems[playerid][index++] = i;

	    	}

	    }

	    PlayerInfo[playerid][pCompany] = company;

    	Dialog_Show(playerid, DealerList, DIALOG_STYLE_LIST, "{FFFFFF}Dealership cars", string, "Select", "Back");

	}

	return 1;

}



Dialog:DealerList(playerid, response, listitem, inputtext[])

{

    new

		company = PlayerInfo[playerid][pCompany];



	if (!IsValidCompanyID(company))

	{

        return 0;

	}

	if (response)

	{

	    if (listitem == 0)

	    {

	        if (!IsVehicleSpawnSetup(company))

			{

		    	return SCM(playerid, COLOR_SYNTAX, "The vehicle spawn point is not setup.");

			}

			else

			{

                Dialog_Show(playerid, DealerAdd, DIALOG_STYLE_INPUT, "{FFFFFF}Add Vehicle", "Please enter the model ID or name of the vehicle to add:", "Submit", "Back");

			}

	  	}

		else

		{

		    PlayerInfo[playerid][pSelected] = gListedItems[playerid][--listitem];

		    Dialog_Show(playerid, DealerEdit, DIALOG_STYLE_LIST, "{FFFFFF}Edit vehicle", "Price: %s\nDelete Vehicle", "Select", "Back", FormatNumber(DealershipCars[PlayerInfo[playerid][pSelected]][dcPrice]));

		}

	}

	return 1;

}



Dialog:DealerEdit(playerid, response, listitem, inputtext[])

{

    new

		company = PlayerInfo[playerid][pCompany];



	if (!IsValidCompanyID(company))

	{

        return 0;

	}

	if (response)

	{

	    switch (listitem)

	    {

	        case 0:

	        {

	            Dialog_Show(playerid, DealerPrice, DIALOG_STYLE_INPUT, "{FFFFFF}Vehicle price", "The current price for this vehicle is %s.\n\nPlease input the new price for this vehicle below.", "Submit", "Cancel", FormatNumber(DealershipCars[PlayerInfo[playerid][pSelected]][dcPrice]));

	        }

	        case 1:

	        {

	            new

	                vehicle = PlayerInfo[playerid][pSelected];



				format(queryBuffer, sizeof(queryBuffer), "DELETE FROM dynamic_dealership WHERE ID = %i", DealershipCars[vehicle][dcID]);

				mysql_tquery(connectionID, queryBuffer);



                DealershipCars[vehicle][dcExists] = 0;

                SendInfoMessage(playerid, "You have deleted a vehicle: %s.", GetVehicleModelName(DealershipCars[vehicle][dcModel]));



				ShowDealershipEditMenu(playerid, company);

    		}

	    }

	}

	else

	{

	    ShowDealershipEditMenu(playerid, company);

	}

	return 1;

}



Dialog:DealerPrice(playerid, response, listitem, inputtext[])

{

    new

		company = PlayerInfo[playerid][pCompany];



	if (!IsValidCompanyID(company))

	{

        return 0;

	}

	if (response)

	{

	    new vehicle = PlayerInfo[playerid][pSelected], amount;



	    if (sscanf(inputtext, "i", amount))

		{

		    return Dialog_Show(playerid, DealerPrice, DIALOG_STYLE_INPUT, "{FFFFFF}Vehicle price", "The current price for this vehicle is %s.\n\nPlease input the new price for this vehicle below.", "Submit", "Cancel", FormatNumber(DealershipCars[vehicle][dcPrice]));

		}

		else if (amount < 0)

		{

		    return Dialog_Show(playerid, DealerPrice, DIALOG_STYLE_INPUT, "{FFFFFF}Vehicle price", "The current price for this vehicle is %s.\n\nPlease input the new price for this vehicle below.", "Submit", "Cancel", FormatNumber(DealershipCars[vehicle][dcPrice]));

		}

		else

		{

		    DealershipCars[vehicle][dcPrice] = amount;

			SaveDealershipCar(vehicle);



			SendInfoMessage(playerid, "You have set the price to %s for vehicle: %s.", FormatNumber(amount), GetVehicleModelName(DealershipCars[vehicle][dcModel]));

			ShowDealershipEditMenu(playerid, company);

		}

	}

	return 1;

}



ClearProducts(company)

{

    switch (BusinessInfo[company][bType])

    {

        case BUSINESS_DEALERSHIP2:

        {

            for (new i = 0; i < MAX_DEALERSHIP_CARS; i ++)

            {

                if (DealershipCars[i][dcExists] && DealershipCars[i][dcCompany] == BusinessInfo[company][bID])

                {

                    DealershipCars[i][dcExists] = 0;

                }

            }

            format(queryBuffer, sizeof(queryBuffer), "DELETE FROM dynamic_dealership WHERE Company = %i", BusinessInfo[company][bID]);

            mysql_tquery(connectionID, queryBuffer);

        }

    }

}



SaveDealershipCar(id)

{

	static

	    queryString[128];



	if (!DealershipCars[id][dcExists]) return 0;



	format(queryString, sizeof(queryString), "UPDATE dynamic_dealership SET Model = %i, Price = %i WHERE ID = %i", DealershipCars[id][dcModel], DealershipCars[id][dcPrice], DealershipCars[id][dcID]);

	return mysql_tquery(connectionID, queryString);

}



IsValidCompanyID(id)

{

    return (id >= 0 && id < MAX_BUSINESSES) && BusinessInfo[id][bExists];

}



IsVehicleInDealership(company, model)

{

    if (!IsValidCompanyID(company) || BusinessInfo[company][bType] != BUSINESS_DEALERSHIP2)

    {

        return 0;

    }

    for (new i = 0; i < MAX_DEALERSHIP_CARS; i ++)

    {

        if (DealershipCars[i][dcExists] && DealershipCars[i][dcCompany] == BusinessInfo[company][bID] && DealershipCars[i][dcModel] == model)

        {

            return 1;

        }

    }

    return 0;

}



AddVehicleToDealership(company, model, price)

{

	if (!IsValidCompanyID(company) || BusinessInfo[company][bType] != BUSINESS_DEALERSHIP2)

	{

	    return -1;

	}



 	new

	 	id = GetNextDealershipCarID();



	if (id != -1)

	{

 		DealershipCars[id][dcExists] = 1;

  		DealershipCars[id][dcCompany] = BusinessInfo[company][bID];

    	DealershipCars[id][dcModel] = model;

	   	DealershipCars[id][dcPrice] = price;



		format(queryBuffer, sizeof(queryBuffer), "INSERT INTO dynamic_dealership (Company) VALUES(%i)", DealershipCars[id][dcCompany]);

		mysql_tquery(connectionID, queryBuffer, "OnDealershipCarAdded", "i", id);

	}

	return id;

}



forward OnDealershipCarAdded(id);

public OnDealershipCarAdded(id)

{

	DealershipCars[id][dcID] = cache_insert_id(connectionID);



	SaveDealershipCar(id);

}



forward OnLoadDealershipCars();

public OnLoadDealershipCars()

{

    new

        rows = cache_get_row_count(connectionID);



    for (new i = 0; i < rows; i ++)

    {

        DealershipCars[i][dcExists] = 1;

        DealershipCars[i][dcID] = cache_get_field_content_int(i, "ID");

        DealershipCars[i][dcCompany] = cache_get_field_content_int(i, "Company");

        DealershipCars[i][dcModel] = cache_get_field_content_int(i, "Model");

        DealershipCars[i][dcPrice] = cache_get_field_content_int(i, "Price");

    }

}



forward OnPlayerAttemptBuyVehicle(playerid, index);

public OnPlayerAttemptBuyVehicle(playerid, index)

{

    new count = cache_get_row_int(0, 0);

    new itemid = PlayerInfo[playerid][pChooseCar];



    //new string[250];

    //strunpack(string, GetVehicleModelName(DealershipCars[itemid][dcModel]));

    if(count >= GetPlayerAssetLimit(playerid, LIMIT_VEHICLES))

    {

        SM(playerid, COLOR_GREY, "You currently own %i/%i vehicles. You can't own anymore unless you upgrade your asset perk.", count, GetPlayerAssetLimit(playerid, LIMIT_VEHICLES));

    }

    else

    {

        new string[20], businessid = GetInsideBusiness(playerid);

        if(PlayerInfo[playerid][pCash] < DealershipCars[itemid][dcPrice])

        {

            SendClientMessage(playerid, COLOR_GREY, "You can't afford to purchase this vehicle.");

        }

        else if(GetSpawnedVehicles(playerid) >= MAX_SPAWNED_VEHICLES)

        {

            SM(playerid, COLOR_GREY, "You can't have more than %i vehicles spawned at a time.", MAX_SPAWNED_VEHICLES);

        }

        else

        {

            //format(string, 32, "%c%c%c %i", Random('A', 'Z'), Random('A', 'Z'), Random('A', 'Z'), Random(100, 999));

            mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "INSERT INTO vehicles (ownerid, owner, modelid, price, plate, pos_x, pos_y, pos_z, pos_a, color1, color2, paintjob) VALUES(%i, '%s', %i, %i, '%s', '%f', '%f', '%f', '%f', 0, 0, -1)", PlayerInfo[playerid][pID], GetPlayerNameEx(playerid), DealershipCars[itemid][dcModel], DealershipCars[itemid][dcPrice], mysql_escaped(string), BusinessInfo[PlayerInfo[playerid][pDealershipMenu]][cVehicle][0], BusinessInfo[PlayerInfo[playerid][pDealershipMenu]][cVehicle][1], BusinessInfo[PlayerInfo[playerid][pDealershipMenu]][cVehicle][2], BusinessInfo[PlayerInfo[playerid][pDealershipMenu]][cVehicle][3]);

            mysql_tquery(connectionID, queryBuffer);

            printf(queryBuffer);

            

            BusinessInfo[businessid][bCash] += DealershipCars[itemid][dcPrice];

            

            mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE businesses SET cash = %i WHERE id = %i", BusinessInfo[businessid][bCash], BusinessInfo[businessid][bID]);

	       	mysql_tquery(connectionID, queryBuffer);



            GivePlayerCash(playerid, -DealershipCars[itemid][dcPrice]);

            format(string, sizeof(string), "~r~-$%i", DealershipCars[itemid][dcPrice]);

            GameTextForPlayer(playerid, string, 5000, 1);

            SM(playerid, COLOR_GREY, "[Dealer Ship]:"WHITE" %s purchased for $%i. [/v spawn] to spawn this vehicle.", GetVehicleModelName(DealershipCars[itemid][dcModel]), DealershipCars[itemid][dcPrice]);

            Log_Write("log_property", "%s (uid: %i) purchased a %s for $%i.", GetPlayerNameEx(playerid), PlayerInfo[playerid][pID], GetVehicleModelName(DealershipCars[itemid][dcModel]), DealershipCars[itemid][dcPrice]);



        }

    }

}



// Version 2 (Simplified)

ShowDealershipMenu(playerid, company)

{

    if (!IsPlayerConnected(playerid),  PlayerInfo[playerid][pInjured],  !PlayerInfo[playerid][pID])

        return 0;



    if(IsValidCompanyID(company) && BusinessInfo[company][bType] == BUSINESS_DEALERSHIP2)

    {

        new

            name[128],

            str[(1024 * 2)];



        PlayerInfo[playerid][pDealershipMenu] = company;

        for (new i = 0, j; i < MAX_DEALERSHIP_CARS; i ++)

        {

            //if (DealershipCars[i][dcExists])

            if (DealershipCars[i][dcCompany] == BusinessInfo[company][bID] && DealershipCars[i][dcModel] > 0)

            {

                strunpack(name, GetVehicleModelName(DealershipCars[i][dcModel]));

                g_ListedItems[playerid][j] = i;

                format(str, sizeof str, "%s%i\t%s ~g~($%i)\n", str, DealershipCars[i][dcModel], name, DealershipCars[i][dcPrice]);

                j++;

            }

        }

        ShowPlayerDialog(playerid, DIALOG_DEALERSHIPMENU, DIALOG_STYLE_PREVIEW_MODEL, "Car Dealership", str, "Select", "Cancel");

    }

    return 1;

}



CMD:createdealership(playerid, params[])

{

	new type = 9, Float:x, Float:y, Float:z, Float:a, description[64];



    if(PlayerInfo[playerid][pAdmin] < 7)

    {

	    return SCM(playerid, COLOR_SYNTAX, "You don't have permission to use this command.");

	}



	GetPlayerPos(playerid, x, y, z);

	GetPlayerFacingAngle(playerid, a);



    type--;

 	for(new i = 0; i < MAX_BUSINESSES; i ++)

	{

	    if(!BusinessInfo[i][bExists])

	    {

			mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "INSERT INTO businesses (type, biz_desc, price, pos_x, pos_y, pos_z, pos_a, int_x, int_y, int_z, int_a, interior, outsideint, outsidevw) VALUES(%i, '%e', %i, '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', %i, %i, %i)", type, description, bizInteriors[type][intPrice], x, y, z, a - 180.0,

				bizInteriors[type][intX], bizInteriors[type][intY], bizInteriors[type][intZ], bizInteriors[type][intA], bizInteriors[type][intID], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));

			mysql_tquery(connectionID, queryBuffer, "OnAdminCreateBusiness", "iiiffffs", playerid, i, type, x, y, z, a, description);

			return 1;

		}

	}

	SCM(playerid, COLOR_SYNTAX, "Business slots are currently full. Ask developers to increase the internal limit.");

	return 1;

}



CMD:editdealership(playerid, params[])

{

	new businessid, option[14], param[32];



	if(PlayerInfo[playerid][pAdmin] < 7)

    {

	    return SCM(playerid, COLOR_SYNTAX, "You don't have permission to use this command.");

	}

	if(sscanf(params, "is[14]S()[32]", businessid, option, param))

	{

	    SCM(playerid, COLOR_LIGHTBLUE, "Usage:  "WHITE"/editdealership [businessid] [option]");

	    SCM(playerid, COLOR_ORANGE, "Options: "WHITE"Position, Spawn, Vehicles, Price");

	    return 1;

	}

	if(!(0 <= businessid < MAX_BUSINESSES) || !BusinessInfo[businessid][bExists])

	{

	    return SCM(playerid, COLOR_SYNTAX, "Invalid Dealership.");

	}

    if (BusinessInfo[businessid][bType] != BUSINESS_DEALERSHIP2)

    {

        return SCM(playerid, COLOR_SYNTAX, "You can only edit dealerships business.");

    }

	if(!strcmp(option, "position", true))

	{

	    GetPlayerPos(playerid, BusinessInfo[businessid][bPosX], BusinessInfo[businessid][bPosY], BusinessInfo[businessid][bPosZ]);

	    GetPlayerFacingAngle(playerid, BusinessInfo[businessid][bPosA]);



	    BusinessInfo[businessid][bOutsideInt] = GetPlayerInterior(playerid);

	    BusinessInfo[businessid][bOutsideVW] = GetPlayerVirtualWorld(playerid);



	    mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE businesses SET pos_x = '%f', pos_y = '%f', pos_z = '%f', pos_a = '%f', outsideint = %i, outsidevw = %i WHERE id = %i", BusinessInfo[businessid][bPosX], BusinessInfo[businessid][bPosY], BusinessInfo[businessid][bPosZ], BusinessInfo[businessid][bPosA], BusinessInfo[businessid][bOutsideInt], BusinessInfo[businessid][bOutsideVW], BusinessInfo[businessid][bID]);

	    mysql_tquery(connectionID, queryBuffer);



	    ReloadBusiness(businessid);

	    SM(playerid, COLOR_AQUA, "** You've changed the entrance of business %i.", businessid);

	}

    else if(!strcmp(option, "spawn", true))

    {

        GetPlayerPos(playerid, BusinessInfo[businessid][cVehicle][0], BusinessInfo[businessid][cVehicle][1], BusinessInfo[businessid][cVehicle][2]);

        GetPlayerFacingAngle(playerid, BusinessInfo[businessid][cVehicle][3]);

        format(queryBuffer, sizeof(queryBuffer), "UPDATE `businesses` SET `cVehicleX` = %.4f, `cVehicleY` = %.4f, `cVehicleZ` = %.4f, `cVehicleA` = %.4f WHERE id = %i",

        BusinessInfo[businessid][cVehicle][0],BusinessInfo[businessid][cVehicle][1],BusinessInfo[businessid][cVehicle][2],BusinessInfo[businessid][cVehicle][3], BusinessInfo[businessid][bID]);

        mysql_tquery(connectionID, queryBuffer);

        SendAdminMessage(COLOR_LIGHTRED, "Admin: %s has edited the vehicle spawn of business %i.", GetPlayerNameEx(playerid), businessid);

    }

    else if(!strcmp(option, "vehicles", true))

    {

        ShowDealershipEditMenu(playerid, businessid);

    }

	else if(!strcmp(option, "price", true))

	{

	    new price;



	    if(sscanf(param, "i", price))

	    {

	        return SCM(playerid, COLOR_LIGHTRED, "Usage:  "WHITE"/editdealership [businessid] [price] [value]");

		}

		if(price < 0)

		{

		    return SCM(playerid, COLOR_SYNTAX, "The price can't be below $0.");

		}



		BusinessInfo[businessid][bPrice] = price;



		mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "UPDATE businesses SET price = %i WHERE id = %i", BusinessInfo[businessid][bPrice], BusinessInfo[businessid][bID]);

	    mysql_tquery(connectionID, queryBuffer);



		ReloadBusiness(businessid);

	    SM(playerid, COLOR_AQUA, "** You've changed the price of business %i to $%i.", businessid, price);

	}

    return 1;

}



CMD:removedealership(playerid, params[])

{

	new businessid;



	if(PlayerInfo[playerid][pAdmin] < 7)

    {

	    return SCM(playerid, COLOR_SYNTAX, "You don't have permission to use this command.");

	}

	if(sscanf(params, "i", businessid))

	{

	    return SCM(playerid, COLOR_LIGHTBLUE, "Usage:  "WHITE"/removedealership [businessid]");

	}

	if(!(0 <= businessid < MAX_HOUSES) || !BusinessInfo[businessid][bExists])

	{

	    return SCM(playerid, COLOR_SYNTAX, "Invalid dealership.");

	}

    if (BusinessInfo[businessid][bType] != BUSINESS_DEALERSHIP2)

    {

        return SCM(playerid, COLOR_SYNTAX, "You can only remove dealerships.");

    }



    ClearProducts(businessid);

	DestroyDynamic3DTextLabel(BusinessInfo[businessid][bText]);

	DestroyDynamicPickup(BusinessInfo[businessid][bPickup]);

	DestroyDynamicMapIcon(BusinessInfo[businessid][bMapIcon]);





	mysql_format(connectionID, queryBuffer, sizeof(queryBuffer), "DELETE FROM businesses WHERE id = %i", BusinessInfo[businessid][bID]);

	mysql_tquery(connectionID, queryBuffer);





	BusinessInfo[businessid][bExists] = 0;

	BusinessInfo[businessid][bID] = 0;

	BusinessInfo[businessid][bOwnerID] = 0;



	SM(playerid, COLOR_LIME, "[Business System]: "WHITE"You have removed business ID: %i.", businessid);

	return 1;

}



CMD:buyvehicle(playerid, params[])

{

	new businessid = GetInsideBusiness(playerid);



	if(businessid == -1)

	{

	    return SCM(playerid, COLOR_SYNTAX, "You're not at any car dealership!");

	}

	if(BusinessInfo[businessid][bProducts] <= 0)

 	{

	 	return SCM(playerid, COLOR_GREY, "[Car Dealership]:"WHITE" This dealership is out of stock.");

   	}

	switch(BusinessInfo[businessid][bType])

	{

        case BUSINESS_DEALERSHIP2:

        {

            if(IsBusinessOwner(playerid, businessid)) return SendClientMessage(playerid, COLOR_GREY, "You can't buy a vehicle on your own business.");

            if(BusinessInfo[businessid][bProducts] <= 0)

            {

                return SCM(playerid, COLOR_SYNTAX, "This business is out of stock.");

            }

            //ShowDealershipPreviewMenu(playerid, businessid);

			ShowDealershipMenu(playerid, businessid);

        }

	}

	return 1;

}

