@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
Title = PokeBorg Advanced Automation NinjaBotter
:: =========================================
:: Name     : PokeBorg.cmd
:: Purpose  : Primary controller of Ninja bots
:: Location : InstallHome\PokeBorg.cmd
:: Author:   Lou Langelier
:: Email: dilborg@hotmail.com
:: https://github.com/dilborg/AdvancedAutomationScripts
:: =========================================
:: -- Version History --
:: Revision:01.100-beta     May 12 2017 - initial version 100 bot manager
::          02.101-beta     Jun 01 2017 - added support for CSV Import
SET version=02.102-beta&REM Jun 03 2017 - installation and configurations support

:passedVars
REM -- Determine assigned variables 
SET "debug=%1"
IF NOT DEFINED debug SET debug=0

:initVars
REM -- Initialize local variables
SET "situation=%~n0"

:debugMode  
:: Local debug dependent on global debug and parameters
SET "_debug=0"
:: SET _debug here 0-no 1-yes 2-log
IF %debug% EQU 1 ( CHOICE /C YN /M "Enable %situation% debug?" )
IF %ERRORLEVEL% EQU 1 SET "_debug=%debug%"
IF %_debug% EQU 1 ( ECHO: Debug mode activated - debug: %debug%  _debug: %_debug%   para1: %1 )
IF %_debug% EQU 1 ( CHOICE /C YN /M "Turn ECHO on?" )
IF %ERRORLEVEL% EQU 1 ECHO ON

:checkSettings
REM -- TEST for PB LOG directory detect First Run
IF NOT EXIST "PBN-LOGS" GOTO NOPOKEBORG 
REM TODO add a test for Configuration such as Pokeborg.ini
REM -- TEST for PB directory and settings
IF NOT EXIST "PokeBorg\PokeBorg-settings.cmd" GOTO NEWPOKEBORG

:initSettings
REM -- Initialize the persistent variables from the storage
CALL "PokeBorg\PokeBorg-settings.cmd"

:initMain
mode con: cols=%cols% lines=%lines%
COLOR %colour%

IF %_debug%==0 GOTO startBatch
:logbatch
(ECHO:
ECHO: DATE            : %DATE%, %TIME%
ECHO: Current CMD     : %situation%
ECHO: Current func    : logBatch
)>> "%log%" 
GOTO startBatch

:startBatch
IF %_debug%==1 CALL :T1 >> %log% 2>&1
IF %_debug%==1 CALL :TSTART >> %log% 2>&1

REM -- TEST if Borg is created and ask to create if needed
IF NOT EXIST %borgDir% GOTO NOBORG

