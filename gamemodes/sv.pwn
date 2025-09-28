#include <a_samp>
#include <a_vehicles>
#include <streamer>
#include <zcmd>
#include <a_mysql>
#include <vSyncALS>
#include <vSyncYSI>

#define SSCANF_NO_NICE_FEATURES
#include <sscanf2>

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
#define COLOR_GOLD         "{ffd700}"
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
#define DB_USER     "samp-server"
#define DB_PASS     "t8!Qz9@hV4#kR2&pX7"
#define DB_DATABASE     "sv-samp"
#define DB_PORT     3306

#define NAME_SERVER     "Ciudad Libertad Roleplay"
#define GAMEMODE_SERVER "Roleplay en español"

#define PASSWORD_MAX_CHARACTERS    (78)
#define INVALID_NUMBER             (999995)
new const_pepper[20] = "XyZz7y12*ab";

#define FIRST_SKIN_MALE            7
#define FIRST_SKIN_FEMALE          8

/*======================================= DEFINE DIALOGOS ================================== */
#define id_dialogos             100

#define DIALOG_EXIT                     (id_dialogos+0)
#define DIALOG_REGISTER_PASSWORD        (id_dialogos+1)
#define DIALOG_REGISTER_EMAIL           (id_dialogos+2)
#define DIALOG_REGISTER_PLAYER_NAME     (id_dialogos+3)
#define DIALOG_REGISTER_PLAYER_LASTNAME (id_dialogos+4)
#define DIALOG_REGISTER_PLAYER_GENDER   (id_dialogos+5)
#define DIALOG_REGISTER_PLAYER_AGE      (id_dialogos+6)
/*========================================================================================= */

#define SPAWN_NONE        0
#define SPAWN_INITIAL     1
#define SPAWN_HOSPITAL    2
#define SPAWN_NORMAL      3

enum uData {
    uIdSQL,
    uName[MAX_PLAYER_NAME],
    uPassword[PASSWORD_MAX_CHARACTERS+25],
    ph[19],
    uMail[60],
    uIp[17],
    uRegisterDate[9],
    uLastLogin[9],
    aLevel,

    lastDialog,
    isLoggedIn,
    spawnState,

    currentCharacterIdSQL // ID del personaje actual
};

enum pData {
    pIdSQL,
    pName[25],
    pLastname[25],
    pGender,
    pAge,
    pSkin,
    pMoney,
    pLevel,
    pExp,
    pJob[2], // 0 y 1
    Float:pPosX,Float:pPosY,Float:pPosZ,Float:pRot,
    Float:pHealth,
    Float:pArmor,
    pInterior,
    pDimension
};

new characterInfo[MAX_PLAYERS][pData], userInfo[MAX_PLAYERS][uData];

