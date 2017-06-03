@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
cls
TITLE = PokeBorg New Process Tester
REM =========================================
REM  Email: dilborg@hotmail.com
REM  http://pokebot.ninja/thread-4859.html
REM =========================================
REM Probably not a good idea to change these settings
REM Debug - 0 for debug
SET debug=1
CALL Pokeborg\PBsettings.cmd %debug%

REM Select Drones to Test
SET /a order=0
SET /a borg=0
SET /a matrix=0
SET /a drone=0

REM botModes 1-10 bots 2-100 bots 3-1000 bots
SET botMode=1

REM Delay is a Multiplier value 0-no delay, 1-3seconds
SET /a myDelay=1

REM Recreate Bot Structure
SET myOrder=Collective
SET fstOrder=Borg
SET sndOrder=Matrix
SET trdOrder=Drone
SET myBorg=%fstOrder%-%borg%
SET myMatrix=%sndOrder%-%borg%%matrix%
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET /a iDrone=%drone%
SET /a iMatrix=%matrix%*10+%iDrone%
SET /a iBorg=%borg%*100+%iMatrix%
SET /a iOrder=%order%*1000+%iBorg%
SET /a nMatrix=0

REM Rerun Directory Assignment
SET collDir=%myPogoDir%
SET borgDir=%collDir%\%myBorg%
SET matrixDir=%borgDir%\%myMatrix%
SET droneDir=%matrixDir%\%myDrone%

REM TESTS GO HERE
REM if not exist %borgDir% GOTO NEW
IF %debug%==0 CALL :TSTART
IF %debug%==1 CALL :TLOCAL
GOTO WORK

:WORK
REM New Settings go here



REM INSERT THE FUNCTION CALL HERE

REM Function to test
GOTO PropRpl