REM -- Test for Mode 1-10 2-100 3-1000 
IF botMode==1 DO (
	CALL :STBORG 0
	GOTO PBN 
REM if botMode==2 SET Borg0 matrix 0 GOTO Matrix
REM if botMode==3 SET Borg0 GOTO Borg
REM if botMode==0 GOTO what

:PBN
REM -- Main Menu Display
IF %_debug%==1 ECHO: --Current func    : PBN >> %log% 
Title = PokeBorg %myMatrix% Command Console
CLS
color %colour%
ECHO:
ECHO: Working Dir: %matrixDir%
ECHO: +============== PokeBorg Advanced Automation NinjaBotter ==============+
ECHO: +-------------------------- COMMAND CONSOLE ---------------------------+
ECHO: :                          %fstOrder%-%borg% Loaded%TAB%%TAB%%TAB%%COL%
ECHO: :                   %myMatrix% ready to receive commands %TAB%%COL%
ECHO: +----------------------------------------------------------------------+
REM ECHO: :1%TAB%2%TAB%3%TAB%4%TAB%5%TAB%6%TAB%7%TAB%8%TAB%%COL%
REM ECHO: 1234567:9112345:7892123:5678931:3456789:1234567:9512345:7896123:5678901:3456
REM ECHO: : %TAB%Option 1 %COL%  Option 2 %COL% Option 3 %COL% Option 4%COL%
ECHO: : %TAB%R - Initiate %myMatrix% %trdOrder% in Regular Farm Mode %TAB%%COL%
ECHO: : %TAB%G - Initiate %myMatrix% %trdOrder% to do Gym Battle %TAB%%TAB%%COL%
ECHO: : %TAB%S - Initiate %myMatrix% %trdOrder% for Sniper Mode %TAB%%TAB%%COL%
ECHO: : %TAB%O - Open Windows Explorer to this %sndOrder% %TAB%%TAB%%COL%
ECHO: : %TAB%J - JSON functions submenu (import, extract, merge)%TAB%%COL%
ECHO: +----------------------------------------------------------------------+
ECHO: : %TAB%C - Load/Create other %myOrder% %TAB%%TAB%%TAB%%COL%
ECHO: : %TAB%B - Load/Create other %fstOrder% %TAB%%TAB%%TAB%%TAB%%COL%
ECHO: : %TAB%M - Load/Create other %sndOrder% %TAB%%TAB%%TAB%%TAB%%COL%
ECHO: : %TAB%D - Single %trdOrder% operations %TAB%%TAB%%TAB%%TAB%%COL%
ECHO: +----------------------------------------------------------------------+
ECHO: : %TAB%P - Edit PokeBorg Settings %TAB%%TAB%%TAB%%TAB%%COL%
ECHO: : %TAB%X - Exit %TAB%%TAB%%TAB%%TAB%%TAB%%TAB%%COL%
ECHO: +========================== PRESS X TO EXIT ===========================+ 
CHOICE /C RGSOJCBMDPX /M " Enter your selection:"
SET C=%ERRORLEVEL%
IF %_debug%==1 ECHO:db     CC Selection: %C% >> %log% 
IF %C% == 11 EXIT
IF %C% == 10 GOTO mySettings
IF %C% == 9 GOTO DRONE
IF %C% == 8 GOTO MATRIX
IF %C% == 7 GOTO BORG
IF %C% == 6 GOTO COLL
IF %C% == 5 GOTO jsMenu
IF %C% == 4 GOTO D1
IF %C% == 3 GOTO launchSNIPER
IF %C% == 2 GOTO launchGYM
IF %C% == 1 GOTO Poke10Unit
EXIT

:D1
REM -- Open Directory to Matrix 
IF %_debug%==1 ECHO: --Current func    : D1 >> %log% 
REM Open directory at location of matrix
start %matrixDir%
GOTO PBN

:A1
REM -- Previous Matrix Drone Launcher
IF %_debug%==1 ECHO: --Current func    : A1 >> %log% 
Title = PokeBorg %myMatrix% Command Console
cls
Title = PokeBorg %myMatrix% Bot Initiation
:A1A
if not exist %matrixDir% GOTO NOMATRIX
cd %matrixDir%
ECHO Please wait until all %trdOrder% of %myMatrix% are initiated ...

REM if not exist %droneDir% GOTO NOBORG
REM 
REM if not exist ninja.json GOTO NEWDRONE

SET unitMode=1
FOR /L %%A IN (0,1,9) DO (
  ECHO Running %trdOrder%%order%%borg%%matrix%%%A
  START cmd /c %pbDir%\PokeBorgUnit.cmd %order% %borg% %matrix% %%A %unitMode% 
  TIMEOUT /T %myDelay%
)
cd %myPogoDir%
ECHO ......................................
ECHO . All %myMatrix% %trdOrder% are running! 
GOTO A2

:A2
REM Decision model based on FullAuto settings
SET /a nMatrix=%iMatrix%+10
REM Test end at 99, if end auto 
IF %nMatrix%==100 GOTO SE1

REM TESTING
REM ECHO Botmode %botMode%
REM Full auto decide Next or ask . . . A3 or A4
IF %botMode%==0 GOTO SE1
IF %botMode%==1 GOTO A3
IF %botMode%==2 GOTO A4

:A3
REM Sub end test for 10 botters
IF %nMatrix%==100 GOTO SE1

ECHO . Do you want to Run the next %sndOrder%?
ECHO ......................................
ECHO:
ECHO:  Y - Yes, run next %sndOrder%
ECHO:  N - No, go back to %myMatrix% menu.
ECHO:
choice /C YN /M "Close this window to quit:"
IF %ERRORLEVEL%==1 GOTO A4
IF %ERRORLEVEL%==2 GOTO PBN
EXIT

:A4
ECHO ......................................
SET /a iMatrix=%nMatrix%
SET /a matrix=%matrix%+1
SET myMatrix=%sndOrder%-%borg%%matrix%
SET matrixDir=%borgDir%\%myMatrix%
GOTO A1

:B1
REM -- Copy the JSON files from PokeBorg\JSON to each Drone Dir -- obsolete
IF %_debug%==1 ECHO: --Current func    : B1 >> %log% 
Title = PokeBorg %myMatrix% JSON Update
CLS
REM TODO rename this to JSON reset . . . like new JSON import
if not exist %matrixDir% GOTO NOMATRIX

For /f "tokens=1-2 delims=/:" %%a in ("%TIME: =0%") do (SET myTime=%%a%%b)
SET backupFilename=ninja-%DATE%_%myTime%.json

ECHO:
ECHO: Making a backup of your Ninja JSONs!
ECHO:
for /d %%a in (%matrixDir%\*) do (
    IF EXIST %%a\ninja.json (
        copy %%a\ninja.json %%a\%backupFilename% >> nul
        )
    )
ECHO: JSON Backup completed. 
ECHO:
ECHO: About to copy JSON files from JSON Source:
ECHO:     %jsnDir%
ECHO: To each %trdOrder% directory in:
ECHO:     %matrixDir%
ECHO:
for /d %%a in (%matrixDir%\*) do (
    xcopy /y %jsnDir%*.* %%a\ >>nul
    ECHO:  Successfully copied JSONs to %%a 
    )
ECHO:
ECHO: Finished updating %myMatrix% Ninja JSON files
ECHO: 
ECHO: Press any key to return to %myMatrix% options . . .
PAUSE
GOTO PBN

:C1
REM -- Copy the JAR files from PokeBorg\JAR to each Drone Dir -- obsolete
IF %_debug%==1 ECHO: --Current func    : C! >> %log% 
Title = PokeBorg %myMatrix% Ninja Update
CLS
if not exist %matrixDir% GOTO NOMATRIX
ECHO .....................................................
ECHO .           %sndOrder% Loaded :  %myMatrix%              
ECHO .  Are you certain you want to update Ninja Files?  
ECHO .....................................................
ECHO:
ECHO Y - Yes
ECHO N - No
ECHO:
choice /C YN /M "Enter Y to Continue or N to go back to the main menu:"
IF %M%==Y GOTO C2
IF %M%==N GOTO PBN

:C2
ECHO: 
ECHO: Copying Ninja.Bot files from %jarDir% to each %trdOrder%
ECHO:
for /d %%a in (%matrixDir%\*) do (
    ECHO:  Successfully copied JAR files to %%a 
    xcopy /y %jarDir%*.* %%a\ >>nul
    )
ECHO: 
ECHO: Finished updating %myMatrix% Ninja.Bot files 
ECHO:
ECHO Press any key to return to %myMatrix% options . . .
PAUSE
GOTO PBN

:IMPORT FROM CSV FUNCTION
:IMPORT
REM -- IMPORT CSV username/pass in a PBN3 file to each Drone Dir
IF %_debug%==1 ECHO: --Current func    : IMPORT >> %log% 
TITLE = PokeBorg CSV Import Function
CLS
ECHO:
ECHO   Beginning CSV Import
ECHO:

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=activity_00
REM Coordinates JSON File
SET coords=elpaso
REM Target JSON
REM SET targetJSON=%myDrone%%activity%.json
SET targetJSON=ninja.json

REM eventually want to autodetect the drone count start
IF %_debug%==1 ECHO:db     iDrone : %iDrone%   (s/b 0) >> %log%
IF %_debug%==1 ECHO:db     iMatrix: %iMatrix%   (s/b X0) >> %log%
IF %debug%==2 PAUSE

REM Post Launch: unitMode set to Normal
SET unitMode=1

REM Create PBN3 and copy to directories
SET importFile=%ptcDir%\%order%%borg%%matrix%%drone%.CSV
REM SET dronePBN3=droneDir\PBN3myDrone.json - is set againg later
SET newPBN3=%jsnDir%\PBN3droneXXX.json

IF %_debug%==1 ECHO:db     importFile: %importFile% >> %log% 
IF %_debug%==1 CALL :TLOCAL >> %log%

REM Go through each line in the import file
FOR /F "tokens=1-2* delims=:" %%A IN (%importFile%) DO (
	Set user=%%A
	Set pass=%%B
	CALL :IMPORTREPL
 )

ECHO:
ECHO:   Completed CSV Read
ECHO: Created Account JSON file for each %trdOrder%
ECHO: Proceeding to build the full ninja. json
ECHO:
PAUSE

REM eventually want to autodetect the drone count start
REM - Reset the drone count and Merge PBN1,2,3,4,5
SET iDrone=0
SET drone=0
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET droneDir=%matrixDir%\%myDrone%
IF %_debug%==1 ECHO:db     iDrone  : %iDrone% >> %log%

REM CALL JSON FUNCTION
CALL :NewJSON
ECHO End of Import Function: Returning to Command Console
PAUSE
GOTO PBN

:IMPORTREPL
IF %_debug%==1 ECHO: --     Start of IMPORTREPL process >> %log% 
REM Begin the replace process for individual drone
SET drone=%iDrone%
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET droneDir=%matrixDir%\%myDrone%
IF %_debug%==1 ECHO: && ECHO:db    drone: %drone% >> %log% 
IF %_debug%==1 ECHO:db    myDrone: %myDrone% >> %log% 
IF %_debug%==1 ECHO:db    matrixDir: %matrixDir% >> %log% 
IF %_debug%==1 ECHO:db     iDrone: %iDrone% >> %log% 

REM Display the extracted data about to be used
ECHO:
ECHO Processing Account: %iDrone%
ECHO   username: "%user%"
ECHO   password: "%pass%"

FOR /F %%a IN ('POWERSHELL -COMMAND "$([guid]::NewGuid().ToString())"') DO ( SET NEWGUID=%%a )

REM The JSON file to be created
SET dronePBN3=%droneDir%\PBN3%myDrone%.json
SET dronePBNa=%droneDir%\PBN3%myDrone%a.json
SET dronePBNb=%droneDir%\PBN3%myDrone%b.json

REM Create new GUID
set NEWGUID=%NEWGUID:-=%
ECHO   New GUID: %NEWGUID%
IF %_debug%==1 ECHO:db New GUID: %NEWGUID% - username: "%user%" - password: "%pass%" >> %log%

REM - > CALL jsonREPL %search% %replace% /M /F %source% /O %target%

IF %_debug%==1 ECHO:db     newPBN3  : %newPBN3% >> %log% 
IF %_debug%==1 ECHO:db     dronePBN3: %dronePBN3% >> %log% 
IF %_debug%==1 ECHO:db    dronePBN3a: %dronePBN3a% >> %log% 
IF %_debug%==1 ECHO:db    dronePBN3b: %dronePBN3b% >> %log% 
IF %debug%==2 PAUSE

CALL jrepl.bat "\bPTCNAME\b" %%user%% /F %%newPBN3%% /O %%dronePBNa%%
CALL jrepl.bat "\PTCPASS\b" %%pass%% /F %%dronePBNa%% /O %%dronePBNb%%
CALL jrepl.bat "\GUID\b" %%NEWGUID%% /F %%dronePBNb%% /O %%dronePBN3%%

DEL %dronePBNa%
DEL %dronePBNb%

SET /a iDrone+=1
IF %_debug%==1 ECHO:db     iDrone  : %iDrone% >> %log% 

GOTO :EOF

: DRONE UNIT LAUNCHER FUNCTIONS
:PRELAUNCH 
IF %_debug%==1 ECHO:db     Begin PRELAUNCH process >> %log% 

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

IF %_debug%==1 CALL :TLOCAL >> %log% 
ECHO: PRESS ANY KEY to confirm these settings . . .
PAUSE > NUL
ECHO:
ECHO: Please wait while drones are loaded . . .
GOTO :EOF

:PokeUnit
REM Test Bot launcher
REM add /MIN
REM add echo to a file .
IF %_debug%==1 ECHO:db     ECHO Starting bot %trdOrder%%order%%borg%%matrix%%drone% >> %log% 
IF %_debug%==1 START cmd /k %pbDir%\PokeBorgUnit.cmd %order% %borg% %matrix% %drone% %unitMode% %activity% %lat% %lng%
IF %debug%==1 START /min cmd /c %pbDir%\PokeBorgUnit.cmd %order% %borg% %matrix% %drone% %unitMode% %activity% %lat% %lng%
GOTO :eof

:Poke10Unit
ECHO:  && ECHO: Starting %myMatrix% &&  ECHO:
set /a delay=%myDelay%*10
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %_debug%==1 CALL :TSTEP
  CALL :PokeUnit
  ECHO | set /p=:   Processing %trdOrder% : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)
