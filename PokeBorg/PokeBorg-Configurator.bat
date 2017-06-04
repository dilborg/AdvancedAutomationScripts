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
SET targetJSON=ninja.json
SET PBN1-ninja=%jsnDir%\PBN1-ninjaBot.json
SET PBN2-user=%jsnDir%\PBN2-user.json

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
IF NOT EXIST "%PBN1-ninja%" GOTO menuCreate
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
ECHO.                    %pbCONFIG% will be overwriten.                        
ECHO.                                                                           
ECHO.         Close this screen to abort or press any key to continue      
ECHO.                                                                           
ECHO.=============================================================================
ECHO.
PAUSE
ECHO.
color 9F
GOTO menuCreate

:jsonPicker
REM -- Ask to scan an existing JSON
IF %debug%==0 ECHO: -- Function:  jsonPicker
ECHO:
ECHO: Please select an existing JSON:
ECHO: 
CALL JSONChooser ninjaFound
IF %debug%==0 ECHO:db     ninjaFound=%ninjaFound%
REM TODO Parse the file directory name to short form
SET "targetJSON=%ninjaFound%"
IF %debug%==0 ECHO:db     targetJSON=%targetJSON%

CALL :ninjaExtract

REM assign values based on CSV

:assignCSV
ECHO: Assign values from CSV

FOR /F "tokens=1-2 delims=:," %%A IN (%destJSON%) DO call :subAssignCSV %%A %%B
GOTO menuCreate

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

:confirmProperties
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
SET /p newVerify="Press ENTER to confirm this value or submit a new value: "||GOTO vhashLicense
SET vverify=%newVerify%
IF %debug%==0 ECHO:db     vverify %vverify%

:vhashLicense
ECHO:   Confirm Bossland hashing license : %vhashLicense%
SET /p newHash="Press ENTER to confirm this value or submit a new value: "||GOTO vRPM
SET vhashLicense=%newHash%
IF %debug%==0 ECHO:db     vhashLicense %vhashLicense%

:vRPM 
REM Key RPM? 150/500/1000
SET vRPM=150
ECHO:   Confirm Bosslan Requests Per Minute : %vRPM%
SET /p newRPM="Press ENTER to confirm this value or submit a new value: "||GOTO vgoogleAPI
SET vRPM=%newRPM%
IF %debug%==0 ECHO:db     vRPM %vRPM%

:vgoogleAPI
ECHO:   Confirm Google API : %vgoogleAPI%
SET /p newGoogle="Press ENTER to confirm this value or submit a new value: "||GOTO homeLocation
SET vgoogleAPI=%newGoogle%
IF %debug%==0 ECHO:db     vgoogleAPI %vgoogleAPI%

:homeLocation
Vegas - Strip // 36.112665, -115.173216
SET vlat=36.112665
SET vlng=-115.173216
ECHO:   Confirm Home Location as Vegas : %vlat%, %vlng%
SET /p newLat="Press ENTER to confirm this value or submit a new latitude: "||GOTO vlat
SET vlat=%newLat%
IF %debug%==0 ECHO:db     vlat %vlat%
:vlng
SET /p newLng="Press ENTER to confirm this value or submit a new longitude: "||GOTO vsystem
SET vlng=%newLng%
IF %debug%==0 ECHO:db     vlng %vlng%

:vsystem
REM SSD
SET vDrive=SSD
SET myDelay=1
ECHO:   Does your system have SSD or IDE drive : %vDrive%
SET /p newDrive="Press ENTER to confirm this value or submit a new value: "||GOTO createNEWCSV
SET vDrive=%newDrive%
IF %debug%==0 ECHO:db     vDrive %vDrive%

:createNEWCSV
REM Write new csv 
SET pbCONFIG=%pbDir%\Pokeborg.ini
REM DIR
REM SET batchPath=%current_small%
REM SET installPath=%home_small%\

GOTO menuCreate

