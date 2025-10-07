/**************************************************************************/
//                        Yaa NPC System
/*************************************************************************/
/**************************************************************************/
//                        Version 1.0 | Build 1
/*************************************************************************/
/**
 * Copyright (c) 2015-2016 San Andreas Playground
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.
 * If not, see <http://www.gnu.org/licenses/>.
 */

 /*AUTHOR ********************
  @Yaa - SA-MP Lead Scripter
 ***************************/


#include <a_samp>

#pragma tabsize 0

#define COLOR_GREEN 0x33AA33AA
#define COLOR_RED 0xE01B4CFF

new Busdama[3];
new BusPick;

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(IsPlayerAdmin(playerid))
	{
  		SetPlayerPos(playerid, fX, fY, fZ);
	}
    return 1;
}
public OnFilterScriptInit()
{
	ConnectNPC("[SAP]Bus[65]", "Gunthers");
    ConnectNPC("[SAP]Bus[52]", "Guntherss");
    ConnectNPC("[SAP]Bus[07]", "SAP07");
    ConnectNPC("[SAP]Bus[30]", "SAP30");
    ConnectNPC("[SAP]Bus[40]", "SAP40");
    ConnectNPC("[SAP]Bus[57]", "SAP57");
    ConnectNPC("[SAP]Bus[18]", "SAP18");

    BusPick = CreatePickup(19130, 2, 2030.3916,1520.7435,10.8203, -1);
    Busdama[0] = CreateVehicle(437,-2037.8804000,139.2291000,29.2285000,270.9555000,-1,-1,15);
    new Text3D:label = Create3DTextLabel("(SF) Pirates Ship <-> (LV) Area 69 \n --------\n 78 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
    Attach3DTextLabelToVehicle( Text3D:label, Busdama[0], 0.0, 0.0, 2.0);

    Busdama[2] = CreateVehicle(437,-2032.6281000,174.0752000,29.2325000,294.2687000,-1,-1,15); 
    new Text3D:label2 = Create3DTextLabel("(LV) SF Chinatown <-> (LV) Emerald Isle\n --------\n 32 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
    Attach3DTextLabelToVehicle( Text3D:label2, Busdama[2], 0.0, 0.0, 2.0);

    Busdama[2] = CreateVehicle(437,-2032.6281000,174.0752000,29.2325000,294.2687000,-1,-1,15); 
    new Text3D:label3 = Create3DTextLabel("(LV) SF Chinatown <-> (LV) Emerald Isle\n --------\n 32 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
    Attach3DTextLabelToVehicle( Text3D:label3, Busdama[2], 0.0, 0.0, 2.0);

	return 1;
}
public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"SAP : test script",5000,5);
	return 1;
}

public OnPlayerSpawn(playerid)
{
   NPCTest(playerid);
   return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if(pickupid == BusPick)
    {
        SendClientMessage(playerid, COLOR_GREEN, "____________________________| Bus's Actives |_____________________________");
        SendClientMessage(playerid, -1, " ");
        SendClientMessage(playerid, COLOR_RED, "Number : 32 | SF Chinatown <-> LV Emerald Isle               | Damaged");
        SendClientMessage(playerid, COLOR_RED, "Number : 04 | SF Industrial Area <-> LS Grouve Street        | Damaged");
        SendClientMessage(playerid, COLOR_RED, "Number : 78 | SF Pirates Ship <-> LV Area 69                 | Damaged");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 57 | SF Train Station <-> (SF-LV) The Small Village | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 18 | SF Police Office <-> (LS Beach) Vachet Harbor  | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 40 | Las Venturas <-> Las Barrancas                 | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 65 | LV Pirates Ship <-> SF Pirates Ship            | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 52 | LV Emerald Isle <-> LS Grouve Street           | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 30 | LV Police Departemment <-> Mount Chilliad      | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "Number : 07 | LV Ammo Nation <-> LV Area 69                  | Active ");
        SendClientMessage(playerid, COLOR_GREEN, "__________________________________________________________________________");
        return 0;
    }
    return 1;
}

stock NPCTest(playerid)
{
    if(IsPlayerNPC(playerid))
	{
        new npcname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, npcname, sizeof(npcname)); //Getting the NPC's name.
        if(!strcmp(npcname, "[SAP]Bus[65]", true))
        {
            new Text3D:label = Create3DTextLabel("(LV) Pirates Ship <-> (SF) Pirates Ship\n --------\n 65 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Near LV Airport
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
        if(!strcmp(npcname, "[SAP]Bus[52]", true))
        {
            new Text3D:label = Create3DTextLabel("(LV) Emerald Isle <-> (LS) Grouve Street\n --------\n 52 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
	    if(!strcmp(npcname, "[SAP]Bus[07]", true))
        {
            new Text3D:label = Create3DTextLabel("(LV) Ammo Nation <-> (LV - SF) Area 69\n --------\n 07 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
	    if(!strcmp(npcname, "[SAP]Bus[30]", true))
        {
            new Text3D:label = Create3DTextLabel("(LV) Police Departemment <-> (LS - SF) Mount Chilliad\n --------\n 30 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
	    if(!strcmp(npcname, "[SAP]Bus[40]", true))
        {
            new Text3D:label = Create3DTextLabel("(T-LV) Las Venturas <-> (LV - SF) Las Barrancas\n --------\n 40 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
	    if(!strcmp(npcname, "[SAP]Bus[18]", true))
        {
            new Text3D:label = Create3DTextLabel("(SF) Police Office <-> (LS Beach) Vachet Harbor\n --------\n 18 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
	    if(!strcmp(npcname, "[SAP]Bus[57]", true))
        {
            new Text3D:label = Create3DTextLabel("(SF) Train Station <-> (SF-LV) The Small Village\n --------\n 57 \n--------", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); // Red Country
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            new NPCar;
            new Float:X,Float:Y,Float:Z,Float:Angle;
            GetPlayerPos(playerid,X,Y,Z);
            GetPlayerFacingAngle(playerid,Angle);
            NPCar = CreateVehicle(437,X,Y,Z,Angle,0,0,0);
            PutPlayerInVehicle(playerid,NPCar,0);
	    }
	    if(!strcmp(npcname, "[LV]Ship[01]", true))
        {
            new Text3D:label = Create3DTextLabel("San Andreas Playground LV Pirates Ship\n Please Fighting / slaping / abuse\n are not allowed in the ship", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0);
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            SetPlayerSkin(playerid, 217);
            GivePlayerWeapon(playerid, 38, 19000);
	    }
	    if(!strcmp(npcname, "[LV]Ship[02]", true))
        {
            new Text3D:label = Create3DTextLabel("San Andreas Playground LV Pirates Ship\n Please CARS / PLANES / BIKES / Bombs\n are not allowed in the ship", 0x008080FF, 30.0, 40.0, 50.0, 40.0, 0); 
            Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.7);
            SetPlayerSkin(playerid, 217);
            GivePlayerWeapon(playerid, 38, 19000);
	    }
    }
}

