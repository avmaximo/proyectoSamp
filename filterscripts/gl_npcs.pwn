//-------------------------------------------------
//
//  NPC initialisation for Grand Larceny
//
//-------------------------------------------------

#pragma tabsize 0
#include <a_samp>

enum tipos {
	tren_ls,
	tren_sf,
	tren_lv
};
new npc_vehicles[tipos];

//-------------------------------------------------

public OnFilterScriptInit()
{
	ConnectNPC("TrainDriverLV","tren_lv1_lv2");
	ConnectNPC("TrainDriverLS","tren_ls_lv1");
	ConnectNPC("TrainDriverSF","tren_sf_unity");
	//ConnectNPC("PilotLV","at400_lv");
	//ConnectNPC("PilotSF","at400_sf");
	//ConnectNPC("PilotLS","at400_ls");
	// Testing
	//ConnectNPC("OnfootTest","onfoot_test");
	//ConnectNPC("DriverTest","mat_test2");
	//ConnectNPC("DriverTest2","driver_test2");

	//AddStaticVehicle(577, 1462.0745,2630.8787,10.8203, 0.0, -1, -1); // at400_sf
	//AddStaticVehicle(577, 1462.0745,2630.8787,10.8203, 0.0, -1, -1); // at400_lv
	npc_vehicles[tren_ls] = AddStaticVehicle(538, 1700.7551,-1953.6531,14.8756, 0.0, -1, -1); // tren LS
	npc_vehicles[tren_lv] = AddStaticVehicle(538, 2864.750000, 1323.227783, 12.125619, 0.0, -1, -1); // tren LV
	npc_vehicles[tren_sf] = AddStaticVehicle(538, -1944.375000, 87.377807, 27.000619, 0.0, -1, -1); // tren SF

	return 1;
}

//-------------------------------------------------
// IMPORTANT: This restricts NPCs connecting from
// an IP address outside this server. If you need
// to connect NPCs externally you will need to modify
// the code in this callback.

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) {
	    new ip_addr_npc[64+1];
	    new ip_addr_server[64+1];
	    GetServerVarAsString("bind",ip_addr_server,64);
	    GetPlayerIp(playerid,ip_addr_npc,64);
	    
		if(!strlen(ip_addr_server)) {
		    ip_addr_server = "127.0.0.1";
		}
		
		if(strcmp(ip_addr_npc,ip_addr_server,true) != 0) {
		    // this bot is remote connecting
		    printf("NPC: Got a remote NPC connecting from %s and I'm kicking it.",ip_addr_npc);
		    Kick(playerid);
		    return 0;
		}
        printf("NPC: Connection from %s is allowed.",ip_addr_npc);
	}
	
	return 1;
}


//-------------------------------------------------

public OnPlayerRequestClass(playerid, classid)
{
	if(!IsPlayerNPC(playerid)) return 0; // We only deal with NPC players in this script
	
	new playername[64];
	GetPlayerName(playerid,playername,64);

 	if(!strcmp(playername,"TrainDriverLV",true)) {
        SetSpawnInfo(playerid,69,255,2864.750000, 1323.227783, 12.125619,0.0,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"TrainDriverSF",true)) {
	    SetSpawnInfo(playerid,69,255,-1944.375000, 87.377807, 27.000619,0.0,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"TrainDriverLS",true)) {
	    SetSpawnInfo(playerid,69,255,1700.7551,-1953.6531,14.8756,0.0,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"PilotLV",true)) {
	    SetSpawnInfo(playerid,69,61,0.0,0.0,0.0,0.0,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"PilotSF",true)) {
	    SetSpawnInfo(playerid,69,61,0.0,0.0,0.0,0.0,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"PilotLS",true)) {
	    SetSpawnInfo(playerid,69,61,2084.706298,-2496.730957,13.546875,82.276901,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"OnfootTest",true)) {
	    SetSpawnInfo(playerid,69,61,2388.1003,-1279.8933,25.1291,94.3321,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"DriverTest",true)) {
	    SetSpawnInfo(playerid,69,61,2388.1003,-1279.8933,25.1291,94.3321,-1,-1,-1,-1,-1,-1);
	}
	else if(!strcmp(playername,"DriverTest2",true)) {
	    SetSpawnInfo(playerid,69,61,2388.1003,-1279.8933,25.1291,94.3321,-1,-1,-1,-1,-1,-1);
	}

	return 0;
}

//-------------------------------------------------

stock SetVehicleTireStatus(vehicleid, tirestatus)
{
    new panels, doors, lights, tires;
    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
    UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tirestatus);
}

//-------------------------------------------------

public OnPlayerSpawn(playerid)
{
	if(!IsPlayerNPC(playerid)) return 1; // We only deal with NPC players in this script

	new playername[64];
	GetPlayerName(playerid,playername,64);

	if(!strcmp(playername,"TrainDriverLV",true)) {
        PutPlayerInVehicle(playerid,npc_vehicles[tren_lv],0);
        SetPlayerColor(playerid,0xFFFFFFFF);
 	}
	else if(!strcmp(playername,"TrainDriverSF",true)) {
	    PutPlayerInVehicle(playerid,npc_vehicles[tren_sf],0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"TrainDriverLS",true)) {
	    PutPlayerInVehicle(playerid,npc_vehicles[tren_ls],0); 
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"PilotLV",true)) {
	    PutPlayerInVehicle(playerid,13,0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"PilotSF",true)) {
	    PutPlayerInVehicle(playerid,14,0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"PilotLS",true)) {
	    //PutPlayerInVehicle(playerid,npc_vehicles[avion_ls],0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"OnfootTest",true)) {
	    //PutPlayerInVehicle(playerid,876,0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"DriverTest",true)) {
	    PutPlayerInVehicle(playerid,376,0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}
	else if(!strcmp(playername,"DriverTest2",true)) {
		//SetVehicleTireStatus(876,0xFF);
	    PutPlayerInVehicle(playerid,875,0);
	    SetPlayerColor(playerid,0xFFFFFFFF);
	}

	return 1;
}

//-------------------------------------------------
// EOF


