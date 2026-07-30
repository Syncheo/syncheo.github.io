@echo off
rem ==========================================================================
rem  Copyright (c) 2026 Syncheo SAS (www.Syncheo.tech)
rem
rem  Logiciel open source distribue sous licence MIT.
rem
rem  Permission est accordee, gracieusement, a toute personne obtenant une
rem  copie de ce logiciel et des fichiers associes, d'utiliser, copier,
rem  modifier, fusionner, publier, distribuer et/ou vendre des copies du
rem  logiciel, sous reserve de CONSERVER DANS TOUTES LES COPIES la presente
rem  notice de propriete et la presente clause de non-responsabilite.
rem
rem  LE LOGICIEL EST FOURNI "EN L'ETAT", SANS GARANTIE D'AUCUNE SORTE, EXPRESSE
rem  OU IMPLICITE. EN AUCUN CAS SYNCHEO SAS NE POURRA ETRE TENUE RESPONSABLE
rem  DE TOUT DOMMAGE OU AUTRE RESPONSABILITE LIE A L'UTILISATION DU LOGICIEL.
rem ==========================================================================
setlocal
rem ==========================================================================
rem  change.bat - Lanceur de change.ps1
rem
rem  Contourne la restriction "l'execution de scripts est desactivee sur ce
rem  systeme" (ExecutionPolicy Restricted, y compris imposee par GPO) : le code
rem  de change.ps1 est charge comme TEXTE puis execute via un ScriptBlock.
rem  L'ExecutionPolicy ne controle que l'execution de FICHIERS .ps1 ; charger
rem  le contenu en memoire et l'executer n'y est pas soumis.
rem
rem  Usage :  change.bat "MonFichier.reqifz"
rem ==========================================================================

if "%~1"=="" (
    echo Usage: %~nx0 "MonFichier.reqifz"
    exit /b 1
)
if not exist "%~1" (
    echo ERREUR: fichier introuvable: "%~1"
    exit /b 1
)
if not exist "%~dp0change.ps1" (
    echo ERREUR: change.ps1 est introuvable a cote de change.bat
    exit /b 1
)

set "PS1=%~dp0change.ps1"
set "REQIFZ=%~f1"

powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create([System.IO.File]::ReadAllText($env:PS1))) -ReqifzFile $env:REQIFZ"

exit /b %errorlevel%