:PropRpl
REM PokeBorgUnit testing launching configs
REM Modes 1-Farm 2-Snipe 3-Maintain 4-Test 5-New 6-Battle
SET unitMode=2
SET activity=sniper
SET coords=coords
REM Testing properties replace
REM  "map": {
REM    "lng": 0.0,
REM    "lat": 0.0,
SET latKey="lat"
SET longKey="lng"
SET lat=45.469773
SET lng=-75.810588
SET snipeFile=%myDrone%Snipe.json
SET sniperFile=%myDrone%Sniper.json
REM Make a copy of sniper file -> use snipe for sniping
IF EXIST %droneDir%\%snipeFile% del %droneDir%\%snipeFile%
copy %droneDir%\%sniperFile% %droneDir%\%snipeFile%

REM Test call for changing values in JSON
START cmd /c %pbDir%propertyReplace.cmd %latKey% %lat% %snipeFile% %droneDir%
  TIMEOUT /T 5
START cmd /c %pbDir%propertyReplace.cmd %longKey% %long% %snipeFile% %droneDir%
  PAUSE
START cmd /c %pbDir%\PokeBorgUnit.cmd %borg% %matrix% %drone% %unitMode%
GOTO rerun
EXIT

:PokeUnit
REM Test Bot launcher
REM add /MIN
REM add echo to a file .
IF %debug%==0 ECHO:db     ECHO Starting bot %trdOrder%%order%%borg%%matrix%%drone%
IF %debug%==0 START cmd /k %pbDir%\PokeBorgUnit.cmd %order% %borg% %matrix% %drone% %unitMode% %activity% %lat% %lng%
IF %debug%==1 START /min cmd /c %pbDir%\PokeBorgUnit.cmd %order% %borg% %matrix% %drone% %unitMode% %activity% %lat% %lng%
GOTO :eof



:RERUN
ECHO: End of test sequence, run again?
PAUSE
GOTO WORK

REM END of activities
GOTO EOF

:NOJSON
REM TODO create or search if its missing
ECHO: ERROR: File %targetJSON% file does not exist.
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
    ECHO:This program is not intended to be run alone.
    ECHO:Use the options in the main PokeBorg program
    ECHO:to create new directories.
    ECHO:Would you like to launch PokeBorg?
    ECHO:
    choice /C YN /M "Enter Y to be assimilated or N to run and hide:"
    IF %ERRORLEVEL%==1 GOTO LAUNCH
    IF %ERRORLEVEL%==2 EXIT

:LAUNCH
    ECHO:A new Command window will appear
    ECHO:Please wait . . .
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
choice /C YN /M "Turn ECHO on?"
IF %ERRORLEVEL%==1 ECHO ON
goto :eof

:T1
ECHO: && ECHO:TESTING Parameter and Escape Values
ECHO:db     %%~0   : %~0    -   %%~1   : %~1
ECHO:db     %%~f0  : %~f0   -   %%~f1  : %~f1
ECHO:db     %%~d0  : %~d0   -   %%~d1  : %~d1
ECHO:db     %%~p0  : %~p0   -   %%~p1  : %~p1
ECHO:db     %%~n0  : %~n0   -   %%~n1  : %~n1
ECHO:db     %%~x0  : %~x0   -   %%~x1  : %~x1
ECHO:db     %%~s0  : %~s0   -   %%~s1  : %~s1
ECHO:db     %%~a0  : %~a0   -   %%~a1  : %~a1
ECHO:db     %%~t0  : %~t0   -   %%~t1  : %~t1
ECHO:db     %%~z0  : %~z0   -   %%~z1  : %~z1
ECHO:db     %%~dp0 : %~dp0  -   %%~dp1 : %~dp1
ECHO:db     %%~dp1 : %~dp1  -   %%~dp1 : %~dp1
ECHO:db     %%~nx0 : %~nx0  -   %%~nx1 : %~nx1
ECHO:db     Parameter1: %1 : %%1 : "%1" : %%~1 : %~1 : %%~1
ECHO:db     Parameter2: %2
ECHO:db     Parameter3: %3
ECHO:db     Parameter4: %4
ECHO:db     Parameter5: %5
ECHO:db     Parameter6: %6
ECHO:db     Parameter7: %7
ECHO:db     Parameter8: %8
GOTO :eof

:T2
ECHO: && ECHO:ECHO TESTING Assignments
ECHO:db    *order   : %order% / iOrder  : %iOrder% / myOrder : %myOrder%
ECHO:db    *borg    : %borg% / iBorg   : %iBorg% / myBorg  : %myBorg%
ECHO:db    *matrix  : %matrix% / iMatrix : %iMatrix% / myMatrix : %myMatrix%
ECHO:db    *drone   : %drone% / iDrone  : %iDrone%  / myDrone : %myDrone%
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
ECHO:db     PBN-JSON   : %ptcDir%
GOTO :eof

:T4
ECHO: && ECHO:TESTING JSON file values
ECHO:db     currentJSON %currentJSON%
ECHO:db     droneJSON %droneJSON%
ECHO:db     targetJSON %targetJSON%
ECHO:db     destJSON %destJSON%
GOTO :eof

:TLOCAL
ECHO: && ECHO:TESTING Local Settings
REM Local drone setup
ECHO:db     myDrone : %myDrone%
ECHO:db     myDelay %myDelay%
ECHO:db     botMode %myDelay%
REM Local JSEXT settings
ECHO:db     Activity = %activity%
ECHO:db     CoordSet = %coords%
REM Local JSMERGE settings
ECHO:db     Sections %sections%
ECHO:db     newSettings %newSettings%
REM Local Drone launcher settings
ECHO:db     unitMode %unitMode%
ECHO:db     lng %lng%
ECHO:db     lat %lat%
GOTO :eof

:TSTEP
ECHO:db     drone : %order%-%borg%-%matrix%-%drone%
REM ECHO:db     Count : %%A
REM PAUSE
GOTO :eof

:TEND
REM TESTING END
ECHO OFF
ECHO:
ECHO Test/ECHO off done
PAUSE
GOTO :eof

:EOF
