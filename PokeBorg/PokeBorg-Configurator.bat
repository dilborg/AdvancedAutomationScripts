@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0

:: =========================================
:: Name     : PokeBorg-Configurator.cmd
:: Purpose  : Install Pokeborg helper files and create PokeBorg directories
:: Location : InstallHome\PokeBorg\PokeBorg\PokeBorg-Configurator.cmd
:: Author   : Lou Langelier
:: Email    : dilborg@hotmail.com
:: https://github.com/dilborg/AdvancedAutomationScripts
:: =========================================
:: -- Version History --
:: Revision:01.100-beta     May 12 2017 - initial version 100 bot manager
::          02.101-beta     Jun 01 2017 - added support for CSV Import
SET version=02.102-beta&REM Jun 03 2017 - installation and configurations support

:passedVars
REM -- Determine assigned variables 

:init
REM.-- Set the window parameters
cls
color 9F
mode con: cols=100 lines=40
Title = PokeBorg Advanced Automation Configuration
SET "space= "

:initVars
REM -- Initialize local variables
SET "situation=%~n0"
REM SET DEBUG=0 here 
SET DEBUG=0
IF %debug%==0 ECHO:db     Debug mode activated - Debug: %debug%

:initPaths
REM -- Determine paths and directories 
REM - Local assignments
REM Paths have the \ at the end
for %%A in ("%~dp0\..") do SET "home_small=%%~sA"
for %%A in ("%~dp0") do SET "current_small=%%~sA"
SET batchPath=%current_small%
SET installPath=%home_small%\
REM - Global assignments
SET pbDir=%installPath%PokeBorg
SET logDir=%installPath%PBN-LOGS
SET downDir=%installPath%PBN-Versions
SET jarDir=%installPath%PBN-JAR
SET jsnDir=%installPath%PBN-JSONs
SET ptcDir=%installPath%PBN-PTC

:initFiles
REM -- Determine fileName variables
FOR %%k in (%0) do SET batchName=%%~nk
SET log=%batchname%.log
SET pbCONFIG=%pbDir%\Pokeborg.ini
:: TargetJSON to change later
SET targetJSON=ninja.json
SET PBN1-ninja=%jsnDir%\PBN1-ninjaBot.json
SET PBN2-user=%jsnDir%\PBN2-user.json
SET destCSV=%jsnDir%\PBN1ninja.csv
SET propKEY=%jsnDir%\PBN1ninja.key

:localChecks
:displayChecks
IF %debug%==0 ECHO:db     Start of Assimilator process 
IF %debug%==0 CALL :TLOCAL

:checkSINGULARITY
REM TODO Detect unzip success and run download if not there
REM - test if install log -> goto ERR NOINSTALL
REM - here the log file will be named PokeBorg-Assimilator.log
REM - the 
IF EXIST %LogPath%%log%  GOTO beginLogging
REM Option later to just have one file to download

:ConfigStart
ECHO.
ECHO.
ECHO.--------------------PokeBorg Configurator--------------------
ECHO.
ECHO: The PokeBorg Configurator creates the following:
ECHO.
ECHO.    PBN-1:ninjaBot.json - %PBN1-ninja%
ECHO.
ECHO.    PBN-2:userdata.json - %PBN2-user%
ECHO.
ECHO.    PBN-4:coords.json - %coordsJSON%
ECHO.
ECHO: You will need the following:
ECHO:      - A working ninja.json file with Radioactive or higher activation
ECHO:             * to obtain this visit: http://pokebot.ninja/thread-1831.html
ECHO:      - A working Bossland hashkey
ECHO:             * to obtain this visit: http://pokebot.ninja/buyhash.php
ECHO:      - A working Google Maps API key
ECHO:
ECHO: The Configurator only configures the Ninja information for using PokeBot.Ninja
ECHO: Configuring account data for PoGo accounts is done later through import of CSV
ECHO:
ECHO: To fine tune your JSONs you will need to edit the files in NotePad++
ECHO:
PAUSE

