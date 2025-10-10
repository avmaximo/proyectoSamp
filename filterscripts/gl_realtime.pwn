#include <a_samp>
#pragma tabsize 0

new Text:txtTimeDisp;
new Text:txtDateDisp;
new hour, minute, second;
new timestr[16], datestr[32];

forward UpdateTimeAndWeather();

public OnGameModeInit()
{
    // === Texto de FECHA (posición original de la hora) ===
    txtDateDisp = TextDrawCreate(605.0, 25.0, "00/00/0000");
    TextDrawUseBox(txtDateDisp, 0);
    TextDrawFont(txtDateDisp, 3);
    TextDrawSetShadow(txtDateDisp, 0);
    TextDrawSetOutline(txtDateDisp, 2);
    TextDrawBackgroundColor(txtDateDisp, 0x000000FF);
    TextDrawColor(txtDateDisp, 0xFFFFFFFF);
    TextDrawAlignment(txtDateDisp, 3);
    TextDrawLetterSize(txtDateDisp, 0.4, 1.2);

    // === Texto de HORA (movido un poco más abajo) ===
    txtTimeDisp = TextDrawCreate(605.0, 45.0, "00:00");
    TextDrawUseBox(txtTimeDisp, 0);
    TextDrawFont(txtTimeDisp, 3);
    TextDrawSetShadow(txtTimeDisp, 0);
    TextDrawSetOutline(txtTimeDisp, 2);
    TextDrawBackgroundColor(txtTimeDisp, 0x000000FF);
    TextDrawColor(txtTimeDisp, 0xFFFFFFFF);
    TextDrawAlignment(txtTimeDisp, 3);
    TextDrawLetterSize(txtTimeDisp, 0.5, 1.5);

    UpdateTimeAndWeather();
    SetTimer("UpdateTimeAndWeather", 60000, true); // Actualiza cada minuto

    return 1;
}

public UpdateTimeAndWeather()
{
    gettime(hour, minute, second);

    // Formatear hora
    format(timestr, sizeof(timestr), "%02d:%02d", hour, minute);
    TextDrawSetString(txtTimeDisp, timestr);
    SetWorldTime(hour);

    // Formatear fecha
    new year, month, day;
    getdate(year, month, day);
    format(datestr, sizeof(datestr), "%02d/%02d/%04d", day, month, year);
    TextDrawSetString(txtDateDisp, datestr);

    // Aplicar hora a todos los jugadores conectados
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i))
        {
            SetPlayerTime(i, hour, minute);
        }
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    gettime(hour, minute, second);
    getdate(_, _, _);

    SetPlayerTime(playerid, hour, minute);

    TextDrawShowForPlayer(playerid, txtDateDisp);
    TextDrawShowForPlayer(playerid, txtTimeDisp);

    return 1;
}

public OnPlayerSpawn(playerid)
{
    TextDrawShowForPlayer(playerid, txtDateDisp);
    TextDrawShowForPlayer(playerid, txtTimeDisp);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    TextDrawHideForPlayer(playerid, txtDateDisp);
    TextDrawHideForPlayer(playerid, txtTimeDisp);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    TextDrawHideForPlayer(playerid, txtDateDisp);
    TextDrawHideForPlayer(playerid, txtTimeDisp);
    return 1;
}