REM - TODO ask to cascade windows
GOTO :eof

:LAUNCHGYM
IF %_debug%==1 ECHO:db     Begin GYM process - gymstrat activity selected >> %log% 
IF %debug%==2 PAUSE

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

:LAUNCHSNIPER
IF %_debug%==1 ECHO:db     Start of Sniper launch process >> %log% 
IF %debug%==2 PAUSE

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


IF %_debug%==1 CALL :TLOCAL >> %log% 
IF %debug%==2 PAUSE

CALL :PRELAUNCH

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
REM go back to menu or run next matrix
PAUSE
GOTO rerun
EXIT

:: JSON HELPER FUNCTIONS

:: JSON EXTRACTION HELPERS
:JS10EXT
REM TESTING JSON Ninja.JSON - extracting bot data
REM PBN1 / PBN2 / PBN3-account PBN3-lastcheck/warning PBN3-Keep PBN-4 PBNSettings PBN-5 Path and location
ECHO:  && ECHO: Extracting %sections% data from %targetJSON% for %myMatrix% &&  ECHO:
set /a delay=%myDelay%*8
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %_debug%==1 CALL :TSTEP
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
IF %_debug%==1 ECHO:db     ECHO Extracting %sections% data from %targetJSON% for %trdOrder%%order%%borg%%matrix%%drone%
IF %_debug%==1 START cmd /k %pbDir%\jsonextract.cmd %order% %borg% %matrix% %drone% %targetJSON% %sections% %newSettings%
IF %debug%==1 START cmd /c %pbDir%\jsonextract.cmd %order% %borg% %matrix% %drone% %targetJSON% %sections% %newSettings%
GOTO :eof

