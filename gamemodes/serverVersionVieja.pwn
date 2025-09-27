#include <a_samp>
#include <Dini>
#include <time>
#include <a_vehicles>
#include <mSelection>
#include <streamer>
#include <zcmd>
#include <a_mysql>
#include <vSyncALS>
#include <vSyncYSI>
#include "../include/gl_common.inc"
#include <a_actor>
#define SSCANF_NO_NICE_FEATURES
#include <sscanf2>
#pragma tabsize 0
//#include <DOF2>
#include <file>

#if defined _zones_included
	#endinput
#endif
#define _zones_included
#pragma library samp

new MySQL:DB;
#define MySQL_host "127.0.0.1"
#define MySQL_user "root"
#define MySQL_password ""
#define MySQL_DB "dbserver"

#define NOMBRE_SERVIDOR "Ciudad Liberal Roleplay"
#define GAMEMODE_SERVER "Roleplay - Simulacion - Rol"
#define VERSION_SERVER   "1.0"
#define CANCION_INICIO_SERVIDOR "https://drive.google.com/uc?export=download&id=1W2hfiwlPYCu5sIwWPJ5LdoBxpOj3guH2"



#define COLOR_NEGRO "{000000}"
#define COLOR_GRIS_OSCURO "{505050}"
#define COLOR_BLANCO "{ffffff}"
#define COLOR_HUESO "{fdf5e6}"
#define COLOR_GRIS "{808080}"
#define COLOR_GRIS_CLARO "{c0c0c0}"
#define COLOR_ROJO "{ff0000}"
#define COLOR_CARMIN "{960018}"
#define COLOR_NARANJA "{ffa500}"
#define COLOR_CORAL "{ff7f50}"
#define COLOR_AMARILLO "{ffff00}"
#define COLOR_MOSTAZA "{ffdb58}"
#define COLOR_ROSA "{ffc0cb}"
#define COLOR_FUCSIA "{ff1493}"
#define COLOR_VERDE "{00ff00}"
#define COLOR_VERDE_OSCURO "{006400}"
#define COLOR_LIMA "{bfff00}"
#define COLOR_VERDE_CLARO "{90ee90}"
#define COLOR_AZUL "{0000ff}"
#define COLOR_AZUL_OSCURO "{00008b}"
#define COLOR_CELESTE "{87ceeb}"
#define COLOR_AZUL_CLARO "{add8e6}"
#define COLOR_CYAN "{00ffff}"
#define COLOR_TURQUESA_OSCURO "{00ced1}"
#define COLOR_TURQUESA "{40e0d0}"
#define COLOR_AGUAMARINA "{7fffd4}"
#define COLOR_VIOLETA "{8a2be2}"
#define COLOR_INDIGO "{4b0082}"
#define COLOR_PURPURA "{800080}"
#define COLOR_MORADO_MEDIO "{9370db}"
#define COLOR_MARRON "{a52a2a}"
#define COLOR_CHOCOLATE "{d2691e}"
#define COLOR_DORADO "{ffd700}"
#define COLOR_BRONCE "{cd7f32}"

// Dialogos ID.
#define DIALOG_LOGIN 			1000 // Inicio de sesión
#define DIALOG_SIGNUP_1 		1001 // Selección de apariencia
#define DIALOG_SIGNUP_2 		1002 // Contraseña
#define DIALOG_SIGNUP_3 		1003 // Email

// Modo del usuario
#define MODE_NONE 		0 // Sin modo
#define MODE_LOBBY 		1 // Lobby
#define MODE_ROL 		2 // En juego
#define MODE_PAUSA 		3 // En pausa

enum uData {
	username[MAX_PLAYER_NAME],
	ip[15],
	sp[17], // Salt para la contraseña
	email[256],
	mode,
	intentosLogin

}
new user[MAX_PLAYERS][uData];

enum pData {
	gender,
	age,
	skin,
	numberphone,
	money,
	Float:x,Float:y,Float:z,Float:r,
	virtualWorld,
	Float:health,
	Float:armor,
	awaitingRevive
	
}

new player[MAX_PLAYERS][pData];

