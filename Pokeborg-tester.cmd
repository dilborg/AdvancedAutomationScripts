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
CALL Pokeborg\PokeBorg-settings.cmd %debug%

REM Select Drones to Test
SET /a order=0
SET /a borg=2
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
REM New Settings

REM add new settings test here

REMSingle Gym launch
REM SET unitMode=6
REM SET activity=gymstrat
REM Target JSONs
REM SET targetJSON=%activity%.json

REM Function to test
GOTO PBCreate


:IMPORT
TITLE = PokeBorg CSV Import Function
IF %debug%==0 ECHO:db     Start of new GYM process

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=activity_00
REM Coordinates JSON File
SET coords=elpaso
REM Target JSON
REM SET targetJSON=%myDrone%%activity%.json
SET targetJSON=ninja.json

REM eventually want to autodetect the drone count start
REM iMatrix should = 30
IF %debug%==0 ECHO:db     iDrone : %iDrone%   (s/b 0)
IF %debug%==0 ECHO:db     iMatrix: %iMatrix%   (s/b 30)
IF %debug%==0 PAUSE

REM Launch unitMode set to Normal
SET unitMode=1

REM Create PBN3 and copy to directories
SET importFile=%ptcDir%\%order%%borg%%matrix%%drone%.CSV

SET newPBN3=%jsnDir%\PBN3droneXXX.json
REM SET dronePBN3=droneDir\PBN3myDrone.json - is set later

IF %debug%==0 CALL :TLOCAL

ECHO:
ECHO   Beginning CSV Import
ECHO:

REM Go through each line in the import file
FOR /F "tokens=1-2* delims=:" %%A IN (%importFile%) DO (
	Set user=%%A
	Set pass=%%B
	CALL :IMPORTREPL
 )

ECHO:
ECHO   Completed CSV Read
ECHO:
PAUSE

REM - Run merge
SET drone=0
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET droneDir=%matrixDir%\%myDrone%

REM CALL JSON FUNCTION
CALL ::NewJSON
ECHO END OF MERGE INSIDE IMPORT
PAUSE

GOTO :EOF

:IMPORTREPL
REM Begin the replace process for individual drone
SET drone=%iDrone%
IF %debug%==0 ECHO: && ECHO:db    drone: %drone%
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
IF %debug%==0 ECHO:db    myDrone: %myDrone%
SET droneDir=%matrixDir%\%myDrone%
IF %debug%==0 ECHO:db    matrixDir: %matrixDir%
IF %debug%==0 ECHO:db     iMatrix: %iMatrix%

REM Display the data extracted about to be used
ECHO:
ECHO Processing Account: %iDrone%
ECHO   username: "%user%"
ECHO   password: "%pass%"

FOR /F %%a IN ('POWERSHELL -COMMAND "$([guid]::NewGuid().ToString())"') DO ( SET NEWGUID=%%a )

REM The JSON file to be created
SET dronePBN3=%droneDir%\PBN3%myDrone%.json
SET dronePBNa=%droneDir%\PBN3%myDrone%1.json
SET dronePBNb=%droneDir%\PBN3%myDrone%2.json
IF %debug%==0 ECHO:db     dronePBN3: %dronePBN3%

REM Create new GUID
set NEWGUID=%NEWGUID:-=%
ECHO   New GUID: %NEWGUID%

REM - > CALL jsonREPL %search% %replace% /M /F %source% /O %target%

IF %debug%==0 ECHO:db     newPBN3  : %newPBN3%
IF %debug%==0 ECHO:db     dronePBN3: %dronePBN3%
REM IF %debug%==0 PAUSE

CALL jrepl.bat "\bPTCNAME\b" %%user%% /F %%newPBN3%% /O %%dronePBNa%%
CALL jrepl.bat "\PTCPASS\b" %%pass%% /F %%dronePBNa%% /O %%dronePBNb%%
CALL jrepl.bat "\GUID\b" %%NEWGUID%% /F %%dronePBNb%% /O %%dronePBN3%%

DEL %dronePBNa%
DEL %dronePBNb%

SET /a iDrone+=1

GOTO :EOF


:LAUNCHGYM
IF %debug%==0 ECHO:db     Begin GYM process - gymstrat activity selected
IF %debug%==0 PAUSE

REM Initiate Launch Variables for GYM
SET unitMode=6
SET activity=gymstrat

REM Target JSONs
SET targetJSON=%activity%.json