:menuCreate
IF %debug%==1 CLS
ECHO.
ECHO.
ECHO.--------------------PokeBorg Ninja/User JSON Creator--------------------
ECHO: 
ECHO. 1 - Extract Settings from existing JSON
ECHO: 
ECHO. 2 - Confirm settings 
ECHO: 
ECHO. 3 - %PBN1-ninja% - write json 
ECHO.
ECHO. 4 - %PBN2-user%  - write json
ECHO.
ECHO. 5 - %pbCONFIG% - write json
ECHO: 
ECHO. These steps should be completed in order.
ECHO.
:_choice
SET _ok=
SET /p _ok= Make your choice or press Enter to close: ||goto:eof
IF "%_ok%" == "3" SET CHOICE=PBN1-ninja&GOTO :PBN1-ninja
IF "%_ok%" == "4" SET CHOICE=PBN2-user&GOTO :PBN2-user
IF "%_ok%" == "5" SET CHOICE=Menu2&GOTO :Menu2
IF "%_ok%" == "2" SET CHOICE=confirmProperties&GOTO :confirmProperties
IF "%_ok%" == "1" SET CHOICE=jsonpicker&GOTO :jsonpicker
GOTO :_choice 

:PBN1-ninja
call:AuthMake %ninjaFound%
goto:Menu

:AuthMake


ECHO.
ECHO.
ECHO.--------------------PokeBorg PBN1-ninja.json creator--------------------
ECHO.
ECHO.
ECHO.{>%PBN1-ninja%


Set /p YOUR_USERNAME="What's your username ?: "
ECHO.    "username": "%YOUR_USERNAME%",>>%PBN1-ninja%
ECHO.
SET /p YOUR_PASSWORD="What's your password ?: "
ECHO.    "password": "%YOUR_PASSWORD%",>>%PBN1-ninja%
ECHO.
SET /p SOME_LOCATION="What's the location you want to search ?: "
ECHO.    "location": "%SOME_LOCATION%",>>%PBN1-ninja%
ECHO.
ECHO.    "favorite_locations":[>>%PBN1-ninja%
ECHO.
ECHO.Adding Favorite Locations....
ECHO.
call:morefav
ECHO.
ECHO.    ],>>%PBN1-ninja%
SET /p GOOGLE_API="What's your Google Maps API Key ?: "
ECHO.    "gmapkey": "%GOOGLE_API%",>>%PBN1-ninja%
ECHO.
SET /p hashkey="What's your Hashing Server Key ?: "
ECHO.    "hashkey": "%hashkey%",>>%PBN1-ninja%
ECHO.
ECHO.    "encrypt_location": "",>>%PBN1-ninja%
SET /p telegram="What's your telegram token? Enter for leave blank: "
ECHO.    "telegram_token": "%telegram%">>%PBN1-ninja%
ECHO.}>>%PBN1-ninja%
goto :eof


:morefav
ECHO.
SET /p _answer="Do you want to add a favorite location (Y/N)?: "
IF "%_answer%" == "y" goto :choice1
IF "%_answer%" == "n" goto :eof
:choice1
ECHO.
ECHO.
SET /p name="What City do you want to add ?: "
SET /p coords="What coordinates has that City ? (example: 45.472849,9.177567 ): "
ECHO.
ECHO.
:choice2
ECHO.
ECHO.
SET /p _answer2="Do you want to add more favorite locations (Y/N)?: "
IF "%_answer2%" == "y" ECHO.        {"name": "%name%", "coords": "%coords%"},>>%PBN1-ninja%&goto :favorite
IF "%_answer2%" == "n" ECHO.        {"name": "%name%", "coords": "%coords%"}>>%PBN1-ninja%&goto :eof
:favorite
SET _answer2=
SET name=
SET coords=
ECHO.
ECHO.
SET /p name="What City do you want to add ?: "
SET /p coords="What coordinates has that City ? (example: 45.472849,9.177567 ): "
goto:choice2

