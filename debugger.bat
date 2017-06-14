@ECHO off
CLS
%~d0
cd %~dp0
:: =========================================
:: Name     : PokeBorg-Assimilator.cmd
:: Purpose  : Install Pokeborg helper files and create PokeBorg directories
:: Location : InstallHome\PokeBorg-Assimilator.cmd
:: Author   : Lou Langelier
:: Email    : dilborg@hotmail.com
:: https://github.com/dilborg/AdvancedAutomationScripts
:: =========================================
:init
REM.-- Set the window parameters
SET cols=80
SET lines=30
:: Menu display settings
SET COL=%TAB%:
SET menuCLR=9F
SET waitCLR=C
SET colour=9F
:initDisplay
mode con: cols=%cols% lines=%lines%
COLOR %colour%
Title = PokeBorg Advanced Automation Debbuger
SET "space= "
SET "tab=	"

ECHO:
ECHO:	1 - Run PokeBorg Debbuger
ECHO:	2 - Run Assimilator Debbuger
CHOICE /C 12 /M "Select Debbuger:"
IF %ERRORLEVEL%==2 START /MAX cmd /k Assimilator.cmd 1 
IF %ERRORLEVEL%==1 START /MAX cmd /k PokeBorg.cmd 1 
exit/b