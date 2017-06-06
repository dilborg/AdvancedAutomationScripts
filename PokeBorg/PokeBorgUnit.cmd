@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
cls
TITLE = PokeBorg Bot Launcher
REM =========================================
REM  Email: dilborg@hotmail.com
REM  http://pokebot.ninja/thread-4859.html
REM =========================================
CALLPokeBorg-settings.cmd
REM Debug - `0 for debug
SET debug=1

REM TESTING parameter output
IF %debug%==1  GOTO DB1
ECHO:db && ECHO:db TESTING Parameters
ECHO:db Order: %1
ECHO:db Borg: %2
ECHO:db Matrix: %3
ECHO:db Drone: %4
ECHO:db UnitMode: %5
ECHO:db Activity: %6
ECHO:db lat: %7
ECHO:db lng: %8
PAUSE
:DB1

REM Find out if paramaters sent 
REM IF NO PARAMETERS . . .
    IF %1.==. GOTO No1

REM IF PARAMETER NOT COMPLETE . . . 
    IF %5.==. GOTO No6

REM Program activated with Parameter
REM Target Bot
	SET order=%1
    SET borg=%2
    SET matrix=%3
    SET drone=%4
REM Modes 0-Test 1-Farm 2-Snipe 3-Maintain 5-New 6-Battle
    SET unitMode=%5
	
REM Activity : ie gymstrat, activity_30
    SET Activity=%6

REM Home Coords
    SET lat=%7
    SET lng=%8

REM Initial Directory Assignment
for %%A in ("%~dp0\..") do SET "root_parent=%%~fA"
SET myPogoDir=%root_parent%\
SET collDir=%root_parent%\
REM Assign directories
SET myBorg=%fstOrder%-%borg%
SET myMatrix=%sndOrder%-%borg%%matrix%
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET borgDir=%collDir%%myBorg%
SET matrixDir=%borgDir%\%myMatrix%
SET droneDir=%matrixDir%\%myDrone%

IF %debug%==0 CALL :T3
IF %debug%==0 PAUSE

REM Localized TESTING
if not exist %droneDir% GOTO WHAT
if not exist %jarDir% GOTO WHAT

REM Localized Settings
SET droneJSON=%myDrone%.json
IF %debug%==0 ECHO:db     droneJSON %droneJSON%
IF %debug%==0 PAUSE
GOTO UML

:UML
Title = PokeBorg: Initiating %myDrone%-%myMatrix%  Ninja.Bot 
REM if %mode%==Snipe check JSON for sniping setting
REM if %mode%==Farm check JSON for farm setting
CD %droneDir%
echo %cd%  Running %myDrone% 
echo Wait for automated killswitch . . . 
ECHO ................................... 
GOTO UM%unitMode%

:UM0
Title = PokeBorg: %myDrone%-%myMatrix% Unit Mode - Testing launcher
REM JSON TARGET OPTIONS
REM SET sniping JSON file Drone-XXXSnipe.json
SET configJSON=%droneJSON%

CALL :TLOCAL
PAUSE

IF NOT EXIST %configJSON% GOTO NOJSON

REM TESTING

REM if %unitMode%==Snipe - add coords
java -jar %jarDir%\PokeBotNinja.jar -config %configJSON% %lat% %log%

REM java -jar %jarDir%PokeBotNinja.jar -config %configJSON% %lat% %log%

REM if %mode%==Test exit with PAUSE
PAUSE
EXIT

:UM1
Title = %myDrone%-%myMatrix%  Ninja.Bot Running 
REM Unit Mode - Regular Farm Activity
SET configJSON=ninja.json
IF NOT EXIST %configJSON% GOTO NOJSON

java -jar %jarDir%\PokeBotNinja.jar -config %configJSON%

REM TODO - stream output to Log file and remove pause
REM TODO Add CSV entry for last run

REM if %mode%==Farm exit with PAUSE
PAUSE
EXIT

:UM2
REM Unit Mode - Sniping Activity
Title = %myDrone%-%myMatrix%  Ninja Bot Sniper 
SET configJSON=%myDrone%%activity%.json
IF %debug%==0 ECHO:db     End of PBSettings.cmdECHO %configJSON%
IF %debug%==0 PAUSE
IF NOT EXIST %configJSON% GOTO NOJSON

REM java -jar %jarDir%PokeBotNinja.jar -config %configJSON% -lat %lat% -lng %lng%
java -jar %jarDir%\PokeBotNinja.jar -config %configJSON%

REM if %mode%==Snipe exit no PAUSE
PAUSE
EXIT

:UM6
REM Unit Mode - Gym Activity
Title = %myDrone%-%myMatrix%  Ninja Bot Gym 
SET configJSON=%myDrone%%activity%.json
IF %debug%==0 ECHO:db     End of PBSettings.cmdECHO %configJSON%
IF %debug%==0 PAUSE
IF NOT EXIST %configJSON% GOTO NOJSON

java -jar %jarDir%\PokeBotNinja.jar -config %configJSON%

REM if %mode%==GYM exit with PAUSE
PAUSE
EXIT

REM END of activities
GOTO EOF

:NOJSON
REM TODO create or search if its missing
ECHO: ERROR: File %configJSON% file does not exist.
GOTO WHAT

:NONAME
REM TODO create or search if its missing
ECHO: ERROR: Username missing from JSON.
GOTO WHAT

:WHAT
COLOR 74
ECHO: *************************************
ECHO: ****  BIOTECHNILOGICAL ERROR ********
ECHO: *************************************
ECHO: 
ECHO: An error in communication has occured.
ECHO: Press any key for system diagnostics. 
PAUSE 
ECHO: Error details . . .
CALL :TSTART
ECHO: Fix the communication array and come back: 
PAUSE
EXIT

:No1
    ECHO This program is not intended to be run alone.
    ECHO Use the options in the main PokeBorg program  
    ECHO to create new directories. 
    ECHO Would you like to launch PokeBorg?
    ECHO 
    choice /C YN /M "Enter Y to be assimilated or N to run and hide:"
    IF %ERRORLEVEL%==1 GOTO LAUNCH
    IF %ERRORLEVEL%==2 EXIT

:LAUNCH
    ECHO A new Command window will appear
    ECHO Please wait . . . 
    START cmd /c PokeBorg.cmd
    EXIT

:No6
ECHO:
ECHO: Parameters are missing.
GOTO WHAT

:TSTART
REM TESTING START Print test series
CALL :T2
CALL :T3
CALL :T4
CALL :TLOCAL
PAUSE
ECHO on
GOTO :eof

:T2
ECHO: && ECHO:ECHO TESTING Assignments
ECHO:db    *order   : %order%
ECHO:db     iOrder  : %iOrder%
ECHO:db     myOrder : %myOrder%
ECHO:db    *borg    : %borg%
ECHO:db     iBorg   : %iBorg%
ECHO:db     myBorg  : %myBorg%
ECHO:db    *matrix  : %matrix%
ECHO:db     iMatrix : %iMatrix%
ECHO:db     myMatrix : %myMatrix%
ECHO:db    *drone   : %drone%
ECHO:db     iDrone  : %iDrone%
ECHO:db     myDrone : %myDrone%
GOTO :eof

:T3
ECHO: && ECHO:TESTING Directories
ECHO:db     Pogo       : %myPogoDir%
ECHO:db     Collective : %collDir%
ECHO:db     Borg       : %borgDir%
ECHO:db     Matrix     : %matrixDir%
ECHO:db     Drone      : %droneDir%
ECHO:db     PokeBot    : %pbDir%
ECHO:db     PBN-Jar    : %jarDir%
ECHO:db     PBN-JSON   : %jsnDir%
GOTO :eof

:T4
ECHO: && ECHO:TESTING Auto Values
ECHO:db     %%~0     =      %~0 
ECHO:db     %%~1     =      %~1
ECHO:db     %%~f1     =      %~f0
ECHO:db     %%~d1     =      %~d0
ECHO:db     %%~p0     =      %~p0
ECHO:db     %%~p1     =      %~p1
ECHO:db     %%~n1     =      %~n0
ECHO:db     %%~x1     =      %~x0
ECHO:db     %%~s1     =      %~s0
ECHO:db     %%~a1     =      %~a0
ECHO:db     %%~t1     =      %~t0
ECHO:db     %%~z1     =      %~z0
ECHO:db     %%~dp0     =      %~dp0
ECHO:db     %%~dp1     =      %~dp1
ECHO:db     %%~nx1     =      %~nx0
GOTO :eof

GOTO :eof

:TLOCAL
ECHO:db && ECHO:db TESTING Parameters
ECHO:db     unitMode %unitMode%
ECHO:db     lng %lng%
ECHO:db     lat %lat%
ECHO:db     configJSON %configJSON%
ECHO:db     droneJSON %droneJSON%
:TEND
REM TESTING END
ECHO OFF
ECHO:
ECHO Test/echo off done
PAUSE
GOTO :eof

:EOF