: JSON MERGE FUNCTIONS
:JSONMERGE
REM TESTING JSON File creator - merger
IF %_debug%==1 ECHO:db     ECHO Creating new %targetJSON% JSON for %trdOrder%%order%%borg%%matrix%%drone%
IF %_debug%==1 START cmd /k %pbDir%\jsonmerger.cmd %order% %borg% %matrix% %drone% %activity% %coords% %targetJSON%
IF %debug%==1 START cmd /c %pbDir%\jsonmerger.cmd %order% %borg% %matrix% %drone% %activity% %coords% %targetJSON%
GOTO :eof


:JSON10MERGE
REM TESTING JSON File creator - merger
ECHO:  && ECHO: Assimilating new %targetJSON% JSON with Activity: %activity% Location: %coords% for %myMatrix% &&  ECHO:
set /a delay=%myDelay%*1
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %_debug%==1 CALL :TSTEP
  SET targetJSON=%trdOrder%-%borg%%matrix%%%A%activity%.json
  CALL :JSONMERGE
  ECHO | set /p=Processing Drone : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)
GOTO :eof

: JSON FULL EXTRACT - COMPILE - RUN

:NewUSER
IF %_debug%==1 ECHO:db     Start of new BOSS key process
IF %_debug%==1 PAUSE

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

IF %_debug%==1 CALL :TLOCAL
IF %_debug%==1 CALL :T4
IF %_debug%==1 PAUSE

CALL :NB0
CALL :extractHELPER
CALL :NB0
CALL :rewriteHELPER
CALL :NB0
CALL :launcherHELPER

REM END OF EXTRACT
ECHO: && ECHO Completed new user extract, rewrite and launch
REM go back to menu or run next matrix ?
PAUSE
GOTO PBN

:NB0
IF %debug%==1 CLS
ECHO:
ECHO:         Updating user JSON is a three step proccess:
ECHO: Extract - copy %sections% data from each %trdOrder% %targetJSON%
ECHO: ReWrite - Create a new %targetJSON% with new settings
ECHO: Launch  - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NewJSON
REM Needs to have PNB3 updated recently
IF %_debug%==1 ECHO: --     Start of new JSON process >> %log% 
IF %debug%==2 PAUSE

REM - need to accept Variables
REM Activity : 1
REM Coords   : 2
REM Test, etc

REM TargetJSON definition
REM HARD coded to ninja.json
REM COULD BE SET targetJSON=%myDrone%%activity%.json
SET targetJSON=ninja.json

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=activity_00
REM Coordinates JSON File
SET coords=vegas

REM MATRIX-19 ottawa activity_25

REM Post UnitMore for test of NEW JSON file . . .
SET unitMode=1

IF %_debug%==1 CALL :TLOCAL >> %log% 
IF %_debug%==1 CALL :T4 >> %log% 
IF %debug%==2 PAUSE

CALL :NJ0
IF %_debug%==1 ECHO: -- Calling reWriteHelper from NewJSON >> %log% 
CALL :rewriteHELPER
CALL :NJ0
IF %_debug%==1 ECHO: -- Calling launcherHelper from NewJSON >> %log% 
CALL :launcherHELPER

REM END OF new JSON
ECHO: && ECHO Completed JSON rewrite and launch
REM go back to menu or run next matrix ?
PAUSE
GOTO PBN

:NJ0
IF %debug%==1 CLS
ECHO:
ECHO:         Updating ninja JSON is a 2 step proccess:
ECHO: ReWrite - Create a new %targetJSON% with new settings
ECHO: Launch  - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NewGYM
IF %_debug%==1 ECHO:db     Start of new GYM process >> %log% 
IF %debug%==2 PAUSE

REM TODO - collect the current activity / location from CSV - confirm with user
SET activity=gymstrat
REM Coordinates JSON File
SET coords=gympink
REM Target JSON
SET targetJSON=%myDrone%%activity%.json
REM Done now in the loop

REM Launch unitMode set to Gym
SET unitMode=3

CALL :NG0
CALL :specwriteHELPER
CALL :NG0
CALL :launcherHELPER

REM END OF GYM
ECHO: && ECHO Completed GYM JSON rewrite and launch
REM go back to menu or run next matrix ?
PAUSE
GOTO PBN

:NG0
IF %debug%==1 CLS
ECHO:
ECHO:         Creating new GYM JSON is a two step proccess:
ECHO: ReWrite - Create a new %targetJSON% with new settings
ECHO: Launch  - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:NewSNIPER
IF %_debug%==1 ECHO:db     Start of new SNIPER process >> %log% 
IF %_debug%==1 PAUSE

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

