#include <a_samp>
#include <a_vehicles>
#include <streamer>
#include <zcmd>
#include <a_mysql>
#include <vSyncALS>
#include <vSyncYSI>

#define SSCANF_NO_NICE_FEATURES
#include <sscanf2>

// ==========================================
// ?? PALETA DE COLORES CIUDAD LIBERTAD RP
// ==========================================

// Colores básicos
#define COLOR_WHITE         "{FFFFFF}"
#define COLOR_BLACK         "{000000}"
#define COLOR_RED           "{FF0000}"
#define COLOR_GREEN         "{00FF00}"
#define COLOR_BLUE          "{0000FF}"
#define COLOR_YELLOW        "{FFFF00}"
#define COLOR_CYAN          "{00FFFF}"
#define COLOR_MAGENTA       "{FF00FF}"
#define COLOR_ORANGE        "{FFA500}"
#define COLOR_SILVER        "{C0C0C0}"

// Metálicos y neutros
#define COLOR_BRONZE        "{CD7F32}" // bronce metálico cálido
#define COLOR_GOLD          "{FFD700}" // dorado intenso
#define COLOR_GOLD_SOFT     "{E1C16E}" // dorado suave y elegante
#define COLOR_GRAY          "{A6ACAF}" // gris medio neutro
#define COLOR_GRAY_SOFT     "{BDBDBD}" // gris claro tenue

// Estilo visual principal
#define COLOR_PRIMARY       "{E8C547}" // dorado pálido (color primario)
#define COLOR_ACCENT        "{7FB3D5}" // azul pastel
#define COLOR_TEXT          "{EAEAEA}" // blanco grisáceo para texto principal
#define COLOR_WARNING       "{F5B041}" // ámbar cálido (avisos)
#define COLOR_ERROR         "{EC7063}" // rojo suave (errores)
#define COLOR_SUCCESS       "{82E0AA}" // verde menta (éxitos)
#define COLOR_GREEN_MINT    "{98FB98}" // verde menta brillante

// Tonos adicionales
#define COLOR_PINK          "{FFC0CB}"
#define COLOR_VIOLET        "{8A2BE2}"
#define COLOR_BROWN         "{8B4513}"
#define COLOR_DARKGREEN     "{006400}"
#define COLOR_DARKRED       "{8B0000}"
#define COLOR_DARKBLUE      "{00008B}"
#define COLOR_LIGHTBLUE     "{ADD8E6}"
#define COLOR_LIGHTGREEN    "{90EE90}"

// Roles / categorías
#define COLOR_ADMIN         "{FF6347}" // rojo tomate
#define COLOR_MOD           "{1E90FF}" // azul dodger
#define COLOR_VIP           "{DAA520}" // dorado opaco
#define COLOR_PLAYER        "{87CEEB}" // azul cielo
#define COLOR_SYSTEM        "{B22222}" // rojo oscuro (sistema)

// Contrastes y bases oscuras
#define COLOR_DARKGRAY      "{A9A9A9}"
#define COLOR_LIGHTGRAY     "{D3D3D3}"
#define COLOR_NAVY          "{191970}"
#define COLOR_TEAL          "{008080}"
#define COLOR_MAROON        "{800000}"



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

#define FIRST_SKIN_MALE            101
#define FIRST_SKIN_FEMALE          56

/*======================================= DEFINE DIALOGOS ================================== */
#define id_dialogos             100

#define DIALOG_EXIT                     (id_dialogos+0)
#define DIALOG_REGISTER_PASSWORD        (id_dialogos+1)
#define DIALOG_REGISTER_EMAIL           (id_dialogos+2)
#define DIALOG_REGISTER_PLAYER_NAME     (id_dialogos+3)
#define DIALOG_REGISTER_PLAYER_LASTNAME (id_dialogos+4)
#define DIALOG_REGISTER_PLAYER_GENDER   (id_dialogos+5)
#define DIALOG_REGISTER_PLAYER_AGE      (id_dialogos+6)
#define DIALOG_LOGIN_PASSWORD           (id_dialogos+7)
#define DIALOG_CHARACTER_SELECT         (id_dialogos + 8)

/*========================================================================================= */

#define SPAWN_NONE        0
#define SPAWN_INITIAL     1
#define SPAWN_HOSPITAL    2
#define SPAWN_NORMAL      3

new loginAttempts[MAX_PLAYERS];

new Text:TD_Fondo[MAX_PLAYERS];
new Text:TD_Logo[MAX_PLAYERS];
new Text:TD_Subtitulo[MAX_PLAYERS];