:Warning
IF %debug%==1 CLS
IF NOT EXIST "%PBN2-user%" GOTO menuCreate
color C
ECHO.
ECHO.
ECHO.--------------------PokeBorg Config Warning--------------------
ECHO.
ECHO.
ECHO.=============================================================================
ECHO.                                                                           
ECHO.           WARNING - Your existing %PBN1-ninja%, %PBN2-user% and              
ECHO.                                                                           
ECHO.                    %pbCONFIG% may be overwriten.                        
ECHO.                                                                           
ECHO.         Close this screen to abort or press any key to continue      
ECHO.                                                                           
ECHO.=============================================================================
ECHO.
PAUSE
ECHO.
color 9F
GOTO menuCreate

:menuCreate
IF %debug%==1 CLS
ECHO.
ECHO.
ECHO.--------------------PokeBorg Ninja/User JSON Creator--------------------
ECHO: 
ECHO. Step 1 - Extract Settings from existing JSON
ECHO: 
ECHO. Step 2 - Confirm extracted settings 
ECHO: 
ECHO. Step 3 - %PBN1-ninja% - write json 
ECHO.
ECHO. Step 4 - %PBN2-user%  - write json
ECHO.
ECHO: 
ECHO. These steps should be completed in order.
ECHO.
:_choice
SET _ok=
SET /p _ok= Make your choice or press Enter to close: ||goto:eof
IF "%_ok%" == "1" SET CHOICE=jsonpicker&GOTO jsonpicker
IF "%_ok%" == "2" SET CHOICE=confirmProperties&GOTO confirmProperties
IF "%_ok%" == "3" SET CHOICE=PBN1&GOTO PBN1
IF "%_ok%" == "4" SET CHOICE=PBN2&GOTO PBN2

GOTO :_choice 

:step1 :: -- Extract Settings from existing JSON
:jsonPicker
REM -- Ask to scan an existing JSON
IF %debug%==0 ECHO: -- Function:  jsonPicker
ECHO.
ECHO.
ECHO.--------------------PokeBorg ninja.json extractor--------------------
ECHO:
ECHO: Please select an existing JSON:
ECHO: 
CALL JSONChooser ninjaFound
IF %debug%==0 ECHO:db     ninjaFound=%ninjaFound%
REM TODO Parse the file directory name to short form
SET "targetJSON=%ninjaFound%"
IF %debug%==0 ECHO:db     targetJSON=%targetJSON%

:: Using sample JSON, extract to PBN1-ninja.csv
CALL :ninjaExtract
CALL :assignFromCSV
CALL :pbn1CSVSave
GOTO menuCreate

:assignFromCSV
:: Assign values based on CSV and clean up values
ECHO: Assign values from CSV
FOR /F "tokens=1-2 delims=:," %%A IN (%destCSV%) DO call :subAssignCSV %%A %%B
GOTO :eof

:subAssignCSV
	IF %debug%==0 ECHO:db     %1 , %2
	SET propA=%1
	SET propA=%propA: =%
	SET propA=%propA:"=%
	SET propB=%2
	SET propB=%propB: =%
	SET propB=%propB:"=%
	IF %debug%==0 ECHO:db      %propA% , %propB%
	SET v%propA%=%propB%
GOTO :EOF

:pbn1CSVSave
:: Rewrite the PBN1-ninja CSV with cleaner values
ECHO lang : %vlang% > %destCSV%
ECHO donator : %vdonator% >> %destCSV%
ECHO donatorcode : %vdonatorcode% >> %destCSV%
ECHO verify : %vverify% >> %destCSV%
ECHO hashLicense : %vhashLicense% >> %destCSV%
ECHO googleAPI : %vgoogleAPI% >> %destCSV%
GOTO :eof

:pbn1CSVErr
ECHO:
ECHO: Please complete the JSON extraction step before continuing
ECHO: 
PAUSE
GOTO PBN1

:step2 :: -- Confirm extracted settings 
:confirmProperties
:: -- Confirm extracted settings
::  Check for existing Ninja CSV extracted data
IF %vlang% NOT EQ "" GOTO displayProperties
IF %destCSV% NOT EXIST GOTO pbn1CSVErr
:: Vars are not in state, loading from saved CSV
CALL :assignFromCSV

:assignFromCSV