CALL :NG0
CALL :specwriteHELPER
CALL :NG0
CALL :launcherHELPER

REM END OF EXTRACT
ECHO: && ECHO Completed JSON rewrite and launch
REM go back to menu or run next matrix ?
PAUSE
GOTO PBN

:NS0
IF %debug%==1 CLS
ECHO:
ECHO:         Creating Sniper JSON is a 2 step proccess:
ECHO: Step 1 - Rewrite a new %targetJSON% with %activity% settings
ECHO: Step 2 - Run each %trdOrder% to test and correct %targetJSON% order
ECHO:
GOTO :EOF

:specwriteHELPER
ECHO:
ECHO: Step : REWRITE
ECHO: About to Rewrite %targetJSON% for %myMatrix% using:
ECHO:  - PBN4 Activity JSON : %activity%
ECHO:  - PBN5 Coords JSON : %coords%
ECHO:

IF %_debug%==1 CALL :TLOCAL

ECHO: PRESS ANY KEY to confirm these settings . . .
PAUSE > NUL
ECHO:
ECHO: Please wait while the rewrite functions completes

REM - rewrite JSONs
CALL :JSON10MERGE
REM completed the reconstructor

ECHO: && ECHO Completed the JSON update
ECHO Check the JSONs to ensure correctness before continuing to launch
REM Open directory at location of matrix
start %matrixDir%
PAUSE
GOTO :EOF

:extractHELPER
ECHO: Step : EXTRACT
ECHO: About to copy current drone settings from %myMatrix%
ECHO: This process will update/create the Drone PNB3 JSON 
ECHO: PRESS ANY KEY to confirm these settings . . .
PAUSE > NUL
ECHO: Please wait while the extraction function begins

IF %_debug%==1 CALL :TLOCAL
IF %_debug%==1 PAUSE

REM Call the extractor
CALL :JS10EXT

REM TODO - detect when last seen file is done writing
ECHO: && ECHO: WARNING *** WAIT FOR ALL WINDOWS TO CLOSE BEFORE PROCEEDING
PAUSE
GOTO :EOF

:rewriteHELPER
ECHO:
ECHO: Step : REWRITE
ECHO: About to Rewrite %targetJSON% for %myMatrix% using:
ECHO:  - PBN4 Activity JSON : %activity%
ECHO:  - PBN5 Coords JSON : %coords%
ECHO:

IF %_debug%==1 CALL :TLOCAL

ECHO: PRESS ANY KEY to confirm these settings . . .
PAUSE > NUL
ECHO:
ECHO: Please wait while the rewrite functions completes

REM Rewrite JSONs
ECHO:  && ECHO: Creating new %targetJSON% JSON with Activity: %activity% Location: %coords% for %myMatrix% &&  ECHO:
set /a delay=%myDelay%*1
FOR /L %%A IN (0,1,9) DO (
  SET drone=%%A
  IF %_debug%==1 CALL :TSTEP
  CALL :JSONMERGE
  ECHO | set /p=Processing Drone : %order%-%borg%-%matrix%-%%A please wait . . .
  TIMEOUT /T %delay% > nul
  ECHO | set /p=Next!
  ECHO:
)

ECHO: && ECHO Completed the JSON update
ECHO Check the JSONs to ensure correctness before continuing to launch
REM Open directory at location of matrix
start %matrixDir%
PAUSE
GOTO :EOF

:launcherHELPERlauncherHELPER
CALL :NB0
ECHO: Step : Drone initiation - post merger
ECHO: Warning! Do not skip this step.  Running the drones fixes the order 
ECHO: of the keys and values in the JSON.  Running another extract if this
ECHO: is not done can reault in problems with extraction.
PAUSE > NUL
CALL :PRELAUNCH

CALL :Poke10Unit
ECHO: && ECHO Completed loading Drones
GOTO :EOF

:: MENU FUNCTIONS

:JSMENU
Title = PokeBorg JSON Function Selection
cls
color %colour%
ECHO:
ECHO: Working Dir: %matrixDir%
ECHO: +============== PokeBorg Advanced Automation NinjaBotter ==============+
ECHO: +--------------------------- JSON FUNCTIONS ---------------------------+
ECHO: :                          %fstOrder%-%borg% Loaded%TAB%%TAB%%TAB%%COL%
ECHO: :                   %myMatrix% ready to receive commands %TAB%%COL%
ECHO: +----------------------------------------------------------------------+
ECHO: : %TAB%Option 1 - Extract Account 'PBN3' data from ninja.json%TAB%%COL%
ECHO: : %TAB%Option 2 - Extract Activity data from JSON - new PBN4%TAB%%COL%
ECHO: : %TAB%Option 3 - Extract Path data from JSON - new PBN5%TAB%%COL%
ECHO: +----------------------------------------------------------------------+
ECHO: : %TAB%Option 4 - Search for JSONs in %myMatrix% sub-dirs %TAB%%COL%
ECHO: : %TAB%Option 5 - Edit PBN2 JSON in Notepad++ %TAB%%TAB%%TAB%%COL%
ECHO: : %TAB%Option 6 - Import JSON data from CSV %TAB%%TAB%%TAB%%COL%
ECHO: +----------------------------------------------------------------------+
ECHO: : %TAB%Option 7 - Update user.json ie-NewKEY %TAB%%TAB%%TAB%%COL%
ECHO: : %TAB%Option 8 - Build new GYM JSONs for %myMatrix% %TAB%%TAB%%COL%
ECHO: : %TAB%Option 9 - Build new Sniper JSONs for %myMatrix% %TAB%%COL%
ECHO: +========================= PRESS R TO RETURN ==========================+ 
REM TODO Option 10 Search Remplace specific term 
REM Back to Command Console
CHOICE /C 123456789R /M " Enter your selection:"
SET C=%ERRORLEVEL%
IF %C% == 10 GOTO PBN
IF %C% == 9 GOTO newSNIPER
IF %C% == 8 GOTO newGYM
IF %C% == 7 GOTO newUSER
IF %C% == 6 GOTO import
IF %C% == 5 GOTO editPBN2
IF %C% == 4 GOTO showJSON
IF %C% == 3 GOTO extractHELPER
IF %C% == 2 GOTO extractHELPER
IF %C% == 1 GOTO extractHELPER
GOTO PBN