enum uData {
    uIdSQL,
    uName[MAX_PLAYER_NAME],
    uPassword[PASSWORD_MAX_CHARACTERS+25],
    ph[19],
    uMail[60],
    uIp[16],
    uCharactersAmount,
    
    uLevel,
    uExp,
    uMinutesPlayed,

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
    pBank,
    pJob[2], // 0 y 1
    Float:pPosX,Float:pPosY,Float:pPosZ,Float:pRot,
    Float:pHealth,
    Float:pArmor,
    pInterior,
    pDimension,

    pLevel,
    pExp,
    pMinutesPlayed,
    bool:pLevelUp
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
    if(IsPlayerNPC(playerid)) return 1;
    modoLobby(playerid, 1);
    userInfo[playerid][spawnState] = SPAWN_NONE;
    loginAttempts[playerid] = 3;
    GetPlayerName(playerid, userInfo[playerid][uName], MAX_PLAYER_NAME);
    GetPlayerIp(playerid, userInfo[playerid][uIp], 16);
    SetTimerEx("ClearChat", 400, false, "i", playerid);
    new DB_Query[256],Cache:ResultCache_;
    format(DB_Query, sizeof(DB_Query), "SELECT * FROM users WHERE username='%s' LIMIT 1", userInfo[playerid][uName]);
    ResultCache_ = mysql_query(database, DB_Query);
    printf("[LOGIN] Jugador conectado: %s (%s)", userInfo[playerid][uName], userInfo[playerid][uIp]);
    if(cache_num_rows()){//-------------------------------------------------------------El usuario existe
        printf("[LOGIN] Cuenta encontrada para %s. Iniciando autenticación...", userInfo[playerid][uName]);

        cache_get_value_name(0, "ph", userInfo[playerid][ph], 17);
        SetTimerEx("_mensajeBienvenida", 400, false, "ii", playerid,1);
        SetTimerEx("_cuadroLogeoPassword", 5000, false, "ii", playerid,loginAttempts[playerid]); // playerid, attempts

    }else{ //---------------------------------------------------------------------------El usuario no existe
        printf("[REGISTER] No existe cuenta para %s. Iniciando registro...", userInfo[playerid][uName]);

        SetTimerEx("_mensajeBienvenida", 400, false, "ii", playerid,0);

        SetTimerEx("_cuadroRegistroPassword", 5000, false, "i", playerid); 




    }
    cache_delete(ResultCache_);
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    guardarCuenta(playerid);
    format(userInfo[playerid][uName], MAX_PLAYER_NAME, "");
    
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
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
                "INSERT INTO users (username,password,ph,email,last_login,ip,register_date) VALUES ('%e','%e','%e','%e',NOW(),'%s',NOW())",
                userInfo[playerid][uName],
                userInfo[playerid][uPassword],
                userInfo[playerid][ph],
                userInfo[playerid][uMail],
                userInfo[playerid][uIp]
            );

            mysql_tquery(database, DB_Query, "OnUserInsert", "i", playerid);


            userInfo[playerid][spawnState] = SPAWN_INITIAL;
            SetTimerEx("modoLobby", 1000, false, "ii", playerid,0);
            
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

            SendClientMessage(playerid, -1, COLOR_SUCCESS"¡Registro completado! Bienvenido a "COLOR_GOLD""NAME_SERVER"!");
            return 1;
        }
        else{
            _cuadroRegistroPlayerAge(playerid);
            return 1;
        }
    }else if(dialogid == DIALOG_LOGIN_PASSWORD)
    {
        if(response)
        {
            // Si el usuario deja el campo vacío
            if(strlen(inputtext) == 0)
            {
                _cuadroLogeoPassword(playerid, loginAttempts[playerid]);
                SendClientMessage(playerid, -1, COLOR_ERROR"Error: "COLOR_WHITE"La contraseña no puede estar vacía.");
                return 1;
            }

            // Hashear contraseña ingresada
            new hash[144];
            HashConPepper(inputtext, userInfo[playerid][ph], hash, sizeof(hash));

            // Consultar en base de datos
            new DB_Query[256], Cache:ResultCache_;
            format(DB_Query, sizeof(DB_Query),
                "SELECT * FROM users WHERE username='%s' AND password='%s' LIMIT 1",
                userInfo[playerid][uName], hash
            );

            ResultCache_ = mysql_query(database, DB_Query);

            if(cache_num_rows()) // ? Contraseña correcta
            {
<<<<<<< HEAD
                printf("[LOGIN] %s ha iniciado sesión correctamente (user_id=%d).", userInfo[playerid][uName], userInfo[playerid][uIdSQL]);

=======
>>>>>>> 37bf9b112cd03a13de79cda59e8e0580937dd064
                cache_get_value_name_int(0, "user_id", userInfo[playerid][uIdSQL]);
                userInfo[playerid][isLoggedIn] = 1;
                userInfo[playerid][spawnState] = SPAWN_INITIAL;

                SendClientMessage(playerid, -1, COLOR_SUCCESS"¡Has iniciado sesión correctamente!");
                mysql_format(database, DB_Query, sizeof(DB_Query),
                    "SELECT character_id, name, lastname FROM characters WHERE user_id=%d",
                    userInfo[playerid][uIdSQL]
                );
                ResultCache_ = mysql_query(database, DB_Query);
                OnCharacterList(playerid);



            }
            else // ? Contraseña incorrecta
            {
                printf("[LOGIN][ERROR] Contraseña incorrecta para %s. Intentos restantes: %d", userInfo[playerid][uName], loginAttempts[playerid]);

                loginAttempts[playerid]--;
                if(loginAttempts[playerid] <= 0)
                {
                    printf("[LOGIN][BLOCK] %s expulsado por intentos fallidos.", userInfo[playerid][uName]);

                    SendClientMessage(playerid, -1, COLOR_ERROR"Has agotado tus intentos de inicio de sesión.");
                    SetTimerEx("kickPlayer", 1000, false, "i", playerid);
                    cache_delete(ResultCache_);
                    return 1;
                }
                else
                {
                    new msg[128];
                    format(msg, sizeof(msg),
                        COLOR_ERROR"Contraseña incorrecta. "COLOR_WARNING"Tienes %d intento(s) restante(s).",
                        loginAttempts[playerid]
                    );
                    SendClientMessage(playerid, -1, msg);
                    _cuadroLogeoPassword(playerid, loginAttempts[playerid]);
                }
            }

            cache_delete(ResultCache_);
        }
        else // Canceló el diálogo
        {
            userInfo[playerid][lastDialog] = DIALOG_LOGIN_PASSWORD;
            _cuadroPreguntaSalir(playerid);
        }
    }
    else if(dialogid == DIALOG_CHARACTER_SELECT)
    {
        if(!response || listitem == userInfo[playerid][uCharactersAmount])
        {
            SendClientMessage(playerid, -1, COLOR_ERROR"No has seleccionado ningún personaje.");
            _cuadroSeleccionPersonaje(playerid); // vuelve a mostrar el cuadro
            return 1;
        }


        // Si es válido, carga el personaje seleccionado
        new DB_Query[256];
        mysql_format(database, DB_Query, sizeof(DB_Query),
            "SELECT * FROM characters WHERE user_id=%d LIMIT %d,1",
            userInfo[playerid][uIdSQL], listitem
        );
        mysql_tquery(database, DB_Query, "OnCharacterSelect", "i", playerid);
        return 1;
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
            else if(userInfo[playerid][lastDialog] == DIALOG_LOGIN_PASSWORD){
                _cuadroLogeoPassword(playerid,loginAttempts[playerid]);
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
    printf("[REGISTER] Nuevo usuario insertado: ID_SQL=%d, Nombre=%s", cache_insert_id(), userInfo[playerid][uName]);
    userInfo[playerid][uIdSQL] = cache_insert_id(); // acá sí lo obtenés bien
    printf("[REGISTER] Insertando personaje para %s %s (user_id=%d)...", characterInfo[playerid][pName], characterInfo[playerid][pLastname], userInfo[playerid][uIdSQL]);

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

forward OnCharacterList(playerid);
public OnCharacterList(playerid)
{   
    
    new rows = cache_num_rows();
    if(rows == 0)
    {
        
        SendClientMessage(playerid, -1, COLOR_ERROR"No tienes personajes creados. Contacta con un administrador.");
        SetTimerEx("kickPlayer", 3000, false, "i", playerid);
        return 1;
    }
    

    

    userInfo[playerid][uCharactersAmount] = rows;
    new dialogContent[512];
    new name[32], lastname[32], p_nivel, p_bank, p_gender, p_Dinero;
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name(i, "name", name, sizeof(name));
        cache_get_value_name(i, "lastname", lastname, sizeof(lastname));
        cache_get_value_name_int(i, "level", p_nivel);
        cache_get_value_name_int(i, "money", p_Dinero);
        cache_get_value_name_int(i, "bank", p_bank);
        cache_get_value_name_int(i, "gender", p_gender);

        //format(dialogContent, sizeof(dialogContent), "%s"#COLOR_BRONZE"%s %s "#COLOR_WHITE"| "#COLOR_BRONZE"Nivel %d"#COLOR_WHITE"("#COLOR_BRONZE"%d"#COLOR_WHITE"/"#COLOR_BRONZE"%d"#COLOR_WHITE") | "#COLOR_LIGHTGREEN"$%d\n", dialogContent, name, lastname,p_nivel,p_exp,p_LevelUp,p_Dinero);
        new cache_genero[25]
        if(p_gender == 0){ // Male
            format(cache_genero, sizeof(cache_genero),"{0000AA}Masculino");
        }else{ // Female
            format(cache_genero, sizeof(cache_genero),"{FFC0CB}Femenino");
        }

        format(dialogContent, sizeof(dialogContent),
            "%s"#COLOR_BRONZE"%s %s "#COLOR_GRAY"? %s "#COLOR_GRAY"? "#COLOR_WHITE"Nivel "#COLOR_GOLD"%d "#COLOR_GRAY"? "#COLOR_WHITE"Efectivo "#COLOR_SUCCESS"$%d "#COLOR_GRAY"? "#COLOR_WHITE"Banco"#COLOR_SUCCESS"$%d\n",
            dialogContent, name, lastname, cache_genero,p_nivel, p_Dinero, p_Banco);
        }

    // Línea gris final
    format(dialogContent, sizeof(dialogContent), "%s%sCrea tu siguiente personaje con VIP", dialogContent, COLOR_GRAY);

    new title[64];
    format(title, sizeof(title), COLOR_GOLD"Selecciona tu personaje");
    ShowPlayerDialog(playerid, DIALOG_CHARACTER_SELECT, DIALOG_STYLE_LIST, title, dialogContent, "Seleccionar", "Cancelar");

    return 1;
}

forward OnCharacterSelect(playerid);
public OnCharacterSelect(playerid)
{
    if(!cache_num_rows()) return 1;

    cache_get_value_name_int(0, "character_id", userInfo[playerid][currentCharacterIdSQL]);
    cache_get_value_name(0, "name", characterInfo[playerid][pName], 25);
    cache_get_value_name(0, "lastname", characterInfo[playerid][pLastname], 25);
    cache_get_value_name_int(0, "gender", characterInfo[playerid][pGender]);
    cache_get_value_name_int(0, "age", characterInfo[playerid][pAge]);
    cache_get_value_name_int(0, "skin", characterInfo[playerid][pSkin]);
    cache_get_value_name_float(0, "posX", characterInfo[playerid][pPosX]);
    cache_get_value_name_float(0, "posY", characterInfo[playerid][pPosY]);
    cache_get_value_name_float(0, "posZ", characterInfo[playerid][pPosZ]);
    cache_get_value_name_float(0, "rot", characterInfo[playerid][pRot]);
    cache_get_value_name_float(0, "health", characterInfo[playerid][pHealth]);
    cache_get_value_name_float(0, "armor", characterInfo[playerid][pArmor]);
    cache_get_value_name_int(0, "interior", characterInfo[playerid][pInterior]);
    cache_get_value_name_int(0, "dimension", characterInfo[playerid][pDimension]);
    cache_get_value_name_int(0, "money", characterInfo[playerid][pMoney]);
    cache_get_value_name_int(0, "bank", characterInfo[playerid][pBank]);

    printf("[CHARACTER] %s %s (char_id=%d) cargado correctamente para %s.", characterInfo[playerid][pName], characterInfo[playerid][pLastname], userInfo[playerid][currentCharacterIdSQL], userInfo[playerid][uName]);

    userInfo[playerid][spawnState] = SPAWN_INITIAL;
    modoLobby(playerid, 0);
    SetTimerEx("SpawnPlayerEx", 500, false, "i", playerid);

    return 1;
}


public OnPlayerSpawn(playerid){
    if(!IsPlayerLoggedIn(playerid) && !IsPlayerNPC(playerid)){ // Si el jugador no está logueado, lo sacamos
        printf("[SPAWN][ERROR] %s intentó spawnear sin estar logueado.", userInfo[playerid][uName]);
        SetTimerEx("kickPlayer", 1000, false, "i", playerid);
        return 1;
    }else{ // Si está logueado, lo dejamos spawnear
        if(userInfo[playerid][spawnState] == SPAWN_INITIAL){
            printf("[SPAWN] %s spawneado correctamente en (%.2f, %.2f, %.2f)", userInfo[playerid][uName], characterInfo[playerid][pPosX], characterInfo[playerid][pPosY], characterInfo[playerid][pPosZ]);

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
        printf("[MySQL][ERROR] Conexión fallida. Código de error: %d", mysql_errno(database));
        SetTimer("CerrarServidor", 10000, false);
    }
    else{ // Conexión establecida correctamente
        printf("[MySQL][OK] Conectado a %s:%d (DB: %s, User: %s)", DB_HOST, DB_PORT, DB_DATABASE, DB_USER);

        return 1;
    }
    return 0;
}
forward CerrarServidor();
public CerrarServidor(){
    SendRconCommand("exit");
    return 1;
}
/*
forward UpdatePlayerMinutes(playerid);
public UpdatePlayerMinutes(playerid){
    if(!IsPlayerLoggedIn(playerid)) return 0;
    characterInfo[playerid][pMinutesPlayed]++;
    if(characterInfo[playerid][pMinutesPlayed] >= 60){
        if(characterInfo[playerid][pLevelUp]){
            SendClientMessage(playerid, -1, COLOR_WARNING"Recuerda que puedes subir de nivel. Usa el comando /comandoParaSubirDeNivel");
            return 1;
        }
        characterInfo[playerid][pMinutesPlayed] = 0;
        characterInfo[playerid][pExp] += 100;
        if(characterInfo[playerid][pExp] >= generateExpPlayerNextGoal(playerid)){
            characterInfo[playerid][pLevel]++;
            characterInfo[playerid][pExp] = 0;
            SendClientMessage(playerid, -1, COLOR_SUCCESS"Ya puedes subir de nivel. /comandoParaSubirDeNivel");
            characterInfo[playerid][pLevelUp] = true;
        }
    }
}

forward generateExpPlayerNextGoal(playerid);
public generateExpPlayerNextGoal(playerid){
    if(!IsPlayerLoggedIn(playerid)) return 0;
    new expNextGoal = (100 * (characterInfo[playerid][pLevel] ** 1.5)) + (characterInfo[playerid][pLevel] * 50);
    return expNextGoal;
}
*/

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
        "UPDATE characters SET name='%e', lastname='%e', gender=%d, age=%d, skin=%d, health=%f, armor=%f, interior=%d, dimension=%d, posX=%f, posY=%f, posZ=%f, rot=%f,money=%d, bank=%d WHERE character_id=%d",
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
        characterInfo[playerid][pMoney],
        characterInfo[playerid][pBank],

        userInfo[playerid][currentCharacterIdSQL]
    );
    mysql_tquery(database, DB_Query);

    mysql_format(database, DB_Query, sizeof(DB_Query),
        "UPDATE users SET last_login=NOW(), ip='%s' WHERE user_id=%d",
        userInfo[playerid][uIp],
        userInfo[playerid][uIdSQL]
    );

    printf("[SAVE] Datos guardados: user_id=%d, char_id=%d, Pos(%.2f, %.2f, %.2f), Dinero=%d", userInfo[playerid][uIdSQL], userInfo[playerid][currentCharacterIdSQL], characterInfo[playerid][pPosX], characterInfo[playerid][pPosY], characterInfo[playerid][pPosZ], characterInfo[playerid][pMoney]);

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
public modoLobby(playerid, onOff)
{
    if(!IsPlayerConnected(playerid)) return 0;

    if(onOff == 1)
    {
        TogglePlayerSpectating(playerid, 1);
        userInfo[playerid][isLoggedIn] = 0;
        SetPlayerVirtualWorld(playerid, 0);


        GameTextForPlayer(playerid, "~y~Conectando a~n~~w~Ciudad Libertad Roleplay...", 5000, 3);

        /* Cámara panorámica ls
        SetPlayerCameraPos(playerid, 1741.497436, -736.675598, 167.170059);
        SetPlayerCameraLookAt(playerid, 1687.005126, -847.056640, 134.222259);
        InterpolateCameraPos(playerid,
            1741.497436, -736.675598, 167.170059,
            1687.005126, -847.056640, 134.222259,
            16000, CAMERA_MOVE
        );
        */
        SetPlayerCameraPos(playerid, 2256.980468, 1285.469970, 62.301094);
        SetPlayerCameraLookAt(playerid, 2175.718261, 1286.025024, 62.687934);
        InterpolateCameraPos(playerid,
            2256.980468, 1285.469970, 62.301094,
            2097.629638, 1285.348999, 83.135856,
            16000, CAMERA_MOVE
        );


        // Esperar 100 ms y reproducir música
        SetTimerEx("PlayAudioLobby", 100, false, "i", playerid);
        
    }
    else if(onOff == 0)
    {
        StopAudioStreamForPlayer(playerid);
        TogglePlayerSpectating(playerid, 0);
        userInfo[playerid][isLoggedIn] = 1;

        TextDrawHideForPlayer(playerid, TD_Fondo[playerid]);
        TextDrawHideForPlayer(playerid, TD_Logo[playerid]);
        TextDrawHideForPlayer(playerid, TD_Subtitulo[playerid]);

        TextDrawDestroy(TD_Fondo[playerid]);
        TextDrawDestroy(TD_Logo[playerid]);
        TextDrawDestroy(TD_Subtitulo[playerid]);
        SetTimerEx("SpawnPlayerEx", 500, false, "i", playerid);

    }
    return 1;
}

// Callback real de audio
forward PlayAudioLobby(playerid);
public PlayAudioLobby(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    // Fondo negro translúcido
    TD_Fondo[playerid] = TextDrawCreate(0.0, 0.0, "_");
    TextDrawLetterSize(TD_Fondo[playerid], 0.0, 50.0);
    TextDrawTextSize(TD_Fondo[playerid], 640.0, 480.0);
    TextDrawAlignment(TD_Fondo[playerid], 1);
    TextDrawColor(TD_Fondo[playerid], 0x00000099); // negro semitransparente
    TextDrawUseBox(TD_Fondo[playerid], 1);
    TextDrawBoxColor(TD_Fondo[playerid], 0x00000066);
    TextDrawShowForPlayer(playerid, TD_Fondo[playerid]);

    // Logo / nombre del servidor
    TD_Logo[playerid] = TextDrawCreate(320.0, 80.0, NAME_SERVER);
    TextDrawLetterSize(TD_Logo[playerid], 0.7, 2.5);
    TextDrawAlignment(TD_Logo[playerid], 2);
    TextDrawColor(TD_Logo[playerid], 0xE8C547FF); // dorado
    TextDrawSetOutline(TD_Logo[playerid], 2);
    TextDrawSetShadow(TD_Logo[playerid], 0);
    TextDrawFont(TD_Logo[playerid], 1);
    TextDrawShowForPlayer(playerid, TD_Logo[playerid]);

    TD_Subtitulo[playerid] = TextDrawCreate(320.0, 115.0, "Tu historia. Tu libertad.");
    TextDrawLetterSize(TD_Subtitulo[playerid], 0.35, 1.2);
    TextDrawAlignment(TD_Subtitulo[playerid], 2);
    TextDrawColor(TD_Subtitulo[playerid], 0xEAEAEAFF);
    TextDrawSetOutline(TD_Subtitulo[playerid], 1);
    TextDrawFont(TD_Subtitulo[playerid], 1);
    TextDrawShowForPlayer(playerid, TD_Subtitulo[playerid]);

    PlayAudioStreamForPlayer(playerid, "https://raw.githubusercontent.com/avmaximo/server-sound_/main/intro2.mp3");
    return 1;
}

forward IsPlayerLoggedIn(playerid);
public IsPlayerLoggedIn(playerid){
    if(IsPlayerConnected(playerid) && userInfo[playerid][isLoggedIn] == 1){
        return 1;
    }
    return 0;
}

forward _mensajeBienvenida(playerid,nro);
public _mensajeBienvenida(playerid,nro){
    new _tempMessage[128];
    if(nro == 0){
        format(_tempMessage, sizeof(_tempMessage), "¡Bienvenido/a a "COLOR_GOLD"%s"#COLOR_WHITE"!", NAME_SERVER);
        SendClientMessage(playerid, -1, _tempMessage);
        format(_tempMessage, sizeof(_tempMessage), "No encontramos una cuenta registrada con el nombre "#COLOR_PLAYER"%s", userInfo[playerid][uName]);
        SendClientMessage(playerid, -1, _tempMessage);
        format(_tempMessage, sizeof(_tempMessage), "Para comenzar a jugar, crea tu cuenta.");
        SendClientMessage(playerid, -1, _tempMessage);
    }else{
        format(_tempMessage, sizeof(_tempMessage), "¡Bienvenido/a de nuevo a "COLOR_GOLD"%s"#COLOR_WHITE"!", NAME_SERVER);
        SendClientMessage(playerid, -1, _tempMessage);
    }
    return 1;
}

forward _cuadroRegistroPassword(playerid);
public _cuadroRegistroPassword(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Registro de cuenta");
    format(msg, sizeof(msg), "{EAEAEA}Creá tu {82E0AA}contraseña segura{EAEAEA} para continuar.\n\n{A6ACAF}Requisitos:\n{F5B041}» {EAEAEA}Mínimo 8 caracteres\n{F5B041}» {EAEAEA}Máximo 78 caracteres\n{F5B041}» {EAEAEA}Sin espacios\n\n{7FB3D5}Consejo:{EAEAEA} combiná letras y números.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PASSWORD, DIALOG_STYLE_INPUT, titulo, msg, "Continuar", "Cancelar");
    return 1;
}



forward _cuadroRegistroPlayerName(playerid);
public _cuadroRegistroPlayerName(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Registro de personaje");
    format(msg, sizeof(msg), "{EAEAEA}Ingresá el {82E0AA}nombre{EAEAEA} de tu personaje.\n\n{A6ACAF}Reglas:\n{F5B041}» {EAEAEA}Entre 3 y 20 caracteres\n{F5B041}» {EAEAEA}Sin espacios ni símbolos\n{F5B041}» {EAEAEA}Debe parecer un nombre real\n\n{7FB3D5}Ejemplo:{EAEAEA} Mateo, Nicolás, Javier.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_NAME, DIALOG_STYLE_INPUT, titulo, msg, "Continuar", "Volver");
    return 1;
}

forward _cuadroRegistroPlayerLastname(playerid);
public _cuadroRegistroPlayerLastname(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Registro de personaje");
    format(msg, sizeof(msg), "{EAEAEA}Ingresá el {82E0AA}apellido{EAEAEA} de tu personaje.\n\n{A6ACAF}Reglas:\n{F5B041}» {EAEAEA}Entre 3 y 20 caracteres\n{F5B041}» {EAEAEA}Sin espacios ni símbolos\n{F5B041}» {EAEAEA}Debe sonar realista\n\n{7FB3D5}Ejemplo:{EAEAEA} Ramírez, Gutiérrez, López.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_LASTNAME, DIALOG_STYLE_INPUT, titulo, msg, "Continuar", "Volver");
    return 1;
}

forward _cuadroRegistroPlayerGender(playerid);
public _cuadroRegistroPlayerGender(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Registro de personaje");
    format(msg, sizeof(msg), "{EAEAEA}Seleccioná el {82E0AA}género{EAEAEA} de tu personaje:\n\n{0000FF}Masculino\n{FFC0CB}Femenino");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_GENDER, DIALOG_STYLE_LIST, titulo, msg, "Seleccionar", "Volver");
    return 1;
}

forward _cuadroRegistroEmail(playerid);
public _cuadroRegistroEmail(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Registro de cuenta");
    format(msg, sizeof(msg), "{EAEAEA}Ingresá tu {82E0AA}correo electrónico{EAEAEA} (opcional).\n\n{A6ACAF}Recomendado para:\n{F5B041}» {EAEAEA}Recuperar tu cuenta\n{F5B041}» {EAEAEA}Recibir avisos del servidor\n\n{7FB3D5}Ejemplo:{EAEAEA} jugador@email.com");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_EMAIL, DIALOG_STYLE_INPUT, titulo, msg, "Registrar", "Volver");
    return 1;
}

forward _cuadroRegistroPlayerAge(playerid);
public _cuadroRegistroPlayerAge(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Registro de personaje");
    format(msg, sizeof(msg), "{EAEAEA}Ingresá la {82E0AA}edad{EAEAEA} de tu personaje.\n\n{A6ACAF}Requisitos:\n{F5B041}» {EAEAEA}Debe ser mayor de 18 años\n{F5B041}» {EAEAEA}Máximo 100 años\n\n{7FB3D5}Nota:{EAEAEA} No tiene que ser tu edad real, pero sí coherente con el rol.");
    ShowPlayerDialog(playerid, DIALOG_REGISTER_PLAYER_AGE, DIALOG_STYLE_INPUT, titulo, msg, "Continuar", "Volver");
    return 1;
}

forward _cuadroLogeoPassword(playerid, attempts);
public _cuadroLogeoPassword(playerid, attempts){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{7FB3D5}» Iniciar sesión");
    format(msg, sizeof(msg), "{EAEAEA}Ingresá tu {82E0AA}contraseña{EAEAEA} para acceder a tu cuenta.\n\n{A6ACAF}Intentos restantes: {F5B041}%d\n\n{7FB3D5}Consejo:{EAEAEA} revisá si tenés las mayúsculas activadas.", attempts);
    ShowPlayerDialog(playerid, DIALOG_LOGIN_PASSWORD, DIALOG_STYLE_PASSWORD, titulo, msg, "Continuar", "Volver");
    return 1;
}


forward _cuadroSeleccionPersonaje(playerid);
public _cuadroSeleccionPersonaje(playerid)
{
    new DB_Query[256];
    mysql_format(database, DB_Query, sizeof(DB_Query),
        "SELECT character_id, name, lastname FROM characters WHERE user_id=%d",
        userInfo[playerid][uIdSQL]
    );
    mysql_tquery(database, DB_Query, "OnCharacterList", "i", playerid);
    return 1;
}


forward _cuadroPreguntaSalir(playerid);
public _cuadroPreguntaSalir(playerid){
    new titulo[128], msg[512];
    format(titulo, sizeof(titulo), "{F5B041}» Confirmar salida");
    format(msg, sizeof(msg), "{EAEAEA}¿Deseás salir del servidor?\n\n{A6ACAF}Tu progreso se guardará automáticamente si estás logueado.");
    ShowPlayerDialog(playerid, DIALOG_EXIT, DIALOG_STYLE_MSGBOX, titulo, msg, "Sí", "No");
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
        printf("Veh[%d] PosXYZR: %f, %f, %f, %f", vehicleid, x, y, z, angle);
        new msg[144];
        format(msg, sizeof(msg), "X: %.2f, Y: %.2f, Z: %.2f, Rot: %.2f", x, y, z, angle);
        SendClientMessage(playerid, -1, msg);
    }
    else
    {
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, angle);

        SendClientMessage(playerid, -1, "Tu posición a pie:");
        printf("Player[%d] PosXYZR: %f, %f, %f, %f", playerid, x, y, z, angle);
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
CMD:veh(playerid, params[])
{
    new modelid;
    if(sscanf(params, "i", modelid))
        return SendClientMessage(playerid, -1, "{F5B041}Uso:{EAEAEA} /veh [ID del modelo]");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    CreateVehicle(modelid, x, y, z+1, a, random(126), random(126), -1);
    //PutPlayerInVehicle(playerid, vehicleid, 0);
    SetPlayerPos(playerid, x, y, z+3);

    new msg[64];
    format(msg, sizeof(msg), "{82E0AA}Vehículo creado ID %d", modelid);
    SendClientMessage(playerid, -1, msg);

    return 1;
}

CMD:tp(playerid, params[])
{
    new targetid;
    if(sscanf(params, "i", targetid))
    {
        SendClientMessage(playerid, -1, "Uso: /tp [id]");
        return 1;
    }

    if(targetid < 0 || targetid >= MAX_PLAYERS)
    {
        SendClientMessage(playerid, -1, "ID inválido.");
        return 1;
    }

    if(!IsPlayerConnected(targetid) && !IsPlayerNPC(targetid))
    {
        SendClientMessage(playerid, -1, "Ese ID no está conectado.");
        return 1;
    }

    new Float:x, Float:y, Float:z, Float:angle;
    new interior, vw;

    interior = GetPlayerInterior(targetid);
    vw = GetPlayerVirtualWorld(targetid);
    SetPlayerInterior(playerid, interior);
    SetPlayerVirtualWorld(playerid, vw);

    if(IsPlayerInAnyVehicle(targetid))
    {
        new veh = GetPlayerVehicleID(targetid);
        GetVehiclePos(veh, x, y, z);
        GetVehicleZAngle(veh, angle);
        z += 1.5; // elevar un poco para no quedar pegado
    }
    else
    {
        GetPlayerPos(targetid, x, y, z);
        GetPlayerFacingAngle(targetid, angle);
        z += 1.0;
    }

    SetPlayerPos(playerid, x, y, z);
    SetPlayerFacingAngle(playerid, angle);

    new msg[64];
    format(msg, sizeof(msg), "Teleportado a ID %d (%.2f, %.2f, %.2f).", targetid, x, y, z);
    SendClientMessage(playerid, -1, msg);

    return 1;
}