main(){
    DatabaseConnect();
    SetGameModeText(GAMEMODE_SERVER);
}
public OnGameModeInit(){
    return 1;
}
public OnPlayerConnect(playerid){
    modoLobby(playerid, 1);
    userInfo[playerid][spawnState] = SPAWN_NONE;
    GetPlayerName(playerid, userInfo[playerid][uName], MAX_PLAYER_NAME);
    SetTimerEx("ClearChat", 400, false, "i", playerid);
    new DB_Query[256],Cache:ResultCache_;
    format(DB_Query, sizeof(DB_Query), "SELECT * FROM users WHERE username='%s' LIMIT 1", userInfo[playerid][uName]);
    ResultCache_ = mysql_query(database, DB_Query);
    if(cache_num_rows()){//-------------------------------------------------------------El usuario existe
        SendClientMessage(playerid, -1, "El usuario existe");



    }else{ //---------------------------------------------------------------------------El usuario no existe
        SetTimerEx("_mensajeBienvenida", 500, false, "i", playerid);

        SetTimerEx("_cuadroRegistroPassword", 800, false, "i", playerid); 




    }
    cache_delete(ResultCache_);
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    guardarCuenta(playerid);
    format(userInfo[playerid][uName], MAX_PLAYER_NAME, "");
    
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_REGISTER_PASSWORD){
        if(response){
            while((strlen(inputtext) < 8 || strlen(inputtext) > PASSWORD_MAX_CHARACTERS) || strfind(inputtext, " ") != -1){
                _cuadroRegistroPassword(playerid);
                if(strlen(inputtext) < 8){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"La contraseña debe tener al menos 8 caracteres.");}
                else if(strlen(inputtext) > PASSWORD_MAX_CHARACTERS){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"La contraseña no debe superar los 78 caracteres.");}
                if(strfind(inputtext, " ") != -1){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"La contraseña no debe contener espacios.");}
                return 1;
            }
            new hash[144];
            generateRandomSalt(userInfo[playerid][ph], 17);
            
            HashConPepper(inputtext, userInfo[playerid][ph], hash, sizeof(hash));

            format(userInfo[playerid][uPassword], PASSWORD_MAX_CHARACTERS, "%s", hash);
            _cuadroRegistroPlayerName(playerid);
        }
        else{
            userInfo[playerid][lastDialog] = DIALOG_REGISTER_PASSWORD;
            _cuadroPreguntaSalir(playerid);
            return 1;
        }
    }
    else if(dialogid == DIALOG_REGISTER_PLAYER_NAME){
        if(response){
            while((strlen(inputtext) < 3 || strlen(inputtext) > 20) || strfind(inputtext, " ") != -1){
                _cuadroRegistroPlayerName(playerid);
                if(strlen(inputtext) < 3){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El nombre debe tener al menos 3 caracteres.");}
                else if(strlen(inputtext) > 20){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El nombre no debe superar los 20 caracteres.");}
                if(strfind(inputtext, " ") != -1){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El nombre no debe contener espacios.");}
                return 1;
            }
            format(characterInfo[playerid][pName], 20, "%s", inputtext);
            _cuadroRegistroPlayerLastname(playerid);
            return 1;
        }
        else{
            _cuadroRegistroPassword(playerid);
            return 1;
        }
    }
    else if(dialogid == DIALOG_REGISTER_PLAYER_LASTNAME){
        if(response){
            while((strlen(inputtext) < 3 || strlen(inputtext) > 20) || strfind(inputtext, " ") != -1){
                _cuadroRegistroPlayerLastname(playerid);
                if(strlen(inputtext) < 3){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El apellido debe tener al menos 3 caracteres.");}
                else if(strlen(inputtext) > 20){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El apellido no debe superar los 20 caracteres.");}
                if(strfind(inputtext, " ") != -1){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El apellido no debe contener espacios.");}
                return 1;
            }
            format(characterInfo[playerid][pLastname], 20, "%s", inputtext);
            _cuadroRegistroPlayerGender(playerid);
            return 1;
        }
        else{
            _cuadroRegistroPlayerName(playerid);
            return 1;
        }
    }
    else if(dialogid == DIALOG_REGISTER_PLAYER_GENDER){
        if(response){
            if(listitem == 1){
                characterInfo[playerid][pSkin] = FIRST_SKIN_MALE;
                characterInfo[playerid][pGender] = 0;
            }
            else if(listitem == 2){
                characterInfo[playerid][pSkin] = FIRST_SKIN_FEMALE;
                characterInfo[playerid][pGender] = 1;
            }
            else{
                _cuadroRegistroPlayerGender(playerid);
                return 1;
            }
            _cuadroRegistroPlayerAge(playerid);
            return 1;
        }
        else{
            _cuadroRegistroPlayerLastname(playerid);
            return 1;
        }
    }
    else if(dialogid == DIALOG_REGISTER_PLAYER_AGE){
        if(response){
            new edad = strval(inputtext);
            while(edad < 18 || edad > 100 || strvalEx(inputtext) == INVALID_NUMBER){
                _cuadroRegistroPlayerAge(playerid);
                if(strvalEx(inputtext) == INVALID_NUMBER){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"La edad debe ser un número válido.");}
                else if(edad < 18){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"Tu personaje debe ser mayor de 18 años.");}
                else if(edad > 100){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"La edad no debe superar los 100 años.");}
                return 1;
            }
            characterInfo[playerid][pAge] = edad;
            _cuadroRegistroEmail(playerid);
            return 1;
        }
        else{
            _cuadroRegistroPlayerGender(playerid);
            return 1;
        }
    }
    else if(dialogid == DIALOG_REGISTER_EMAIL){
        if(response){
            if(strlen(inputtext) > 0){
                while(strfind(inputtext, " ") != -1 || strfind(inputtext, "@") == -1 || strfind(inputtext, ".") == -1){
                    _cuadroRegistroEmail(playerid);
                    if(strfind(inputtext, " ") != -1){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El correo electrónico no debe contener espacios.");}
                    if(strfind(inputtext, "@") == -1 || strfind(inputtext, ".") == -1){SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"El correo electrónico no es válido.");}
                    return 1;
                }
                format(userInfo[playerid][uMail], 60, "%s", inputtext);
            }else{
                format(userInfo[playerid][uMail], 60, "No especificado");
            }
            new DB_Query[512];
            mysql_format(database, DB_Query, sizeof(DB_Query),
                "INSERT INTO users (username,password,ph,email,last_login,ip) VALUES ('%e','%e','%e','%e',NOW(),'%e')",
                userInfo[playerid][uName],
                userInfo[playerid][uPassword],
                userInfo[playerid][ph],
                userInfo[playerid][uMail],
                userInfo[playerid][uIp]
            );

            mysql_tquery(database, DB_Query, "OnUserInsert", "i", playerid);


            userInfo[playerid][spawnState] = SPAWN_INITIAL;
            modoLobby(playerid, 0);
            
            characterInfo[playerid][pMoney] = 1000;
            characterInfo[playerid][pLevel] = 1;
            characterInfo[playerid][pExp] = 0;
            characterInfo[playerid][pPosX] = 1765.931274;
            characterInfo[playerid][pPosY] = -1949.806640;
            characterInfo[playerid][pPosZ] = 14.609554;
            characterInfo[playerid][pRot] = 271.041625;
            characterInfo[playerid][pHealth] = 100;
            characterInfo[playerid][pArmor] = 0;
            characterInfo[playerid][pInterior] = 0;
            characterInfo[playerid][pDimension] = 0;

            SetTimerEx("SpawnPlayerEx", 200, false, "i", playerid);
            SendClientMessage(playerid, -1, COLOR_SUCCESS"¡Registro completado! Bienvenido a "COLOR_GOLD""NAME_SERVER"!");
            return 1;
        }
        else{
            _cuadroRegistroPlayerAge(playerid);
            return 1;
        }
    }
    else if(dialogid == DIALOG_EXIT){
        if(response){
            SetTimerEx("kickPlayer", 500, false, "i", playerid);
            return 1;
        }
        else{
            if(userInfo[playerid][lastDialog] == DIALOG_REGISTER_PASSWORD){
                _cuadroRegistroPassword(playerid);
            }
            return 1;
        }
    }
    return 1;
}

// Callback del insert
forward OnUserInsert(playerid);
public OnUserInsert(playerid)
{
    userInfo[playerid][uIdSQL] = cache_insert_id(); // acá sí lo obtenés bien

    // Ahora podés usarlo en el insert de characters
    new q2[512];
    mysql_format(database, q2, sizeof(q2),
        "INSERT INTO characters (user_id,name,lastname,gender,age,skin,level,money,bank,posX,posY,posZ,rot,health,armor,interior,dimension) VALUES (%d,'%e','%e',%d,%d,%d,1,1000,0,%.2f,%.2f,%.2f,%.2f,100,0,0,0)",
        userInfo[playerid][uIdSQL],
        characterInfo[playerid][pName],
        characterInfo[playerid][pLastname],
        characterInfo[playerid][pGender],
        characterInfo[playerid][pAge],
        characterInfo[playerid][pSkin],
        characterInfo[playerid][pPosX],
        characterInfo[playerid][pPosY],
        characterInfo[playerid][pPosZ],
        characterInfo[playerid][pRot]
    );
    mysql_tquery(database, q2, "OnPlayerInsert", "i", playerid);
}


// Callback para jugadores
forward OnPlayerInsert(playerid);
public OnPlayerInsert(playerid)
{
    characterInfo[playerid][pIdSQL] = cache_insert_id(); // ID del personaje
    userInfo[playerid][currentCharacterIdSQL] = characterInfo[playerid][pIdSQL]; // Guardás el ID del personaje actual en userInfo
}

public OnPlayerSpawn(playerid){
    if(!IsPlayerLoggedIn(playerid)){ // Si el jugador no está logueado, lo sacamos
        SendClientMessage(playerid, -1, COLOR_ERROR"Error.");
        return 0;
    }else{ // Si está logueado, lo dejamos spawnear
        if(userInfo[playerid][spawnState] == SPAWN_INITIAL){
            SetPlayerPos(playerid, characterInfo[playerid][pPosX], characterInfo[playerid][pPosY], characterInfo[playerid][pPosZ]);
            SetPlayerFacingAngle(playerid, characterInfo[playerid][pRot]);
            SetPlayerSkin(playerid, characterInfo[playerid][pSkin]);
            SetPlayerHealth(playerid, characterInfo[playerid][pHealth]);
            SetPlayerArmour(playerid, characterInfo[playerid][pArmor]);
            SetPlayerMoneyEx(playerid, characterInfo[playerid][pMoney]);
            SetPlayerVirtualWorld(playerid, characterInfo[playerid][pDimension]);
            SetPlayerInterior(playerid, characterInfo[playerid][pInterior]);
            userInfo[playerid][spawnState] = SPAWN_NORMAL;

            new _cacheMessage[128];
            format(_cacheMessage, sizeof(_cacheMessage), "DEBUG: ID Usuario: %d, ID Personaje: %d", userInfo[playerid][uIdSQL], characterInfo[playerid][pIdSQL]);
            SendClientMessage(playerid, -1, _cacheMessage);
            format(_cacheMessage, sizeof(_cacheMessage), "DEBUG: IsLoggedIn: %d, SpawnState: %d", userInfo[playerid][isLoggedIn], userInfo[playerid][spawnState]);
            SendClientMessage(playerid, -1, _cacheMessage);
        }
        else if(userInfo[playerid][spawnState] == SPAWN_HOSPITAL){
            userInfo[playerid][spawnState] = SPAWN_NORMAL;
        }
    }



    return 1;
}


//=======================================> FUNCTIONS
forward DatabaseConnect();
public DatabaseConnect(){
    database = mysql_connect(DB_HOST, DB_USER, DB_PASS, DB_DATABASE);

    if(database == MYSQL_INVALID_HANDLE || mysql_errno(database) != 0){ // Conexión fallida a la base de datos
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

forward guardarCuenta(playerid);
public guardarCuenta(playerid){
    if(!IsPlayerLoggedIn(playerid)) return 0;
    GetPlayerPos(playerid, characterInfo[playerid][pPosX], characterInfo[playerid][pPosY], characterInfo[playerid][pPosZ]);
    GetPlayerFacingAngle(playerid, characterInfo[playerid][pRot]);
    characterInfo[playerid][pMoney] = GetPlayerMoney(playerid);
    GetPlayerHealth(playerid, characterInfo[playerid][pHealth]);
    GetPlayerArmour(playerid, characterInfo[playerid][pArmor]);
    characterInfo[playerid][pInterior] = GetPlayerInterior(playerid);
    characterInfo[playerid][pDimension] = GetPlayerVirtualWorld(playerid);


    new DB_Query[512];
    mysql_format(database, DB_Query, sizeof(DB_Query),
        "UPDATE characters SET name='%e', lastname='%e', gender=%d, age=%d, skin=%d, health=%d, armor=%d, interior=%d, dimension=%d, posX=%f, posY=%f, posZ=%f, rot=%f WHERE character_id=%d",
        characterInfo[playerid][pName],
        characterInfo[playerid][pLastname],
        characterInfo[playerid][pGender],
        characterInfo[playerid][pAge],
        characterInfo[playerid][pSkin],
        characterInfo[playerid][pHealth],
        characterInfo[playerid][pArmor],
        characterInfo[playerid][pInterior],
        characterInfo[playerid][pDimension],
        characterInfo[playerid][pPosX],
        characterInfo[playerid][pPosY],
        characterInfo[playerid][pPosZ],
        characterInfo[playerid][pRot],

        userInfo[playerid][currentCharacterIdSQL]
    );
    mysql_tquery(database, DB_Query);

    mysql_format(database, DB_Query, sizeof(DB_Query),
        "UPDATE users SET last_login=NOW(), ip='%e' WHERE user_id=%d",
        userInfo[playerid][uIp],
        userInfo[playerid][uIdSQL]
    );
    return 1;
}

forward SetPlayerMoneyEx(playerid, amount);
public SetPlayerMoneyEx(playerid, amount){
    if(!IsPlayerLoggedIn(playerid)) return 0;
    characterInfo[playerid][pMoney] = amount;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, amount);
    return 1;
}

forward ClearChat(playerid);
public ClearChat(playerid){
    for(new i=0; i<50; i++){
        SendClientMessage(playerid, -1, " ");
    }
    return 1;
}

forward kickPlayer(playerid);
public kickPlayer(playerid){
	return Kick(playerid);
}

forward SpawnPlayerEx(playerid);
public SpawnPlayerEx(playerid){
	if(!IsPlayerConnected(playerid)) return 0;
    SpawnPlayer(playerid);
	return 1;
}


forward modoLobby(playerid, onOff);
public modoLobby(playerid, onOff){
    if(!IsPlayerConnected(playerid)) return 0;
    if(onOff == 1){
        TogglePlayerSpectating(playerid, 1);
        userInfo[playerid][isLoggedIn] = 0;
    }
    else if(onOff == 0){
        TogglePlayerSpectating(playerid, 0);
        userInfo[playerid][isLoggedIn] = 1;
    }
    return 1;
}

forward IsPlayerLoggedIn(playerid);
public IsPlayerLoggedIn(playerid){
    if(IsPlayerConnected(playerid) && userInfo[playerid][isLoggedIn] == 1){
        return 1;
    }
    return 0;
}

forward _mensajeBienvenida(playerid);
public _mensajeBienvenida(playerid){
    new _tempMessage[128];
    format(_tempMessage, sizeof(_tempMessage), "Bienvenido a "COLOR_GOLD"%s", NAME_SERVER);
    SendClientMessage(playerid, -1, _tempMessage);
    format(_tempMessage, sizeof(_tempMessage), "No encontramos una cuenta registrada con el nombre "#COLOR_PLAYER"%s", userInfo[playerid][uName]);
    SendClientMessage(playerid, -1, _tempMessage);
    format(_tempMessage, sizeof(_tempMessage), "Para comenzar a jugar, crea tu cuenta.");
    SendClientMessage(playerid, -1, _tempMessage);
    return 1;
}

forward _cuadroRegistroPassword(playerid);
public _cuadroRegistroPassword(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_GOLD"Registro en %s", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"Crea tu "COLOR_SUCCESS"contraseña:\n\n"COLOR_WARNING"- Debe tener al menos 8 caracteres.\n- Máximo 78 caracteres.\n- No debe contener espacios.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_INPUT, _tempTitulo, _tempMessage, "Continuar", "Cancelar");
    return 1;
}
forward _cuadroRegistroPlayerName(playerid);
public _cuadroRegistroPlayerName(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_GOLD"Registro en %s", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"Introduce tu "COLOR_CYAN"NOMBRE:\n\n"COLOR_WARNING"- Entre 3 y 20 caracteres.\n- No debe contener espacios.\n- Solo letras y números.\n"COLOR_SUCCESS"- Usa nombres realistas para el rol.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_NAME, DIALOG_STYLE_INPUT, _tempTitulo, _tempMessage, "Continuar", "Volver");
    return 1;
}
forward _cuadroRegistroPlayerLastname(playerid);
public _cuadroRegistroPlayerLastname(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_GOLD"Registro en %s", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"Introduce tu "COLOR_CYAN"APELLIDO:\n\n"COLOR_WARNING"- Entre 3 y 20 caracteres.\n- No debe contener espacios.\n- Solo letras y números.\n"COLOR_SUCCESS"- Usa apellidos realistas para el rol.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_LASTNAME, DIALOG_STYLE_INPUT, _tempTitulo, _tempMessage, "Continuar", "Volver");
    return 1;
}
forward _cuadroRegistroPlayerGender(playerid);
public _cuadroRegistroPlayerGender(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_GOLD"Registro en %s", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"Selecciona el "COLOR_CYAN"género de tu personaje:\n\n"COLOR_LIGHTBLUE"Masculino\n"COLOR_PINK"Femenino");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_GENDER, DIALOG_STYLE_LIST, _tempTitulo, _tempMessage, "Seleccionar", "Volver");
    return 1;
}
forward _cuadroRegistroEmail(playerid);
public _cuadroRegistroEmail(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_GOLD"Registro en %s", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"Introduce tu "COLOR_CYAN"correo electrónico (opcional):\n\n"COLOR_WARNING"- Lo usaremos solo para recuperar tu cuenta en caso de olvido.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_EMAIL, DIALOG_STYLE_INPUT, _tempTitulo, _tempMessage, "Registrar", "Volver");
    return 1;
}
forward _cuadroRegistroPlayerAge(playerid);
public _cuadroRegistroPlayerAge(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_GOLD"Registro en %s", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"Introduce tu "COLOR_CYAN"edad:\n\n"COLOR_WARNING"- Tu personaje debe ser mayor de 18 años.\n- No es necesario que sea tu edad real, pero sí mayor de 18.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_AGE, DIALOG_STYLE_INPUT, _tempTitulo, _tempMessage, "Continuar", "Volver");
    return 1;
}
forward _cuadroPreguntaSalir(playerid);
public _cuadroPreguntaSalir(playerid){
    new _tempTitulo[128], _tempMessage[256];
    format(_tempTitulo, sizeof(_tempTitulo), COLOR_WARNING"¿Salir de %s?", NAME_SERVER);
    format(_tempMessage, sizeof(_tempMessage), COLOR_WHITE"¿Estás seguro que deseas salir del servidor?");
    ShowPlayerDialog(playerid, DIALOG_EXIT, DIALOG_STYLE_MSGBOX, _tempTitulo, _tempMessage, "Sí", "No");
    return 1;
}

stock strvalEx(input[])
{
    new len = strlen(input);
    if(len == 0) return INVALID_NUMBER;

    for(new i = 0; i < len; i++)
    {
        if(input[i] < '0' || input[i] > '9')
        {
            return INVALID_NUMBER; // Contiene un caracter no numérico
        }
    }
    return strval(input); // Convierte y devuelve en decimal
}

stock generateRandomSalt(output[], size)
{
    new charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    new len = strlen(charset);
    
    for(new i = 0; i < size - 1; i++)
    {
        output[i] = charset[random(len)];
    }
    output[size - 1] = '\0'; // Fin de string
}
//SHA256_PassHash(inputtext, salt, hash, sizeof(hash));
stock HashConPepper(password[], salt[], ret_hash[], ret_hash_len)
{
    new mezcla[256];
    // Concatenás: pepper + password
    format(mezcla, sizeof(mezcla), "%s%s", const_pepper, password);
    // Hasheás usando la nativa, pasando también el salt del usuario
    SHA256_PassHash(mezcla, salt, ret_hash, ret_hash_len);

    printf("Depuracion password: %s\n", password);
    printf("Depuracion mezcla: %s\n", mezcla);
    printf("Depuracion salt: %s\n", salt);
    printf("Depuracion hash: %s\n", ret_hash);
    return 1;
}

CMD:xyz(playerid, params[])
{
    new Float:x, Float:y, Float:z, Float:angle;

    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        GetVehiclePos(vehicleid, x, y, z);
        GetVehicleZAngle(vehicleid, angle);

        SendClientMessage(playerid, -1, "Tu posición en vehículo:");
        printf("Veh[%d] PosX: %f PosY: %f PosZ: %f Rot: %f", vehicleid, x, y, z, angle);
        new msg[144];
        format(msg, sizeof(msg), "X: %.2f, Y: %.2f, Z: %.2f, Rot: %.2f", x, y, z, angle);
        SendClientMessage(playerid, -1, msg);
    }
    else
    {
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, angle);

        SendClientMessage(playerid, -1, "Tu posición a pie:");
        printf("Player[%d] PosX: %f PosY: %f PosZ: %f Rot: %f", playerid, x, y, z, angle);
        new msg[144];
        format(msg, sizeof(msg), "X: %.2f, Y: %.2f, Z: %.2f, Rot: %.2f", x, y, z, angle);
        SendClientMessage(playerid, -1, msg);
    }
    return 1;
}

CMD:guardar(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid)){
        SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"No estás logueado.");
        return 1;
    }
    guardarCuenta(playerid);
    SendClientMessage(playerid, -1, COLOR_SUCCESS"¡Cuenta guardada correctamente!");

    new _cacheMessage[128];
    format(_cacheMessage, sizeof(_cacheMessage), "DEBUG: Dinero: %d, Salud: %f, Armadura: %f, Interior: %d, Dimensión: %d", characterInfo[playerid][pMoney], characterInfo[playerid][pHealth], characterInfo[playerid][pArmor], characterInfo[playerid][pInterior], characterInfo[playerid][pDimension]);
    SendClientMessage(playerid, -1, _cacheMessage);
    return 1;
}