:COLL
REM -- Order / Collection Selection Menu
IF %_debug%==1 ECHO: --Current func    : BORG >> %log% 
Title = PokeBorg %fstOrder% Selection
REM TODO Need to confirm the Collective and Borg assignments ie: order = '-' borg =0
REM TODO - clean up the selection menus and add - option to collective
ECHO: Eh, I haven't reached 1000 accounts yet. . . so stick with up to 999 bots
choice /C 1234567890 /M "Select the %Order% to load:"
SET O=%ERRORLEVEL%
IF %O%==10 GOTO O10
CALL :STCOLL %M%
:O10
IF %O%==10 CALL :STCOLL -
GOTO PBN

:BORG
REM -- Borg Selection Menu
IF %_debug%==1 ECHO: --Current func    : BORG >> %log% 
Title = PokeBorg %fstOrder% Selection
cls
color %pickCLR%
ECHO %myPogoDir%
ECHO                      PokeBorg Advanced Automation NinjaBotter  
ECHO ::::::::::::::::::::: PokeBorg %fstOrder%-%borg%00 - %borg%99  ::::::::::::::::::::::
ECHO ::                                                                  ::
ECHO ::                     %fstOrder% Unit Selection                          ::
ECHO ::                                                                  ::
ECHO ::      0 - Load/New %fstOrder%-0 (%trdOrder% 000-099)                         ::
ECHO ::      1 - Load/New %fstOrder%-1 (%trdOrder% 100-199)                         ::
ECHO ::      2 - Load/New %fstOrder%-2 (%trdOrder% 200-299)                         ::
ECHO ::      3 - Load/New %fstOrder%-3 (%trdOrder% 300-399)                         ::
ECHO ::      4 - Load/New %fstOrder%-4 (%trdOrder% 400-499)                         ::
ECHO ::      5 - Load/New %fstOrder%-5 (%trdOrder% 500-599)                         ::
ECHO ::      6 - Load/New %fstOrder%-6 (%trdOrder% 600-699)                         ::
ECHO ::      7 - Load/New %fstOrder%-7 (%trdOrder% 700-799)                         ::
ECHO ::      8 - Load/New %fstOrder%-8 (%trdOrder% 800-899)                         ::
ECHO ::      9 - Load/New %fstOrder%-9 (%trdOrder% 900-999)                         ::
ECHO ::                                                                  ::
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
choice /C 1234567890 /M "Select the %fstOrder% to load:"
SET B=%ERRORLEVEL%
IF %B%==10 GOTO B10
CALL :STBORG %B%
:B10
IF %B%==10 CALL :STBORG 0
GOTO PBN

:MATRIX
REM -- Borg Selection Menu
IF %_debug%==1 ECHO: --Current func    : MATRIX >> %log% 
Title = PokeBorg Matrix Selection
cls
color %pickCLR%
REM Detect Date of JSON
ECHO %borgDir%
ECHO                      PokeBorg Advanced Automation NinjaBotter  
ECHO ::::::::::::::::::::: PokeBorg %fstOrder%  %borg%00 - %borg%99  ::::::::::::::::::::::
ECHO ::                                                                  ::
ECHO ::                        %fstOrder%-%borg% Loaded                             ::
ECHO ::                  Select %sndOrder% from %fstOrder%-%borg%                       ::
ECHO ::                                                                  ::
ECHO ::      0 - Load %sndOrder%-%borg%0 (%trdOrder% %borg%00-%borg%09)                          ::
ECHO ::      1 - Load %sndOrder%-%borg%1 (%trdOrder% %borg%10-%borg%19)                          ::
ECHO ::      2 - Load %sndOrder%-%borg%2 (%trdOrder% %borg%20-%borg%29)                          ::
ECHO ::      3 - Load %sndOrder%-%borg%3 (%trdOrder% %borg%30-%borg%39)                          ::
ECHO ::      4 - Load %sndOrder%-%borg%4 (%trdOrder% %borg%40-%borg%49)                          ::
ECHO ::      5 - Load %sndOrder%-%borg%5 (%trdOrder% %borg%50-%borg%59)                          ::
ECHO ::      6 - Load %sndOrder%-%borg%6 (%trdOrder% %borg%60-%borg%69)                          ::
ECHO ::      7 - Load %sndOrder%-%borg%7 (%trdOrder% %borg%70-%borg%79)                          ::
ECHO ::      8 - Load %sndOrder%-%borg%8 (%trdOrder% %borg%80-%borg%89)                          ::
ECHO ::      9 - Load %sndOrder%-%borg%9 (%trdOrder% %borg%90-%borg%99)                          ::
ECHO ::                                                                  ::
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
choice /C 1234567890 /M "Select the %sndOrder% to load:"
SET M=%ERRORLEVEL%
IF %M%==10 GOTO M10
CALL :STMATRIX %M%
:M10
IF %M%==10 CALL :STMATRIX 0
GOTO PBN