CALL :PRELAUNCH

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones

REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT


:PRELAUNCH
IF %debug%==0 ECHO:db     Begin PRELAUNCH process - display

REM Target JSONs
SET activityJSON=PBN4%activity%.json
SET locationJSON=PBN5%coords%.json

REM TODO TEST existance of TargetJSONs
REM This is a redundant test, but could ask here to create JSON
IF NOT EXIST %jsnDir%\%activityJSON% GOTO NOJSON
IF NOT EXIST %jsnDir%\%coordsJSON% GOTO NOJSON

IF %debug%==1 CLS
ECHO:
ECHO: PROCESS: PRE-LAUNCH
ECHO:
ECHO: About to Run %myMatrix% %trdOrder%s using:
ECHO:
ECHO:  - Activity: %activity%
ECHO:  - JSON    : %targetJSON%
ECHO:  - UnitMode: %unitMode%
ECHO:

IF %debug%==0 CALL :TLOCAL
ECHO: PRESS ANY KEY to confirm these settings . . .
PAUSE > NUL
ECHO:
ECHO: Please wait while drones are loaded . . .
GOTO :EOF


:LAUNCHSNIPER
IF %debug%==0 ECHO:db     Start of Sniper launch process
IF %debug%==0 PAUSE

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=sniper
REM SET targetJSON=%myDrone%%activity%.json
SET targetJSON=%activity%.json
REM Launch unitMode set to Gym
SET unitMode=2

SET lat=36.17785253
SET lng=-115.21675114

REM Modes 0-Test 1-Farm 2-Snipe 3-Maintain 5-New 6-Battle
SET unitMode=2


IF %debug%==0 CALL :TLOCAL
IF %debug%==0 PAUSE

ECHO:
ECHO: PROCESS: SNIPER LAUNCH
ECHO: About to Run %myMatrix% %trdOrder%s using:
ECHO:
ECHO:  - Activity: %activity%
ECHO:  - JSON    : %targetJSON%
ECHO:  - UnitMode: %unitMode%
ECHO:
IF %debug%==0 CALL :TLOCAL
IF %debug%==0 CALL :T4
PAUSE
ECHO: Please wait while drones are loaded

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT

:NewSNIPER
IF %debug%==0 ECHO:db     Start of new GYM process
IF %debug%==0 PAUSE

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=sniper
REM Coordinates JSON File
SET coords=vegas
REM Target JSON
REM SET targetJSON=%myDrone%%activity%.json
SET gymFile=%activity%.json
SET targetJSON=%gymFile%

SET lat=36.17785253
SET lng=-115.21675114

REM Launch unitMode set to Gym
SET unitMode=2

GOTO NS2

:NS0
IF %debug%==1 CLS
ECHO:
ECHO:         Updating user JSON is a 2 step proccess:
ECHO: Step 1 - Rewrite a new %targetJSON% with %activity% settings
ECHO: Step 2 - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NS2
CALL :NS0
ECHO: Step 1:
ECHO: About to Rewrite %targetJSON% for %myMatrix%
ECHO: Please wait while the rewrite functions completes
PAUSE
REM - rewrite JSONs
CALL :JSON10MERGE
REM completed the reconstructor

REM option to display each new JSON after creating it?
ECHO: && ECHO Completed the JSON update
ECHO Check the JSONs to ensure correctness before continuing to step 2
PAUSE
IF %debug%==0 CALL :TLOCAL
IF %debug%==0 CALL :T4
IF %debug%==0 PAUSE
GOTO NS3



:NS3
CALL :NS0
ECHO: Step 2:
ECHO: About to start Matrix %matrix% drones
ECHO: Please wait while drones are loaded

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT

:NewGYM
IF %debug%==0 ECHO:db     Start of new GYM process
IF %debug%==0 PAUSE

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=gymstrat
REM Coordinates JSON File
SET coords=gympink
REM Target JSON
REM SET targetJSON=%myDrone%%activity%.json
REM Done now in the loop

REM Launch unitMode set to Gym
SET unitMode=3

GOTO NG2

:NG0
IF %debug%==1 CLS
ECHO:
ECHO:         Updating user JSON is a three step proccess:
ECHO: Step 1 - Rewrite a new %myDrone%%targetJSON% with %activity% settings
ECHO: Step 2 - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NG2
CALL :NG0
ECHO: Step 1:
ECHO: About to Rewrite %targetJSON% for Matrix %matrix%
ECHO: Please wait while the rewrite functions completes
PAUSE
REM - rewrite JSONs
CALL :JSON10MERGE
REM completed the reconstructor