:PBN2-user
ECHO.
ECHO.
ECHO.--------------------PokeBorg PBN2-user.js creator--------------------
ECHO.
ECHO.
ECHO.// MUST CONFIGURE THE USER ARRAY AND GOOGLE MAPS API KEY.>%PBN2-user%
ECHO.// YOU CAN GET A KEY HERE: https://developers.google.com/maps/documentation/javascript/get-api-key>>%PBN2-user%
ECHO.var userInfo = {>>%PBN2-user%
Set /p users="What's the username to use ?: "
ECHO.	users: ["%users%"],>>%PBN2-user%
ECHO.	userZoom: true,>>%PBN2-user%
ECHO.	zoom: 16,>>%PBN2-user%
ECHO.	userFollow: true,>>%PBN2-user%
SET /p API="What's your Google Maps API Key ?: "
ECHO.	gMapsAPIKey: "%API%",>>%PBN2-user%
ECHO.	botPath: true,>>%PBN2-user%
ECHO.	actionsEnabled: false>>%PBN2-user%
ECHO.};>>%PBN2-user%
goto:menu

:Menu2
cls
ECHO.
ECHO.
ECHO.--------------------PokeBorg config.json chooser--------------------
ECHO.
ECHO. 
ECHO. 1 - config.json.example
ECHO.
ECHO. 2 - config.json.cluster.example
ECHO.
ECHO. 3 - config.json.map.example
ECHO.
ECHO. 4 - config.json.optimizer.example
ECHO.
ECHO. 5 - config.json.path.example
ECHO.
ECHO. 6 - config.json.pokemon.example
ECHO.
ECHO. Choose the config you want to use with your bot,
ECHO.
ECHO. to customize it you will have to edit %pbCONFIG%.
ECHO.
ECHO.
:_choice2
SET _ok2=
SET /p _ok2= Make your choice or press Enter to close: ||goto:eof
IF "%_ok2%" == "1" copy %pbCONFIG%.example %pbCONFIG%
IF "%_ok2%" == "2" copy %pbCONFIG%.cluster.example %pbCONFIG%
IF "%_ok2%" == "3" copy %pbCONFIG%.map.example %pbCONFIG%
IF "%_ok2%" == "4" copy %pbCONFIG%.optimizer.example %pbCONFIG%
IF "%_ok2%" == "5" copy %pbCONFIG%.path.example %pbCONFIG%
IF "%_ok2%" == "6" copy %pbCONFIG%.pokemon.example %pbCONFIG%
GOTO :EndUserData 

:EndUserData
cls
ECHO.
ECHO.
ECHO. Your %PBN1-ninja% and %PBN2-user% have been made.
ECHO.
ECHO. %pbCONFIG% needs to be customized
ECHO.
ECHO. or you can run the bot with the default values.
ECHO.
ECHO. After that you are ready to start the bot.
ECHO.
ECHO.
timeout /t 10
goto:eof

:ninjaExtract
REM Extracting Ninja key and user data 
SET destJSON=%jsnDir%\PBN1ninja.csv
SET propKEY=%jsnDir%\PBN1ninja.key
SET raw_targetJSON=raw_targetJSON.json
SET testKEY="donator"
SET checkKeyResult=false
SET backupNinja=%jsnDir%\PBN2user-%DATE%_%myTime%.json

IF %debug%==0 ECHO:db     jsnDir : %jsnDir%
IF %debug%==0 ECHO:db     Backup file: %backupNinja%

IF EXIST %destJSON% ECHO:  Backup of %destJSON% 
IF EXIST %destJSON% copy %destJSON% %backupNinja%
IF EXIST %destJSON% ECHO:  Deleting old %destJSON% 
IF EXIST %destJSON% del %destJSON% 
IF EXIST %raw_targetJSON% del %raw_targetJSON%

REM CHECK to see if the JSON is valid
ECHO: Check for value %testKey% exists in JSON
find /i %testKey% %targetJSON% > nul
IF %ERRORLEVEL% equ 0 SET checkKeyResult=valid
ECHO checkKeyResult: %checkKeyResult%

ECHO:
ECHO:  Extracting Ninja settings from:
ECHO:     target: %targetJSON%
ECHO:     writing to: %destJSON%
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
type %raw_targetJSON% > %destJSON%
ECHO: 
ECHO: Completed extraction of %sections% data from %targetJSON% to %destJSON%
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