:DRONE
REM -- Borg Selection Menu
IF %_debug%==1 ECHO: --Current func    : DRONE >> %log% 
Title = PokeBorg %sndOrder% Selection
cls
color %pickCLR%
ECHO %matrixDir%
ECHO                      PokeBorg Advanced Automation NinjaBotter  
ECHO ::::::::::::::::::::: PokeBorg %fstOrder%  %borg%%matrix%0 - %borg%%matrix%9  ::::::::::::::::::::::
ECHO ::                                                                  ::
ECHO ::                        %sndOrder%-%borg%%matrix% Loaded                             ::
ECHO ::                  Select %trdOrder% from %sndOrder%-%borg%%matrix%                       ::
ECHO ::                                                                  ::
ECHO ::      0 - Load/New %trdOrder%-%borg%%matrix%0                                                      ::
ECHO ::      1 - Load/New %trdOrder%-%borg%%matrix%1                                                      ::
ECHO ::      2 - Load/New %trdOrder%-%borg%%matrix%2                                                      ::
ECHO ::      3 - Load/New %trdOrder%-%borg%%matrix%3                                                      ::
ECHO ::      4 - Load/New %trdOrder%-%borg%%matrix%4                                                    ::
ECHO ::      5 - Load/New %trdOrder%-%borg%%matrix%5                                                     ::
ECHO ::      6 - Load/New %trdOrder%-%borg%%matrix%6                                                      ::
ECHO ::      7 - Load/New %trdOrder%-%borg%%matrix%7                                                      ::
ECHO ::      8 - Load/New %trdOrder%-%borg%%matrix%8                            ::
ECHO ::      9 - Load/New %trdOrder%-%borg%%matrix%9                            ::
ECHO ::                                                                  ::
ECHO ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
choice /C 1234567890 /M "Select the %trdOrder% to load:"
SET D=%ERRORLEVEL%
IF %D%==10 GOTO D10
CALL :STDRONE %D%
:D10
IF %D%==10 CALL :STDRONE 0
GOTO PBN

:: -------------------------------
:: POST SELECTION DRONE REASSIGNMENT
:: -------------------------------

:STCOLL
REM -- SET Collective AKA Order - should not be required for some time
IF %_debug%==1 ECHO: --Current func    : STCOLL - %1 >> %log% 
REM Need to set Order to '-' when less than 1k and then add a 0
REM then if bots exceeds 9999, switch to hexidecimal for 65k max
SET order=%1
SET myOrder=%fstOrder%-%borg%
SET /a iOrder=%borg%*100+%iMatrix%
REM COLL DIR remains the same -> Pogo 
CALL :STBORG 0
GOTO :EOF

:STBORG
REM -- SET Borg
IF %_debug%==1 ECHO: --Current func    : STBORG - %1 >> %log% 
SET borg=%1
SET myBorg=%fstOrder%-%borg%
SET /a iBorg=%borg%*100+%iMatrix%
SET borgDir=%collDir%\%myBorg%
if not exist %borgDir% GOTO NOBORG
CALL :STMATRIX 0
GOTO :EOF

:STMATRIX
REM -- SET Matrix
IF %_debug%==1 ECHO: --Current func    : STMATRIX - %1 >> %log% 
SET matrix=%1
SET myMatrix=%sndOrder%-%borg%%matrix%
SET /a iMatrix=%matrix%*10+%0%
SET matrixDir=%borgDir%\%myMatrix%
REM if not exist %matrixDir% GOTO NOMATRIX - this is a redundant directory test of BORG
CALL :STDRONE 0
GOTO :EOF

:STDRONE
REM -- SET Drone
IF %_debug%==1 ECHO: --Current func    : STDRONE - %1 >> %log% 
SET drone=%1
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET /a iDrone=%drone%
SET droneDir=%matrixDir%\%myDrone%
REM if not exist %droneDir% GOTO NODRONE - should really be testing for JSON 
GOTO :EOF

:: -------------------------------
:: POST SELECTION DRONE TESTS
:: -------------------------------

:NOPOKEBORG
REM --  Detected missing POKEBORG subdirectory or settings
ECHO: && ECHO: ERROR: Could not find the PokeBorg Settings
ECHO: There may be a problem with the unzip process
ECHO: Or perhaps the files are in a directory requiring permissions
ECHO: You may need to download again or extract the files to another location
GOTO NEWPOKEBORG

:NOBORG
REM -- Detected the BORG directory does not exist ask to create new Borg
IF %_debug%==1 ECHO: --Current func    : NOBORG - %myBorg% >> %log% 
ECHO: & ECHO: Selection: %myBorg% 
ECHO: & ECHO: Could not find directory - %myBorg%
ECHO: 
choice /C YN /M ": Do you want the directories created?"
IF %ERRORLEVEL%==2 GOTO PBN
IF %ERRORLEVEL%==1 GOTO NEWBORG
EXIT /B %ERRORLEVEL%

:NOMATRIX
REM --  Detected missing Matrix directory or empty Drone directory - need to import  
IF %_debug%==1 ECHO: --Current func    : NOMATRIX - %myMatrix% >> %log% 
REM Should be doing a test before operations on Matrix for JSONs, then ask to import
REM Before running operation - test each sub dire for JSON needed 
REM The MATRIX selected does not exist - should ask to IMPORT
ECHO That MATRIX selection does not exist.
GOTO NEWMATRIX

:NODRONE
REM -- Detected missing JSON: PBN3 or activity or ninja JSON is missing 
IF %_debug%==1 ECHO: --Current func    : NODRONE - %myDrone% >> %log% 
REM - if target JSON missing . . . to handle activity snipe and gym
REM - IF exist ninja - 
REM       - If detect PBN3 fails attempt to extract from ninja
REM - IF exist PBN3
REM        - If detect Ninja fails attempt to merge using PBN3
ECHO: 
ECHO: Selection: %myDrone% 
ECHO: Could not find JSON - %targetJSON%
choice /C YN /M "-Do you want the JSON created?"
IF %ERRORLEVEL%==2 GOTO PBN
IF %ERRORLEVEL%==1 GOTO NEWDRONE
EXIT /B %ERRORLEVEL%

:: -------------------------------
:: POST DRONE TESTS NEW MAKE REDIRECTS
:: -------------------------------