REM option to display each new JSON after creating it?
ECHO: && ECHO Completed the JSON update
ECHO Check the JSONs to ensure correctness before continuing to step 2
PAUSE
GOTO NG3

:NG3
CALL :NG0
ECHO: Step 2:
ECHO: About to start Matrix %matrix% drones
ECHO: Please wait while drones are loaded

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT


:NewJSON
REM Needs to have PNB3 updated recently
IF %debug%==0 ECHO:db     Start of new JSON process
IF %debug%==0 PAUSE

REM - need to accept Variables
REM Activity : 1
REM Coords   : 2
REM Test, etc

REM TargetJSON definition
REM HARD coded to ninja.json
REM SET targetJSON=%myDrone%%activity%.json

SET targetJSON=ninja.json

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=activity_00
REM Coordinates JSON File
SET coords=vegas

REM MATRIX-19 ottawa activity_25

REM Post UnitMore for test of NEW JSON file . . .
SET unitMode=1

GOTO NJ1

:NJ0
IF %debug%==1 CLS
ECHO:
ECHO:         Updating user JSON is a 2 step proccess:
ECHO: ReWrite - Create a new %targetJSON% with new settings
ECHO: Launch  - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NJ1
REM SHOULD DO TESTING OF PBN3 here - exist ? Most recent?
REM if test fail, call the process to extract PBN3 for matrix . . .
IF %debug%==0 CALL :TLOCAL
IF %debug%==0 CALL :T4
IF %debug%==0 PAUSE
GOTO NJ2

:NJ2
CALL :NJ0
ECHO:
ECHO: Step 1:
ECHO: About to Rewrite %targetJSON% for %myMatrix% using:
ECHO:  - PBN4 Activity JSON : %activity%
ECHO:  - PBN5 Coords JSON : %coords%
ECHO:

IF %debug%==0 CALL :TLOCAL

ECHO: PRESS ANY KEY to confirm these settings . . .
PAUSE > NUL
ECHO:
ECHO: Please wait while the rewrite functions completes

REM Rewrite JSONs
ECHO:  && ECHO: Creating new %targetJSON% JSON with Activity: %activity% Location: %coords% for %myMatrix% &&  ECHO:
set /a delay=%myDelay%*1
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %debug%==0 CALL :TSTEP
  CALL :JSONMERGE
  ECHO | set /p=Processing Drone : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)
REM completed the reconstructor

REM option to display each new JSON after creating it?
ECHO: && ECHO Completed the JSON update
ECHO Check the JSONs to ensure correctness before continuing to step 3
REM OPEN the Matrix directories
PAUSE
GOTO NJ3

:NJ3
CALL :NJ0
ECHO: Step 2:

CALL :PRELAUNCH

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT


:NewBOSS
IF %debug%==0 ECHO:db     Start of new BOSS key process
IF %debug%==0 PAUSE

REM Launch Notepad with JSNUser.json
REM Allow to edit
REM Test the new settings on a single account . . .

REM Decide which Matrix to work with
REM Loop - start with first matrix, roll through to end

REM Current hard coded to ninja.json
REM SET targetJSON=%myDrone%%activity%.json
SET targetJSON=ninja.json

REM - extract latest account
SET sections=Account
SET newSettings=blank

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=activity_33
REM Coordinates JSON File
SET coords=ottawa

SET unitMode=1

GOTO NB1

:NB0
IF %debug%==1 CLS
ECHO:
ECHO:         Updating user JSON is a three step proccess:
ECHO: Step 1 - Extract %sections% data from each %trdOrder% %targetJSON%
ECHO: Step 2 - Rewrite a new %targetJSON% with new settings
ECHO: Step 3 - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NB1
CALL :NB0
ECHO: Step 1:
ECHO: About to Extract current drone settings from %myMatrix%
ECHO: Please wait while the extraction function begin

IF %debug%==0 CALL :TLOCAL
IF %debug%==0 PAUSE

REM Call the extractor
CALL :JS10EXT

REM TODO - detect when last seen file is done writing
ECHO: && ECHO: WARNING *** WAIT FOR ALL WINDOWS TO CLOSE BEFORE PROCEEDING
PAUSE
GOTO NB2

