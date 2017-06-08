REM ECHO off
%~d0
:: =========================================
:: Name     : PokeBorg-settings.cmd
:: Purpose  : Settings configuration function defining global variables
:: Location : InstallHome\PokeBorg-Assimilator.cmd
:: Author   : Lou Langelier
:: Email    : dilborg@hotmail.com
:: https://github.com/dilborg/AdvancedAutomationScripts
:: =========================================
:: Probably not a good idea to change these settings
:: Establish current command sequence

:passedVars
:: -- Determine assigned variables

:initVars
:: -- Initialize local variables
SET "situation=%~n0"
ECHO: Debug: %debug%

:initPaths
:: -- Initial Directory Assignment
for %%A in ("%~dp0..") do SET "home_small=%%~sA"
for %%A in ("%~dp0") do SET "current_small=%%~sA"
SET batchPath=%current_small%
SET installPath=%home_small%\
SET downPath=%installPath%\PBN-Versions\
:: -- Assign other utility Directory
SET "myPogoDir=%home_small%"
SET "pbDir=%myPogoDir%\PokeBorg"
SET "logDir=%myPogoDir%\PBN-LOGS"
SET "jarDir=%myPogoDir%\PBN-JAR"
SET "jsnDir=%myPogoDir%\PBN-JSONs"
SET "ptcDir=%myPogoDir%\PBN-PTC"

:initLog
:: -- Inititate Log file varialbles
SET "LogFileExt=.log"
SET "LogFileName=PokeBorg%LogFileExt%"
:: -- Date is set for when script started
SET "myDate=%DATE%"
SET "myDate=%myDate:-=%"
FOR /f "tokens=1-2 delims=/:" %%a in ("%TIME: =0%") do (set myTime=%%a%%b)
:: -- Create Log file if needed
SET "log=%logDir%\%myDate%_%LogFileName%"
IF EXIST %log% GOTO logBatch
(ECHO:
	ECHO: PokeBorg Advanced Automation NinjaBotter Logs
	ECHO: PokeBorg VER    : %version%
	ECHO: Current CMD     : %situation%
	FOR /F "tokens=*" %%W IN ('VER') DO ECHO: Windows Version : %%W
	FOR /F "tokens=*" %%J IN ('java -fullversion 2^>^&1') DO ECHO: Java            : %%J
	ECHO: DATE            : %DATE%, %TIME%
	ECHO:=========================================================
)>> "%log%"
CALL :startBatch >> "%log%" 2>&1
EXIT /B %ERRORLEVEL%

:logBatch
(ECHO:
ECHO: DATE            : %DATE%, %TIME%
ECHO:=========================================================
)>> "%log%"
CALL :startBatch >> "%log%" 2>&1
EXIT /B %ERRORLEVEL%

:startBatch
:: -- Configure Global Settings
ECHO:db -- Configuring Global Settings
ECHO:db     Debug             : %debug%
SET pbCONFIG=%pbDir%\Pokeborg.ini
ECHO:db     pbCONFIG          : %pbCONFIG%
:: Delay setting - depends on System speed SSD, etc
:: Delay is a Multiplier value 0-no delay, 1-3seconds
SET myDelay=1
ECHO:db     myDelay           : %myDelay%
:: botModes 1-10 bots 2-100 bots 3-1000 bots
SET botMode=1
ECHO:db     botMode           : %botMode%
:: -- Establish Bot Structure
SET myOrder=Collective
SET fstOrder=Borg
SET sndOrder=Matrix
SET trdOrder=Drone
SET /a order=0
SET /a borg=0
SET /a matrix=0
SET /a drone=0
SET myBorg=%fstOrder%-%borg%
SET myMatrix=%sndOrder%-%borg%%matrix%
SET myDrone=%trdOrder%-%borg%%matrix%%drone%
SET /a iDrone=%drone%
SET /a iMatrix=%matrix%*10+%iDrone%
SET /a iBorg=%borg%*100+%iMatrix%
SET /a iOrder=%order%*1000+%iBorg%
SET /a nMatrix=0
:: -- Establish Bot directories
SET collDir=%installPath%
SET borgDir=%collDir%%myBorg%
SET matrixDir=%borgDir%\%myMatrix%
SET droneDir=%matrixDir%\%myDrone%
:: --Launcher default configs
:: Modes 0-Test 1-Farm 2-Snipe 3-Maintain 5-New 6-Battle
SET unitMode=1
:: -- jsonMerger default configs for JSON file creation
:: PNB4 Activity JSON File - Farm level (20) - Sniper - Gym 
:: Options: activity_00 / activity_20 / activity_25 / sniper / gymstrat
SET activity=activity_00
:: PBN5 Coordinates JSON File
:: Options: vegas / nywoodlawn / coords-blank
SET coords=vegas
:: -- jsonExtract Configs
:: Sections options:
::     Ninja(PBN1,PBN2)
::     Account(PBN3abc)
::     Seen(PBN3b,PBN3c)
::     Config(PBN4)
::     Path(PBN5)
::     Display(display JSON)
::     Edit(edit JSON)
SET sections=Account
:: SET new path or new settings
SET newSettings=extractedValues
:: -- JSON File assignments
SET targetJSON=ninja.json
:: TODO: soft code the JSON file
SET currentJSON=ninja.json
:: Eventually want to make this equal myDrone.json
SET gymJSON=%myDrone%GymStrat.json
SET sniperJSON=%myDrone%Sniper.json
:: Default properties replace settings
SET latKey="lat"
SET longKey="lng"
:: Create initial coord settings
SET lng=0.0
SET lat=0.0
:: Menu display settings
FOR /f "delims=" %%x IN (%pbDir%\tabfile.txt) DO SET tab=%%x
FOR /f "delims=" %%x IN (%pbDir%\space.txt) DO SET space=%%x
SET COL=%TAB%:
SET cols=120 
SET lines=60
SET colour=9F
SET menuCLR=9F
SET waitCLR=C
ECHO:db -- End of PBSettings.cmd
ECHO:db     

:EOF