:NEWPOKEBORG
REM -- Function to call Assimilation function - detected missing LOGS
REM TODO create installer response function
ECHO: && ECHO: Could not find PokeBorg Program directories.
ECHO: 
choice /C YN /M ":     Would you like to install PokeBorg?"
IF %ERRORLEVEL%==2 GOIO EOF
IF %ERRORLEVEL%==1 ECHO Please wait . . . 
REM Close this window and launch the Assimilator
IF NOT EXIST PokeBorg-Assimilator.cmd CALL :getAssimilator
START cmd /c PokeBorg-Assimilator.cmd
EXIT /B %ERRORLEVEL% 

:getAssimilator
ECHO: 
ECHO:--------------------Downloading PokeBorg--------------------
ECHO: Please wait while PokeBorg is downloaded.
ECHO: 
curl -L https://github.com/dilborg/AdvancedAutomationScripts/raw/master/PokeBorg-Assimilator.cmd > PokeBorg-Assimilator.cmd
ECHO: The PokeBorg Program Installer was downloaded.
GOTO :EOF

:NEWBORG
REM -- Helper function which calls the BORG Directory Generator
IF %_debug%==1 ECHO: --Current func    : NEWPOKEBORG >> %log% 
ECHO: & ECHO:     BORG Directory Generator:
ECHO: & ECHO: This function will generate the following directories:
ECHO:   -- %myPogoDir%  %TAB%%TAB%- already exists
ECHO:     -- %myBorg%  %TAB%%TAB%%TAB%%TAB%%TAB%sub-directory
ECHO:       -- 10x %sndOrder% %TAB%%TAB%%TAB%subdirecties to %myBorg%
ECHO:         -- 10x %trdOrder% %TAB%%TAB%subdirecties to %sndOrder%
ECHO:
ECHO: A window will appear that will initiate the directory generator.
IF %_debug%==1 ECHO:db%TAB%myPogoDir%TAB%: %myPogoDir% >> %log%
IF %_debug%==1 ECHO:db%TAB%myBorg%TAB%: %myBorg%  >> %log%
PAUSE
START cmd /k %pbDir%\PokeBorg-Regenerator.cmd %myOrder% %order% %fstOrder% %borg% %sndOrder% %matrix% %trdOrder% %drone%
GOTO PBN

:NEWMATRIX
REM TODO test for actual first run of Matrix - ie if the Drone DIR is empty
REM create process for new MATRIX - ie copy starter JSON to DRONE dirs
ECHO NEW Matrix
ECHO For now sending you to JSON option
PAUSE
GOTO JSMENU

:NEWDRONE
REM TODO This is extremely experimental . . .
REM Possible function if user doesn't want to import
REM Likely need several copies of this for activity based detection
REM Also possible this could come up during batch processing - how to handle
ECHO: 
ECHO: The ninja.json doesn't exist.
ECHO: Copy Starter JSON to this directory?
REM Copy from Pogo/json to here, name it ninja.json
ECHO:
ECHO: About to copy JSON file from JSON Source:
ECHO:     %myPogoDir%PBN-JSONs
ECHO: To this directory:
ECHO:     %droneDir%
ECHO:     
ECHO:
xcopy /y %myPogoDir%PBN-JSONs\starter.json %droneDir%\ninja.json 
PAUSE
ECHO:  Successfully copied JSONs to %droneDir%
ECHO:
ECHO: Press any key to return to run again . . .
PAUSE
GOTO :EOF

REM END of activities
::-----------------------------------------------------------
:: helper functions follow below here
::-----------------------------------------------------------
:: ERROR RESPONSE FUNCTIONS
::-----------------------------------------------------------

:SE1
REM go back to menu or run next matrix ?
ECHO ......................................
ECHO . Do you want to run another script? .
ECHO ......................................
ECHO:
ECHO Y - Yes
ECHO N - No
ECHO:
choice /C YN /M "Enter Y to go back to the main menu or N to quit:"
IF %ERRORLEVEL%==1 GOTO PBN
IF %ERRORLEVEL%==2 exit

:WHAT
REM -- Error processing - error detected by interal testing
IF %_debug%==1 ECHO: --Current func    : WHAT >> %log% 
IF %_debug%==1 ECHO: --Previous Title  : %TITLE% >> %log% 
COLOR %waitCLR%
ECHO: *************************************
ECHO: ****  BIOTECHNILOGICAL ERROR ********
ECHO: *************************************
ECHO: 
ECHO: An error in communication has occured.
ECHO: 
choice /C YN /M "Display system diagnostics?"
IF %ERRORLEVEL%==1 GOTO DIAG
IF %ERRORLEVEL%==2 GOTO PBN

:DIAG
REM -- Diagnostics Display
IF %_debug%==1 ECHO: --Current func    : DIAG >> %log% 
ECHO:     Error details . . .
CALL :TSTART
IF %_debug%==1 CALL :START >> %log% 
ECHO: Fix the communication array and come back: 
choice /C YN /M "Enter Y to go back to the Command Console or N to quit:"
IF %ERRORLEVEL%==1 GOTO PBN
IF %ERRORLEVEL%==2 EXIT
EXIT

:: -------------------------------
:: TESTING HELPER FUNCTIONS
:: -------------------------------

:TSTART
REM TESTING START Print test series
CALL :T2
CALL :T3
CALL :T4
CALL :TLOCAL
IF %debug%==2 choice /C YN /M "Turn ECHO on?"
IF %debug%==2 IF %ERRORLEVEL%==1 ECHO ON
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
ECHO: & ECHO:TESTING Assignments
ECHO:db    *order   : %order% 	iOrder  : %iOrder% 	myOrder  : %myOrder%
ECHO:db    *borg    : %borg% 	iBorg   : %iBorg% 	myBorg   : %myBorg%
ECHO:db    *matrix  : %matrix% 	iMatrix : %iMatrix%	myMatrix : %myMatrix%
ECHO:db    *drone   : %drone% 	iDrone  : %iDrone% 	myDrone  : %myDrone%
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