:displayProperties
IF %debug%==1 CLS
IF %debug%==0 ECHO:db   Using imported keys and values
IF %debug%==0 ECHO:db      vlang : %vlang%
IF %debug%==0 ECHO:db      vdonator : %vdonator%
IF %debug%==0 ECHO:db      vdonatorcode : %vdonatorcode%
IF %debug%==0 ECHO:db      vverify : %vverify%
IF %debug%==0 ECHO:db      vhashLicense : %vhashLicense%
IF %debug%==0 ECHO:db      vgoogleAPI : %vgoogleAPI%
ECHO.
ECHO.
ECHO.--------------------Confirm Ninja/User Settings--------------------
ECHO:
:vlang
ECHO:   Confirm language : %vlang%
SET /p newlang="Press ENTER to confirm this value or submit a new value: "||GOTO vdonator
SET vlang=%newlang%
IF %debug%==0 ECHO:db     vlang %vlang%

:vdonator
ECHO:   Confirm Ninja donator email : %vdonator%
SET /p newUser="Press ENTER to confirm this value or submit a new value: "||GOTO vdonatorcode
SET vdonator=%vdonator%
IF %debug%==0 ECHO:db     vdonator %vdonator%

:vdonatorcode
ECHO:   Confirm Ninja donator code : %vdonatorcode%
SET /p newDCode="Press ENTER to confirm this value or submit a new value: "||GOTO vverify
SET vdonatorcode=%newDCode%
IF %debug%==0 ECHO:db     vdonatorcode %vdonatorcode%

:vverify
ECHO:   Confirm Ninja donator code : %vverify%
SET /p newVerify="Press ENTER to confirm this value or submit a new value: "||GOTO vgoogleAPI
SET vverify=%newVerify%
IF %debug%==0 ECHO:db     vverify %vverify%

:vgoogleAPI
ECHO:   Confirm Google API : %vgoogleAPI%
SET /p newGoogle="Press ENTER to confirm this value or submit a new value: "||GOTO vhashLicense
SET vgoogleAPI=%newGoogle%
IF %debug%==0 ECHO:db     vgoogleAPI %vgoogleAPI%

:vhashLicense
ECHO:   Confirm Bossland hashing license : %vhashLicense%
SET /p newHash="Press ENTER to confirm this value or submit a new value: "||GOTO optionalSettings
SET vhashLicense=%newHash%
IF %debug%==0 ECHO:db     vhashLicense %vhashLicense%

:optionalSettings
ECHO.
ECHO.--------------------Optional additional Settings--------------------
ECHO:

:vRPM 
REM Key RPM? 150/500/1000
SET botMode=1
ECHO:   In order to know maximum botting limits,
ECHO:   Please confirm Bosslan Requests Per Minute (RPM):
ECHO:       1 -  150 RPM
ECHO:       2 -  500 RPM
ECHO:       3 - 1000 RPM
 choice /C 123 /M "Select your Bossland Key RPM:  "
 IF %ERRORLEVEL%==3 myDelay=3
 IF %ERRORLEVEL%==2 myDelay=2
 IF %ERRORLEVEL%==1 myDelay=1

:homeLocation
Vegas - Strip // 36.112665, -115.173216
SET vlat=36.112665
SET vlng=-115.173216
ECHO:   Confirm Home Location as Vegas : %vlat%, %vlng%
SET /p newLat="Press ENTER to confirm this value or submit a new latitude: "||GOTO vlng
SET vlat=%newLat%
IF %debug%==0 ECHO:db     vlat %vlat%
:vlng
SET /p newLng="Press ENTER to confirm this value or submit a new longitude: "||GOTO vsystem
SET vlng=%newLng%
IF %debug%==0 ECHO:db     vlng %vlng%

:vsystem
REM SSD
SET myDelay=1
ECHO:   In order to estimate file operation times,
ECHO:   Does your system have SSD or IDE drive ?
ECHO:       1 - Solid state drive
ECHO:       2 - Older IDE hard drive
 choice /C 12 /M "If you don't know, pick IDE: "
 IF %ERRORLEVEL%==2 myDelay=1
 IF %ERRORLEVEL%==1 myDelay=3
:: End of user interaction
:: Save the confirmed values
CALL :pbn1CSVSave
REM TODO - write the settings.ini
CALL :csvConfigSave
GOTO menuCreate