:NB2
CALL :NB0
ECHO: Step 2:
ECHO: About to Rewrite %targetJSON% for %myMatrix%
ECHO: Please wait while the rewrite functions completes

REM - rewrite JSONs
CALL :JSON10MERGE
REM completed the reconstructor

REM option to display each new JSON after creating it?
ECHO: && ECHO Completed the JSON update
ECHO Check the JSONs to ensure correctness before continuing to step 3
PAUSE
GOTO NB3

:NB3
CALL :NB0
ECHO: Step 3:
ECHO: About to start %myMatrix% drones
ECHO: Please wait while drones are loaded

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT

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

:Poke10Unit
ECHO:  && ECHO: Starting %myMatrix% &&  ECHO:
set /a delay=%myDelay%*10
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %debug%==0 CALL :TSTEP
  CALL :PokeUnit
  ECHO | set /p=:   Processing %trdOrder% : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)
REM - TODO ask to cascade windows
GOTO :eof

:JSONMERGE
REM TESTING JSON File creator - merger
IF %debug%==0 ECHO:db     ECHO Creating new %targetJSON% JSON for %trdOrder%%order%%borg%%matrix%%drone%
IF %debug%==0 START cmd /k %pbDir%\jsonmerger.cmd %order% %borg% %matrix% %drone% %activity% %coords% %targetJSON%
IF %debug%==1 START cmd /c %pbDir%\jsonmerger.cmd %order% %borg% %matrix% %drone% %activity% %coords% %targetJSON%
GOTO :eof


:JSON10MERGE
REM TESTING JSON File creator - merger
ECHO:  && ECHO: Assimilating new %targetJSON% JSON with Activity: %activity% Location: %coords% for %myMatrix% &&  ECHO:
set /a delay=%myDelay%*1
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %debug%==0 CALL :TSTEP
  SET targetJSON=%trdOrder%-%borg%%matrix%%%A%activity%.json
  CALL :JSONMERGE
  ECHO | set /p=Processing Drone : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)
GOTO :eof

:JS10EXT
REM TESTING JSON Ninja.JSON - extracting bot data
REM PBN1 / PBN2 / PBN3-account PBN3-lastcheck/warning PBN3-Keep PBN-4 PBNSettings PBN-5 Path and location
ECHO:  && ECHO: Extracting %sections% data from %targetJSON% for %myMatrix% &&  ECHO:
set /a delay=%myDelay%*8
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %debug%==0 CALL :TSTEP
  REM Once the Ninja json is soft coded
  REM SET targetJSON=%trdOrder%-%borg%%matrix%%%A%activity%.json
  CALL :JSEXT
  ECHO | set /p=Processing Drone : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)
GOTO :eof

:JSEXT
REM TESTING JSON Ninja.JSON - extracting bot data
REM SET sections options Ninja(PBN1,PBN2), Account(PBN3abc), Seen(PBN3b,PBN3c), Config(PBN4), Path(PBN5), Display(run display)
IF %debug%==0 ECHO:db     ECHO Extracting %sections% data from %targetJSON% for %trdOrder%%order%%borg%%matrix%%drone%
IF %debug%==0 START cmd /k %pbDir%\jsonextract.cmd %order% %borg% %matrix% %drone% %targetJSON% %sections% %newSettings%
IF %debug%==1 START cmd /c %pbDir%\jsonextract.cmd %order% %borg% %matrix% %drone% %targetJSON% %sections% %newSettings%
GOTO :eof

REM Obsolete tests

:JSNUP
REM Testing extracting 10 borg matrix -> PBBorg.json and using it to create new Ninja.JSON
FOR /L %%A IN (0,1,9) DO (
  ECHO Extracting Ninja.JSON for %trdOrder%-%borg%%matrix%%%A
  START cmd /c %pbDir%jsonextract.cmd %order% %borg% %matrix% %%A
  TIMEOUT /T 3
  ECHO Creating new JSON for %trdOrder%-%borg%%matrix%%%A
  START cmd /c %pbDir%jsonmerger.cmd %order% %borg% %matrix% %%A %activity% %coords%
  TIMEOUT /T 5
 )
GOTO rerun

:PBCreate
REM Test Call to start Creator
START cmd /c %pbDir%\PBCreator.cmd %myOrder% %order% %fstOrder% %borg% %sndOrder% %matrix% %trdOrder% %drone%
GOTO rerun


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
