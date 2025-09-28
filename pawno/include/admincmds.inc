// ========================================
// ========== Comandos administrativos ==========
// ========================================

CMD:morir(playerid, params[]){
	if(enLobby[playerid]==1) return 1;
    SetPlayerHealth(playerid, 0);
    SendClientMessage(playerid, -1, "Has usado /morir.");
	return 1;
}