main() {
    printf("\n* Nombre del servidor: %s", NOMBRE_SERVIDOR);
    printf("* Versión %s", VERSION_SERVER);
    print("* Autor: Maximo Avila\n");
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	if(dialogid == DIALOG_LOGIN){
		if(response){
			new hash[144];
			SHA256_PassHash(inputtext, user[playerid][sp], hash, sizeof(hash));

			new DB_Query[146], Cache:ResultCache_;
			mysql_format(DB, DB_Query, sizeof(DB_Query), "SELECT * FROM accounts WHERE usuario='%s' AND password='%e' LIMIT 1",
                user[playerid][username], // usuario
                hash // contraseña encriptada
            );
            ResultCache_ = mysql_query(DB, DB_Query);
			if(cache_num_rows()){
				SendClientMessage(playerid, -1, "La contraseña es correcta, cargando tu cuenta...");

				user[playerid][mode] = MODE_ROL; // Cambiar a modo rol
			}else{
				if(user[playerid][intentosLogin] <= 1){
					SendClientMessage(playerid, -1, ""#COLOR_ROJO"Has fallado demasiados intentos de inicio de sesión, saliendo del servidor.");
					SetTimerEx("kickear", 100, false, "i", playerid);
					cache_delete(ResultCache_);
					return 1;
				}
				user[playerid][intentosLogin]--;
				new txt[144]; format(txt, sizeof(txt), ""#COLOR_AZUL_CLARO"Ingrese su contraseña para entrar al servidor:\n"#COLOR_NARANJA"%d"#COLOR_AZUL_CLARO" intentos restantes", user[playerid][intentosLogin]);
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""#COLOR_AZUL_CLARO"Inicio de sesión", txt, "Enviar", "Salir");
			}
			cache_delete(ResultCache_);
		}else{
			// El usuario ha cancelado el inicio de sesión
			SendClientMessage(playerid, -1, "Has cancelado el inicio de sesión, saliendo del servidor.");
			SetTimerEx("kickear", 100, false, "i", playerid);
		}
	}
	else if(dialogid == DIALOG_SIGNUP_1){
		if(response){
			if(listitem == 0){ // Masculino
				player[playerid][gender] = 0;
			}else if(listitem == 1){ // Femenino
				player[playerid][gender] = 1;
			}
			ShowPlayerDialog(playerid, DIALOG_SIGNUP_2, DIALOG_STYLE_INPUT, ""#COLOR_AZUL_CLARO"Registro de cuenta: Contraseña", "Cree su contraseña que va a usar para entrar al servidor:", "Listo", "Salir");
		}else{
			// El usuario ha cancelado el registro
			SendClientMessage(playerid, -1, "Has cancelado el registro de cuenta, saliendo del servidor.");
			SetTimerEx("kickear", 100, false, "i", playerid);
		}
	}
	else if(dialogid == DIALOG_SIGNUP_2){
		if(response){
			if(strlen(inputtext) < 4 || strlen(inputtext) > 16){
				SendClientMessage(playerid, -1, "La contraseña debe tener entre 4 y 16 caracteres.");
				ShowPlayerDialog(playerid, DIALOG_SIGNUP_2, DIALOG_STYLE_INPUT, ""#COLOR_AZUL_CLARO"Registro de cuenta: Contraseña", "Cree la contraseña que va a usar para entrar al servidor:", "Listo", "Salir");
				return 1;
			}

			new salt[17],hash[144];
			generateRandomSalt(salt, sizeof(salt));
			SHA256_PassHash(inputtext, salt, hash, sizeof(hash));


			new DB_Query[400];
			mysql_format(DB, DB_Query, sizeof(DB_Query), "INSERT INTO accounts (usuario, password, sp, ip, sexo) VALUES ('%s', '%s', '%s', '%s', %d)",
				user[playerid][username], // usuario
				hash, // contraseña
				salt, // salt
				user[playerid][ip], // ip
				player[playerid][gender] // sexo
			);
			mysql_pquery(DB, DB_Query);

			ShowPlayerDialog(playerid, DIALOG_SIGNUP_3, DIALOG_STYLE_INPUT, ""#COLOR_AZUL_CLARO"Registro de cuenta: Email", "Ingrese un email personal por motivos de seguridad:\n"#COLOR_BRONCE"Este paso es opcional, puede colocarlo más tarde.", "Finalizar", "Salir");
		}else{
			// El usuario ha cancelado el registro
			SendClientMessage(playerid, -1, "Has cancelado el registro de cuenta, saliendo del servidor.");
			SetTimerEx("kickear", 100, false, "i", playerid);
		}
	}
	else if(dialogid == DIALOG_SIGNUP_3){
		if(response){
			if(strlen(inputtext) > 0){
				new DB_Query[160];
				mysql_format(DB, DB_Query, sizeof(DB_Query), "UPDATE accounts SET email='%s' WHERE usuario='%s'",
					inputtext, user[playerid][username]
				);
				mysql_pquery(DB, DB_Query);

				format(user[playerid][email], 256, "%s", inputtext);
			}
		}else{
			SendClientMessage(playerid, -1, ""#COLOR_AMARILLO"No has ingresado un email, puedes colocarlo más tarde.");
		}
		new msjb[144];
		format(msjb, sizeof(msjb), "Cuenta registrada con éxito, bienvenido a "#COLOR_AGUAMARINA"%s"#COLOR_BLANCO", %s.", NOMBRE_SERVIDOR, user[playerid][username]);
		SendClientMessage(playerid, -1, msjb);
		player[playerid][x] = 823.9372;
		player[playerid][y] = -1361.9766;
		player[playerid][z] = -0.5078;
		player[playerid][r] = 316.0867;

		user[playerid][mode] = MODE_LOBBY; // Cambiar a modo lobby
	}
	return 1;
}


public OnGameModeInit()
{
	DB = mysql_connect(MySQL_host, MySQL_user, MySQL_password, MySQL_DB);

	if(DB == MYSQL_INVALID_HANDLE || mysql_errno(DB) != 0){ // error (https://youtu.be/SsWNRTmSu-I?t=1949)
		print("MySQL error: No se ha podido conectar a la base datos. Cierra la consola.");
		new error[144];
		mysql_error(error, sizeof(error));
		printf("\nMySQL: Error: %d,%s", mysql_errno(DB), error);
	}else{
		print("**** MySQL: Conexion establecida con éxito a la base de datos. ****");
	}

    UsePlayerPedAnims();
    ManualVehicleEngineAndLights();
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    LimitGlobalChatRadius(0);
	SetNameTagDrawDistance(20);
    SetGameModeText(GAMEMODE_SERVER);
    return 1;
}


public OnPlayerConnect(playerid){
	user[playerid][mode] = MODE_NONE; // Modo inicial del jugador.
	SetPlayerVirtualWorld(playerid, -1); // Vword -1 = lobby
	SetTimerEx("clearChat", 300, false, "i", playerid);
	GetPlayerName(playerid, user[playerid][username], MAX_PLAYER_NAME);
	GetPlayerIp(playerid, user[playerid][ip], 15);
	if(strfind(user[playerid][username], "_", false)!=-1){
		// El usuario tiene el formato correcto
	
		new DB_Query[146], Cache:ResultCache_;
		mysql_format(DB, DB_Query, sizeof(DB_Query), "SELECT * FROM accounts WHERE usuario='%s' LIMIT 1",
			user[playerid][username]
		);
		ResultCache_ = mysql_query(DB, DB_Query);
		new msjb[144];
		format(msjb, sizeof(msjb), "Conectado a "#COLOR_AGUAMARINA"%s.", NOMBRE_SERVIDOR);
		SendClientMessage(playerid, -1, msjb);
		if(cache_num_rows()){ // Si la cuenta existe entonces...
			user[playerid][intentosLogin] = 3; // Reiniciar intentos de login
			cache_get_value_name(0, "sp", user[playerid][sp], 17);
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""#COLOR_AZUL_CLARO"Inicio de sesión", ""#COLOR_AZUL_CLARO"Ingrese su contraseña para entrar al servidor:", "Enviar", "Salir");
		}else{ // Si la cuenta no existe entonces...
			ShowPlayerDialog(playerid, DIALOG_SIGNUP_1, DIALOG_STYLE_LIST, ""#COLOR_AZUL_CLARO"Registro de cuenta: Selección de apariencia", "Masculino\nFemenino", "Siguiente", "Salir");
		}
		cache_delete(ResultCache_);
		

	}else{
		// El usuario no tiene el formato correcto
		SendClientMessage(playerid, -1, "Tu usuario de "#COLOR_ROJO"SA-MP"#COLOR_BLANCO" debe ser con formato "#COLOR_AMARILLO"Nombre_Apellido"#COLOR_BLANCO" para ingresar al servidor.");
		SetTimerEx("kickear", 100, false, "i", playerid);
	}
	return 1;
}

public OnPlayerSpawn(playerid){
	if(user[playerid][mode] == MODE_NONE){
		// No completo el ingreso al servidor.
		SendClientMessage(playerid, -1, ""#COLOR_ROJO"Debes completar el ingreso al servidor para poder jugar.");
		SetTimerEx("kickear", 100, false, "i", playerid);
		return 1;
	}
	if(user[playerid][mode] == MODE_LOBBY){
		
		SetPlayerPos(playerid, player[playerid][x], player[playerid][y], player[playerid][z]);
		SetPlayerFacingAngle(playerid, player[playerid][r]);
		SetPlayerVirtualWorld(playerid, player[playerid][virtualWorld]);
		return 1;
	}
	return 1;
}

// Kickea al jugador

forward kickear(playerid);
public kickear(playerid){
	return Kick(playerid);
}

// Funciones de encriptación y desencriptación simples


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