:csvConfigSave
:: Write new  pbCONFIG.ini file
ECHO Pokeborg.ini : PokeBorg Advanced Automation NinjaBotter > %pbCONFIG%
ECHO Version : %version% >> %pbCONFIG%
ECHO Windows : (FOR /F "tokens=*" %%W IN ('VER') DO ECHO %%W) >> %pbCONFIG%
ECHO Java : (FOR /F "tokens=*" %%J IN ('java -fullversion 2^>^&1') DO ECHO %%J) >> %pbCONFIG%
ECHO batchPath : %current_small% >> %pbCONFIG%
ECHO installPath : %home_small%\ >> %pbCONFIG%
ECHO myDelay : %myDelay% >> %pbCONFIG%
ECHO botMode : %botMode% >> %pbCONFIG%
ECHO myOrder : Collective >> %pbCONFIG%
ECHO fstOrder : Borg >> %pbCONFIG%
ECHO sndOrder : Matrix >> %pbCONFIG%
ECHO trdOrder : Drone >> %pbCONFIG%
ECHO homeLng : %vlng% >> %pbCONFIG%
ECHO homeLat : %vlat% >> %pbCONFIG%
ECHO cols : 100  >> %pbCONFIG%
ECHO lines : 40 >> %pbCONFIG%
ECHO colour : 9F >> %pbCONFIG%
ECHO menuCLR : 9F >> %pbCONFIG%
ECHO waitCLR : C >> %pbCONFIG%
GOTO :EOF

