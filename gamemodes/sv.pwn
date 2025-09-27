#include <a_samp>
#include <a_mysql>

// Colores básicos
#define COLOR_WHITE        "{FFFFFF}"
#define COLOR_BLACK        "{000000}"
#define COLOR_RED          "{FF0000}"
#define COLOR_GREEN        "{00FF00}"
#define COLOR_BLUE         "{0000FF}"
#define COLOR_YELLOW       "{FFFF00}"
#define COLOR_CYAN         "{00FFFF}"
#define COLOR_MAGENTA      "{FF00FF}"
#define COLOR_ORANGE       "{FFA500}"
#define COLOR_GRAY         "{808080}"
#define COLOR_SILVER       "{C0C0C0}"

// Colores extra comunes
#define COLOR_PINK         "{FFC0CB}"
#define COLOR_VIOLET       "{8A2BE2}"
#define COLOR_BROWN        "{8B4513}"
#define COLOR_GOLD         "{FFD700}"
#define COLOR_DARKGREEN    "{006400}"
#define COLOR_DARKRED      "{8B0000}"
#define COLOR_DARKBLUE     "{00008B}"
#define COLOR_LIGHTBLUE    "{ADD8E6}"
#define COLOR_LIGHTGREEN   "{90EE90}"

// Roles
#define COLOR_ADMIN        "{FF6347}" // rojo tomate
#define COLOR_MOD          "{1E90FF}" // azul dodger
#define COLOR_VIP          "{DAA520}" // goldenrod
#define COLOR_PLAYER       "{87CEEB}" // sky blue
#define COLOR_SYSTEM       "{B22222}" // firebrick
#define COLOR_WARNING      "{FFD700}" // dorado fuerte
#define COLOR_SUCCESS      "{32CD32}" // lime green
#define COLOR_ERROR        "{DC143C}" // crimson

// Contrastes
#define COLOR_DARKGRAY     "{A9A9A9}"
#define COLOR_LIGHTGRAY    "{D3D3D3}"
#define COLOR_NAVY         "{191970}"
#define COLOR_TEAL         "{008080}"
#define COLOR_MAROON       "{800000}"


new MySQL:database;
#define DB_HOST     "localhost"
#define DB_USER     "root"
#define DB_PASS     ""
#define DB_DATABASE     "sv-samp"
#define DB_PORT     3306

#define NAME_SERVER     "Ciudad Libertad Roleplay"

#define PASSWORD_MAX_CHARACTERS    (78)

/*======================================= DEFINE DIALOGOS ================================== */
#define id_dialogos             100

#define DIALOG_REGISTER_1      (id_dialogos+1)
#define DIALOG_REGISTER_2      (id_dialogos+2)

enum uData {
    uName[MAX_PLAYER_NAME],
    uPassword[PASSWORD_MAX_CHARACTERS],
    uMail[40],
    uIp[17],
    uRegisterDate[9],
    uLastLogin[9],
    aLevel
};

enum pData {
    pName[25],
    pLastname[25],
    pSkin,
    pMoney,
    pLevel,
    pExp,
    pJob[2], // 0 y 1
    Float:pPosX,Float:pPosY,Float:pPosZ,Float:pRot
};

new playerInfo[MAX_PLAYERS][pData], userInfo[MAX_PLAYERS][uData];

main(){
    DatabaseConnect();
}
public OnGameModeInit(){
    return 1;
}
public OnPlayerConnect(playerid){
    GetPlayerName(playerid, userInfo[playerid][uName], MAX_PLAYER_NAME);
    new DB_Query[256],Cache:ResultCache_;
    format(DB_Query, sizeof(DB_Query), "SELECT * FROM users WHERE username='%s' LIMIT 1", userInfo[playerid][uName]);
    ResultCache_ = mysql_query(database, DB_Query);
    if(cache_num_rows()){//-------------------------------------------------------------El usuario existe
        SendClientMessage(playerid, -1, "El usuario existe");






    }else{ //---------------------------------------------------------------------------El usuario no existe
        new str_title[144], str_infobox[144];
        format(str_title, sizeof(str_title), ""#COLOR_WHITE"Bienvenida");
        format(str_infobox, sizeof(str_infobox), ""COLOR_GOLD"%s "#COLOR_WHITE"te da la bienvenida", NAME_SERVER);
        ShowPlayerDialog(playerid, DIALOG_REGISTER_1, DIALOG_STYLE_MSGBOX, str_title, str_infobox, "Continuar", "");






    }
    cache_delete(ResultCache_);
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    format(userInfo[playerid][uName], MAX_PLAYER_NAME, "");
    return 1;
}

//=======================================> FUNCTIONS
forward DatabaseConnect();
public DatabaseConnect(){
    database = mysql_connect(DB_HOST, DB_USER, DB_PASS, DB_DATABASE);

    if(database == MYSQL_INVALID_HANDLE || mysql_errno(database) != 0){ // Conexión fallidaa la base de datos
        print("\n\n[MySQL]: Error al establecer conexión con la base de datos.\n\n");
        SetTimer("CerrarServidor", 10000, false);
    }
    else{ // Conexión establecida correctamente
        print("\n\n[MySQL]: Conexión con la base de datos MySQL concretada con éxito.\n[MySQL]: ON\n\n");
        return 1;
    }
    return 0;
}
forward CerrarServidor();
public CerrarServidor(){
    SendRconCommand("exit");
    return 1;
}
