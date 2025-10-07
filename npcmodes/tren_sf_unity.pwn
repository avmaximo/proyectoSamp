//
// A Driver NPC that goes around a path continuously
// Kye 2009
//

#include <a_npc>

#define NUM_PLAYBACK_FILES 5
new gPlaybackFileCycle=0;

//------------------------------------------

main(){}

//------------------------------------------

NextPlayback()
{
	// Reset the cycle count if we reach the max
	if(gPlaybackFileCycle==NUM_PLAYBACK_FILES) gPlaybackFileCycle = 0;

	if(gPlaybackFileCycle==0) {
	    StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"tren_sf_unity");
	}
	else if(gPlaybackFileCycle==1) {
	    StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"tren_unity_ls");
	}
	else if(gPlaybackFileCycle==2) {
	    StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"tren_ls_lv1");
	}
	else if(gPlaybackFileCycle==3) {
		StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"tren_lv1_lv2");
	}
	else if(gPlaybackFileCycle==4) {
	    StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,"tren_lv2_sf");
	}

	gPlaybackFileCycle++;
}
	

//------------------------------------------

public OnRecordingPlaybackEnd()
{
    NextPlayback();
}

//------------------------------------------

public OnNPCEnterVehicle(vehicleid, seatid)
{
    NextPlayback();
}

//------------------------------------------

public OnNPCExitVehicle()
{
    StopRecordingPlayback();
    gPlaybackFileCycle = 0;
}

//------------------------------------------
