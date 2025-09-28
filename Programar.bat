@echo off
echo Iniciando espacio de trabajo SA-MP...

:: Abrir Visual Studio Code
start "" "C:\Users\avila\AppData\Local\Programs\Microsoft VS Code\Code.exe" "C:\proyectoSamp"

:: Abrir WAMP Server
start "" "C:\wamp64\wampmanager.exe"

:: Abrir carpeta completa del servidor SA-MP
start "" explorer "C:\proyectoSamp"

:: Abrir carpeta completa del GTA SAN ANDREAS
start "" explorer "D:\GTA San Andreas"

:: Abrir panel de phpMyAdmin
start "" "http://localhost/phpmyadmin"

:: Abrir chatgpt
start "" "https://chatgpt.com/"

exit