:step3 :: - PBN1-ninja - write json 
:PBN1
REM Check for setttings CSV
ECHO.
ECHO.
ECHO.--------------------PokeBorg PBN1-ninja.json creator--------------------
ECHO.
ECHO.
ECHO:{>%PBN1-ninja%
ECHO:    "lang": "%vlang%",>>%PBN1-ninja%
ECHO:>>%PBN1-ninja%
ECHO:  JSON Created:
ECHO:  %PBN1-ninja%
CALL :Display %PBN1-ninja% 
PAUSE
GOTO menuCreate

:step4 :: - PBN2-user - write json 
:PBN2
ECHO.
ECHO.
ECHO.--------------------PokeBorg PBN2-user.js creator--------------------
ECHO.
ECHO.
ECHO:{>%PBN2-user%
ECHO:  "donator": %vdonator%,>>%PBN2-user%
ECHO:  "donatorcode": %vdonatorcode%,>>%PBN2-user%
ECHO:  "verify": %vverify%,>>%PBN2-user%
ECHO:  "hashLicense": %vhashLicense%,>>%PBN2-user%
ECHO:  "audio": {>>%PBN2-user%
ECHO:    "robbed": false,>>%PBN2-user%
ECHO:    "pickup": false,>>%PBN2-user%
ECHO:    "throwing": false,>>%PBN2-user%
ECHO:    "caught": false,>>%PBN2-user%
ECHO:    "pokedex": false,>>%PBN2-user%
ECHO:    "missed": false,>>%PBN2-user%
ECHO:    "escaped": false,>>%PBN2-user%
ECHO:    "fled": false,>>%PBN2-user%
ECHO:    "evolved": false,>>%PBN2-user%
ECHO:    "transfered": false,>>%PBN2-user%
ECHO:    "powerup": false,>>%PBN2-user%
ECHO:    "struggle": true,>>%PBN2-user%
ECHO:    "hatched": false,>>%PBN2-user%
ECHO:    "levelup": true,>>%PBN2-user%
ECHO:    "badge": false,>>%PBN2-user%
ECHO:    "generic": true,>>%PBN2-user%
ECHO:    "bagfull": true,>>%PBN2-user%
ECHO:    "volume": 12>>%PBN2-user%
ECHO:  },>>%PBN2-user%
ECHO:  "minimizeToTray": false,>>%PBN2-user%
ECHO:>>%PBN2-user%
ECHO:  JSON Created:
ECHO:  %PBN2-user% 
CALL :Display %PBN2-user% 
PAUSE
GOTO EndPBN2Write

:EndPBN2Write
cls
ECHO.
ECHO.
ECHO. Your %PBN1-ninja% and %PBN2-user% have been made.
ECHO.
ECHO. and your %pbCONFIG% has been customized.
ECHO.
ECHO. You are ready to start the bot.
ECHO.
PAUSE
GOTO menuCreate

:ninjaExtract
REM Extracting Ninja key and user data 
SET raw_targetJSON=raw_targetJSON.json
SET testKEY="donator"
SET checkKeyResult=false
SET backupNinja=%jsnDir%\PBN2user-%DATE%_%myTime%.json

IF %debug%==0 ECHO:db     jsnDir : %jsnDir%
IF %debug%==0 ECHO:db     Backup file: %backupNinja%

IF EXIST %destCSV% ECHO:  Backup of %destCSV% 
IF EXIST %destCSV% copy %destCSV% %backupNinja%
IF EXIST %destCSV% ECHO:  Deleting old %destCSV% 
IF EXIST %destCSV% del %destCSV% 
IF EXIST %raw_targetJSON% del %raw_targetJSON%

REM CHECK to see if the JSON is valid
ECHO: Check for value %testKey% exists in JSON
find /i %testKey% %targetJSON% > nul
IF %ERRORLEVEL% equ 0 SET checkKeyResult=valid
ECHO checkKeyResult: %checkKeyResult%

ECHO:
ECHO:  Extracting Ninja settings from:
ECHO:     target: %targetJSON%
ECHO:     writing to: %destCSV%
ECHO:     using PropKey file: %PropKey%

for /f "tokens=*" %%P in (%propKey%) do (
	IF %debug%==0 ECHO:db     propKEY: %%P
	IF %%P == ENDBRACKET type %jsnDir%PBN8Bracket.json >> %raw_targetJSON%
	find /i %%P %targetJSON% >> %raw_targetJSON%
	
	)
IF %debug%==0 ECHO:db     PAUSE
IF %debug%==0 ECHO:db     Finished creating %raw_targetJSON%
CALL :SEARCHTEXT
CALL :SEARCHSPACE

REM complete the extraction
type %raw_targetJSON% > %destCSV%
ECHO: 
ECHO: Completed extraction of %sections% data from %targetJSON% to %destCSV%
ECHO:

IF %debug%==0 ECHO:db     Clean up the temporary file
del %raw_targetJSON% > nul
IF %debug%==0 ECHO:db     End of extract process
PAUSE
GOTO :EOF

:SEARCHTEXT
REM  Removing the search parameter the 1st time
IF %debug%==0 ECHO:db     Removing text from %raw_targetJSON%
CALL :SEARCHREPLACE
GOTO :EOF

:SEARCHSPACE
REM This is a bug fix unable to define empty space as variable
REM Run the 2nd time to remove spaces
IF %debug%==0 ECHO:db     Removing spaces from %raw_targetJSON%
CALL :SEARCHREPLACE
GOTO :EOF

:SEARCHREPLACE
REM TODO add variables
@ECHO off &setlocal
IF %debug%==0 ECHO:db     Search replace function for %raw_targetJSON%
set "search=---------- %targetJSON%"
set "replace="
set "textfile=%raw_targetJSON%"
set "newfile=temp_JSON"
(for /f "delims=*" %%i in (%textfile%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%search%=%replace%!"
    ECHO(!line!
    endlocal
))>"%newfile%"
del %textfile%
rename %newfile%  %textfile%
GOTO :EOF

REM Displaying a JSON
:Display
REM USE - CALL:Display %targetJSON%
IF %debug%==0 ECHO:db     Starting JSON Caller
IF %debug%==0 ECHO:db     Variable : %1
START cmd /k %pbDir%\PokeBorg-jsonDisplay.cmd %1%
IF %debug%==0 ECHO:db     ErrorLevel: %errorlevel%
IF %debug%==0 ECHO:db     End of display
IF %debug%==0 ECHO:db     PAUSE
GOTO :EOF

:TLOCAL
ECHO: && ECHO:TESTING Local Settings 
REM Local init
ECHO:db     Version     : %version%
ECHO:db     Current CMD : %situation%
ECHO:db     situation   : %situation%
ECHO:db     DEBUG       : %DEBUG%
REM Local Paths
ECHO:db     batchPath   : %batchPath%
ECHO:db     installPath : %installPath%
ECHO:db     installDir  : %installDir%  - depricated to installPath
ECHO:db     myPogoDir   : %myPogoDir% - depricated to installPath
ECHO:db     LogPath     : %LogPath%  - will be depricated to logDir
ECHO:db     logDir      : %logDir%
ECHO:db     downPath    : %downPath%
ECHO:db     jarDir      : %jarDir%
ECHO:db     jsnDir      : %jsnDir%
ECHO:db     ptcDir      : %ptcDir%
REM Local Filenames
ECHO:db     log         : %log%
ECHO:db     pbCONFIG    : %pbCONFIG%
GOTO :EOF

:eof
exit