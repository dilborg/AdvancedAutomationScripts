@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
cls
TITLE = PokeBorg JSON Assimilation
REM =========================================
REM  Email: dilborg@hotmail.com
REM  http://pokebot.ninja/thread-4859.html
REM =========================================
REM Probably not a good idea to change these settings
CALL PokeBorg-settings.cmd
REM Debug - `0 for debug
SET debug=1

REM TESTING parameter output
IF %debug%==1  GOTO DB1
ECHO:db && ECHO:db TESTING Parameters
ECHO:db Order: %1
ECHO:db Borg: %2
ECHO:db Matrix: %3
ECHO:db Drone: %4
ECHO:db Activity: %5
ECHO:db coords: %6
ECHO:db Target-JSON: %7
ECHO:db CoordSet: %8
PAUSE
:DB1

REM Find out if paramaters sent 
REM IF NO PARAMETERS . . .
    IF %1.==. GOTO No1

REM IF PARAMETER NOT COMPLETE . . . 
    IF %6.==. GOTO No6
	
REM Program activated with Parameter
    set order=%1
    set borg=%2
    set matrix=%3
    set drone=%4
	set activity=%5
	set coords=%6

REM Reassign directories after ID change
set myBorg=%fstOrder%-%borg%
set myMatrix=%sndOrder%-%borg%%matrix%
set myDrone=%trdOrder%-%borg%%matrix%%drone%
set /a iDrone=%drone%
set /a iMatrix=%matrix%*10+%iDrone%
set /a iBorg=%borg%*100+%iMatrix%
set /a iOrder=%order%*1000+%iBorg%
set /a nMatrix=0
set borgDir=%collDir%\%myBorg%
set matrixDir=%borgDir%\%myMatrix%
set droneDir=%matrixDir%\%myDrone%

REM Determine if a target is sent
IF %7.==. GOTO No7
SET targetJSON=%7
GOTO :JM0

:NO7
REM Need to create soft pointer to ninja.json, in the meantime hardcode it
SET targetJSON=ninja.json
GOTO :JM0

:JM0

TITLE = PokeBorg JSON Assimilation %myDrone%
IF %debug%==0 CALL :T3

REM Set local variables - json files
SET ninjaJSON=PBN1ninjaBot.json
SET userJSON=PBN2user.json
SET activityJSON=PBN4%5.json
SET coordsJSON=PBN5%6.json
SET droneJSON=%myDrone%.json
SET pbn3JSON=PBN3%droneJSON%
IF %debug%==0 CALL :TLOCAL

REM Local testing
IF NOT EXIST %jsnDir%\%userJSON% GOTO NOJSON
IF NOT EXIST %droneDir%\%pbn3JSON% GOTO NOPBN3
REM IF NOT EXIST %droneDir%\%targetJSON% GOTO NOTARGET

GOTO JM1

REM JSON Merger	
:JM1
ECHO: 
ECHO: Beginning JSON Merger
For /f "tokens=1-2 delims=/:" %%a in ("%TIME: =0%") do (set myTime=%%a%%b)
GOTO JM2

:JM2
REM Start here to loop the process on 10x drones in a Matrix
CD %droneDir%
ECHO:
ECHO: Assimilation process started for %droneJSON%
IF %debug%==0 ECHO:db     Working in directory: %CD% 
IF %debug%==0 ECHO:db     Using Source PBN3JSON: %pbn3JSON%, Activity:%activity%, Location: %coords%
IF %debug%==0 PAUSE 
GOTO JM4

:JM3
REM Sub-function of JM5
REM Create droneXXX.json file from Ninja.json
ECHO:
ECHO: Copying local %targetJSON% to %droneJSON%
IF EXIST %droneJSON% del %droneJSON%
copy %targetJSON% %droneJSON%
GOTO :EOF

:JM4
REM TODO if exist newer %targetJSON% - add newest Keep to PBN3drone010.json
REM Backup %targetJSON%
ECHO:
ECHO: Backing up %targetJSON% JSON
set backupNinja=%targetJSON%-%DATE%_%myTime%.json
IF %debug%==0 ECHO:db     Backup file: %backupNinja%
IF EXIST %targetJSON% copy %targetJSON% %backupNinja%
GOTO JM5

REM Build a new JSON
:JM5
REM Build a new JSON
ECHO:
ECHO: Building new %trdOrder% JSON: %targetJSON% for %myDrone%
ECHO:
type %jsnDir%\PBN1ninjaBot.json > %targetJSON%
ECHO Added Ninja Bot details from %jsnDir%\PBN1ninjaBot.json
type %jsnDir%\PBN2user.json >> %targetJSON%
ECHO Added User details from %jsnDir%PBN2user.json
REM Using PBN3 from local borg directory
type %pbn3JSON% >> %targetJSON%
ECHO Added Drone details from %droneDir%\%pbn3JSON%
type %jsnDir%\%activityJSON% >> %targetJSON%
ECHO Added Activity details from %jsnDir%%activityJSON% for %activity%
type %jsnDir%\%coordsJSON% >> %targetJSON%
ECHO Added path and coordinates for %coords% from %jsnDir%\%coordsJSON%
REM THIS is not needed if we softcode the jsons CALL :JM3
ECHO:
ECHO: Finished creating JSON: %targetJSON% in %droneDir%
ECHO:

REM END of activities
IF %debug%==0 CALL :Display PBN3%targetJSON%
IF %debug%==0 PAUSE
GOTO EOF

REM Displaying a JSON
:Display
REM USE - CALL:Display %targetJSON%
IF %debug%==0 ECHO:db     Starting JSON Caller
IF %debug%==0 ECHO:db     Variable : %1
SET FQJSON=%droneDir%\%1
IF %debug%==0 ECHO:db     PokeBorg Directory: %pbDir%
IF %debug%==0 ECHO:db     FullPathTarger: %FQJSON%
IF %debug%==0 PAUSE
START cmd /c %pbDir%\jsonDisplay.cmd %FQJSON%
IF %debug%==0 ECHO:db     ErrorLevel: %errorlevel%
IF %debug%==0 ECHO:db     End of display
IF %debug%==0 ECHO:db     PAUSE
GOTO :EOF

:No1
    ECHO This program is not intended to be run alone.
    ECHO Use the options in the main PokeBorg program  
    ECHO to create new directories. 
    ECHO Would you like to launch PokeBorg?
    ECHO 
    choice /C YN /M "Enter Y to be assimilated or N to run and hide:"
    IF %ERRORLEVEL%==1 GOTO LAUNCH
    IF %ERRORLEVEL%==2 GOTO DONE

:LAUNCH
    ECHO A new Command window will appear
    ECHO Please wait . . . 
    START cmd /c PokeBorg.cmd
    EXIT

:No6
ECHO: ERROR: Parameters are missing . . .
GOTO WHAT

:NOJSON
REM Hard error exit
ECHO: ERROR: Directory %jsnDir% does not exist. 
ECHO: ERROR: Directory %jsnDir% does not exist. %userJSON%
GOTO WHAT

:NOPBN3
REM TODO create using extract if its missing
ECHO: ERROR: File %pbn3JSON% file does not exist.
GOTO WHAT

:NOTARGET
REM TODO need to soft code ninja.json
ECHO: ERROR: File %targetJSON% file does not exist.
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
Pause
EXIT

:TSTART
REM TESTING START Print test series
CALL :T2
CALL :T3
CALL :T4
CALL :T5
PAUSE
ECHO on
goto :eof

:T1
ECHO: && ECHO TESTING Parameters
    ECHO Parameter1: %%1
    ECHO Parameter2: %2
    ECHO Parameter3: %3
    ECHO Parameter4: %4
    ECHO Parameter5: %5
    ECHO Parameter6: %6
    ECHO Parameter7: %7
    ECHO Parameter8: %8
GOTO :eof

:T2
ECHO: & ECHO:TESTING Assignments
ECHO:db    *order   : %order% 	/ iOrder  : %iOrder% 	/ myOrder  : %myOrder%
ECHO:db    *borg    : %borg% 	/ iBorg   : %iBorg% 	/ myBorg   : %myBorg%
ECHO:db    *matrix  : %matrix% 	/ iMatrix : %iMatrix% 	/ myMatrix : %myMatrix%
ECHO:db    *drone   : %drone% 	/ iDrone  : %iDrone% 	/ myDrone  : %myDrone%
GOTO :eof

:T3
ECHO: && ECHO TESTING Directories
ECHO Pogo       : %myPogoDir%
ECHO Collective : %collDir%
ECHO Borg       : %borgDir%
ECHO Matrix     : %matrixDir%
ECHO Drone      : %droneDir%
ECHO PokeBot    : %pbDir%
ECHO PBN-Jar    : %jarDir%
GOTO :eof

:T4
ECHO: && ECHO TESTING Auto Values
ECHO:%%~0     =      %~0 
ECHO:%%~1     =      %~1
ECHO:%%~f1     =      %~f0
ECHO:%%~d1     =      %~d0
ECHO:%%~p0     =      %~p0
ECHO:%%~p1     =      %~p1
ECHO:%%~n1     =      %~n0
ECHO:%%~x1     =      %~x0
ECHO:%%~s1     =      %~s0
ECHO:%%~a1     =      %~a0
ECHO:%%~t1     =      %~t0
ECHO:%%~z1     =      %~z0
ECHO:%%~dp0     =      %~dp0
ECHO:%%~dp1     =      %~dp1
ECHO:%%~nx1     =      %~nx0
GOTO :eof

:T5
ECHO: && ECHO TESTING JSON call values
ECHO:Activity = %activity%
ECHO:CoordSet = %coords%
GOTO :eof

:TLOCAL
ECHO ninjaJSON %ninjaJSON%
ECHO userJSON %userJSON%
ECHO activityJSON %activityJSON%
ECHO coordsJSON %coordsJSON%
ECHO droneJSON %droneJSON%
ECHO pbn3JSON %pbn3JSON%
ECHO targetJSON %targetJSON%
GOTO :eof

:TEND
REM TESTING END
ECHO OFF
ECHO:
ECHO Test/echo off done
PAUSE
GOTO :eof

:EOF