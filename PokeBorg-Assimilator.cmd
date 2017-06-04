@ECHO off
@setlocal enableextensions enabledelayedexpansion
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
Title = PokeBorg Advanced Automation Installation
SET "space= "

:initVars
REM -- Initialize local variables
SET "situation=%~n0"
REM SET DEBUG=0 here 
SET DEBUG=1
IF %debug%==0 ECHO:db     Debug mode activated - Debug: %debug%

:initPaths
REM -- Determine paths and directories 
REM - Local assignments
REM Paths have the \ at the end
for %%A in ("%~dp0\..") do SET "home_small=%%~sA"
for %%A in ("%~dp0") do SET "current_small=%%~sA"
SET batchPath=%current_small%
SET installPath=%batchPath%
REM - Global assignments
SET pbDir=%installPath%PokeBorg
SET logDir=%installPath%PBN-LOGS
SET downPath=%installPath%PBN-Versions\
SET jarDir=%installPath%PBN-JAR\
SET jsnDir=%installPath%PBN-JSONs
SET ptcDir=%installPath%PBN-PTC

:initFiles
REM -- Determine fileName variables
FOR %%k in (%0) do SET batchName=%%~nk
SET log=%batchname%.log

:localChecks
:displayChecks
IF %debug%==0 ECHO:db     Start of Assimilator process 
IF %debug%==0 CALL :TLOCAL

:checkSINGULARITY
IF %debug%==0 ECHO: -- Function:  testSINGULARITY
IF %debug%==0 GOTO CheckInstallPath
REM TODO Detect unzip success and run download if not there
REM TODO Test to see if already installed and coming here to update then redirect - test install log 
IF EXIST %logDir%\%log%  GOTO beginLogging
REM Option later to just have one file to download
ECHO: 
ECHO:------- PokeBorg Advanced Automation Installer -----------
ECHO:  
<nul (set/p myDot=Please wait: Scanning all open hailing frequencies . )
FOR /L %%A IN (0,1,5) DO CALL :DOT
GOTO CheckInstallPath
:DOT
TIMEOUT /T 1 >NUL
<nul (set/p myDot= . . )
GOTO :EOF

:CheckInstallPath
IF %debug%==0 ECHO: -- Function:  CheckInstallPath
TITLE=%borg%
REM -- Check if the user wants to install here
ECHO: %borg%
ECHO:--------------------Assimilation Start -----------------------
ECHO:  
ECHO: Your computer is about to be assimilated, RESISTANCE IS FUTILE! 
ECHO: Your technological and biological distinctiveness will ba added to our own.
ECHO: 
ECHO: PokeBorg Advanced Automation NinjaBotter will be installed in this folder:  
ECHO:      installPath
ECHO: 
ECHO:  Is this the location where you want to install the program?
choice /C YN /M ": Click Y to be assimilated or N to run and hide:"
IF %ERRORLEVEL%==2 GOTO RUN
IF %ERRORLEVEL%==1 GOTO CheckCreateDirectories

:RUN 
IF %debug%==0 ECHO: -- Function:  About to quit
TITLE=RESISTANCE IS FUTILE
ECHO: && ECHO: Move this file to the desired location and re-run the installer from the new folder.
PAUSE
EXIT

:CheckCreateDirectories
REM -- Check if basic directories exist and create them if they do not
IF %debug%==0 ECHO: -- Function:  CheckCreateDirectories
REM Test mkdir permission - if fail then ask to elevate
ECHO: && ECHO: ----- Checking Pokeborg Path -----
<nul (set/p myDot=%space%Folder: PokeBorg%space%)
IF exist %pbDir% ( ECHO exists ) ELSE ( mkdir %pbDir% && ECHO created )
ECHO: && ECHO: ----- Checking Log  Path -----
<nul (set/p myDot=%space%Folder: PokeBorg.PBN-LOGS%space%)
IF exist %logDir% ( ECHO exists ) ELSE ( mkdir %logDir% && ECHO created)
ECHO: && ECHO: ----- Checking Download Path -----
<nul (set/p myDot=%space%Folder: PokeBorg.PBN-Versions%space%)
IF exist %downPath% ( ECHO exists ) ELSE ( mkdir %downPath% && ECHO created )
ECHO: && ECHO: ----- Checking Ninja.Bot Path -----
<nul (set/p myDot=%space%Folder: PokeBorg.PBN-JAR%space%)
IF exist %jarDir% ( ECHO exists ) ELSE ( mkdir %jarDir% && ECHO created )
ECHO: && ECHO: ----- Checking JSONs Path -----
<nul (set/p myDot=%space%Folder: PokeBorg.PBN-JSONs%space%)
IF exist %jsnDir% ( ECHO exists ) ELSE ( mkdir %jsnDir% && ECHO created )
ECHO: && ECHO: ----- Checking PTC Path -----
<nul (set/p myDot=%space%Folder: PokeBorg.PBN-PTC%space%)
IF exist %ptcDir% ( ECHO exists ) ELSE ( mkdir %ptcDir% && ECHO created )
ECHO: && ECHO: Initial directories verified and created.
PAUSE

:beginLogging
REM -- Determine if log file exists and start logging - jump point if log exists
IF %debug%==0 ECHO: -- Function:  beginLogging
REM -- End of Directory creation, skip to here if dir are made
Title = PokeBorg Assimilation Process . . .
REM -- Create Log file if needed
SET log=%logDir%\%log%
IF %debug%==0 ECHO:db     log : %log%
IF EXIST "%log%" GOTO logBatch
(ECHO:
	ECHO: PokeBorg Advanced Automation Assimilator Logs
	ECHO: PokeBorg VER    : %version%
	ECHO: Current CMD     : %situation%
	FOR /F "tokens=*" %%W IN ('VER') DO ECHO: Windows Version : %%W
	FOR /F "tokens=*"  %%J in ('java -fullversion 2^>^&1') DO  ECHO: Java            : %%J
	ECHO: DATE            : %DATE%, %TIME%
	ECHO:=========================================================
)>> "%log%"
CALL :startBatch >> "%log%" 2>&1
GOTO installOptions

:logBatch
IF %debug%==0 ECHO: -- Function:  logBatch
(ECHO:
ECHO: DATE            : %DATE%, %TIME%
ECHO:=========================================================
)>> "%log%"
CALL :startBatch >> "%log%" 2>&1
GOTO installOptions

:startBatch
IF %debug%==0 ECHO: -- Function:  startBatch
REM -- Determine debug mode
CALL :T4
ECHO: Debug mode      : %debug%  
ECHO: Folder pbDir    : %pbDir% 
ECHO: Folder logDir  : %logDir% 
ECHO: Folder jarDir   : %jarDir% 
ECHO: Folder jsnDir   : %jsnDir% 
ECHO: Folder ptcDir   : %ptcDir% 
ECHO: Folder downPath : %downPath% 
EXIT /B %ERRORLEVEL%

:installOptions
REM -- Menu : Select Install options
IF %debug%==0 ECHO: -- Function:  installOptions >> %log%
IF %debug%==1 CLS
TITLE=PokeBorg Advanced Automation Installer
REM TODO Add autodetect of steps completed
REM TODO Add option to install Git
REM TODO Add option to check and install Java based on 32/64bit
REM TODO Add option to blow everything away and start over
REM Would need to add the permissions settings
ECHO:
ECHO:--------------------PokeBorg Installer--------------------
ECHO:   Select an installation option:
ECHO:
ECHO: 1 - Download Pokeborg
ECHO: 2 - Install Pokeborg
ECHO:
ECHO: 3 - Download PokeBot.Ninja
ECHO: 4 - Install PokeBot.Ninja
ECHO: 
ECHO: 5 - Configure Pokeborg
ECHO:
:_choice
SET _ok=
SET /p _ok= Choose an option or press Enter to close: ||goto:eof
IF "%_ok%" == "1" SET CHOICE=downBORG&GOTO :downBORG
IF "%_ok%" == "2" SET CHOICE=installBORG&GOTO :installBORG
IF "%_ok%" == "3" SET CHOICE=downNinja&GOTO :downNinja
IF "%_ok%" == "4" SET CHOICE=installNinja&GOTO :installNinja
IF "%_ok%" == "5" SET CHOICE=configPokeBorg&GOTO :configPokeBorg
GOTO :_choice 

:downBORG
REM -- Function downBORG
IF %debug%==0 ECHO: -- Function:  downBORG >> %log%
IF %debug%==1 CLS
ECHO: 
ECHO:--------------------Downloading PokeBorg--------------------
ECHO: Please wait while PokeBorg is downloaded.
ECHO: 
curl -L https://github.com/dilborg/AdvancedAutomationScripts/raw/master/PBN-JAR/PokeBorg.zip > %downPath%\PokeBorg.zip

REM -TODO Test to see if the download really worked . . 
ECHO:db     PokeBorg download result: %ERRORLEVEL% >> %log%

ECHO: The PokeBorg Program was downloaded.
choice /C YN /M " Click Y to Install PokeBorg or N for Options Menu:"
IF %ERRORLEVEL%==2 GOTO installOptions
IF %ERRORLEVEL%==1 GOTO installBORG
GOTO :EOF

:downNINJA
REM -- Function downNINJA
IF %debug%==0 ECHO: -- Function:  downNINJA >> %log%
IF %debug%==1 CLS
ECHO: 
ECHO:--------------------Downloading Ninja.Bot--------------------
ECHO: Please wait while PokeNinja.BOT is downloaded.
ECHO: 
curl -L https://github.com/dilborg/AdvancedAutomationScripts/raw/master/PBN-JAR/PokeBotNinja.zip > %downPath%\PokeBotNinja.zip

REM -TODO Test to see if the download really worked . . 
ECHO:db     Ninja.Bot download result: %ERRORLEVEL% >> %log%

ECHO: The Ninja.Bot Program was downloaded.
choice /C YN /M " Click Y to Install Ninja.Bot or N for Options Menu:"
IF %ERRORLEVEL%==2 GOTO installOptions
IF %ERRORLEVEL%==1 GOTO installNinja
GOTO :EOF

:installBORG
REM -- Function installBORG
IF %debug%==0 ECHO: -- Function:  installBORG >> %log%
IF %debug%==1 CLS
SET zipFile=%downPath%PokeBorg.zip
IF %debug%==0 ECHO:db     zipFile : %zipFile%  >> %log%
ECHO: 
ECHO:--------------------Installing PokeBorg-------------------- 
CALL :MAKEUNZIP
ECHO: Please wait while files are extracted from: 
ECHO: %zipFile% 
ECHO:
cscript myunzip.vbs %zipFile%  %installPath%  >> %log%
ECHO: The PokeBorg installation is complete.
del myunzip.vbs
choice /C YN /M " Click Y to Downlaod Ninja.BOT or N for Options Menu:"
IF %ERRORLEVEL%==2 GOTO installOptions
IF %ERRORLEVEL%==1 GOTO downNinja
GOTO :EOF

:installNinja
REM -- Function installNinja
IF %debug%==0 ECHO: -- Function:  installNinja >> %log%
IF %debug%==1 CLS
SET zipFile=%downPath%PokeBotNinja.zip
IF %debug%==0 ECHO:db     zipFile : %zipFile%  >> %log%
IF %debug%==0 ECHO:db     jarDir : %jarDir%  >> %log%
ECHO: 
ECHO:--------------------Installing Ninja.Bot-------------------- 
CALL :MAKEUNZIP
ECHO: Please wait while files are extracted from: 
ECHO: %zipFile% 
ECHO:
cscript myunzip.vbs %zipFile%  %jarDir%  >> %log%
ECHO: The Ninja.Bot installation is complete.
del myunzip.vbs
choice /C YN /M " Click Y to Configure PokeBorg Settings or N for Options Menu:"
IF %ERRORLEVEL%==2 GOTO installOptions
IF %ERRORLEVEL%==1 GOTO configPokeBorg
GOTO :EOF

:configPokeBorg
REM -- Function configPokeBorg - used to start the configPokeBorg
IF %debug%==0 ECHO: *** Calling the Installation function from %situation% >> %log% 
ECHO: 
ECHO:--------------------Exiting Assimilator-------------------- 
ECHO:   This function will open a new PokeBorg Config window.
ECHO: PAUSE
START cmd /c %pbDir%\PokeBorg-Configurator.cmd 
GOTO :EOF

:MAKEZIP
REM -- create a local zip helper file
IF %debug%==0 ECHO: -- Function:  MAKEZIP >> %log%
REM Usage: myunzip %zipFile% %extractTo%
    > myunzip.vbs ECHO FolderToZip = Wscript.Arguments(0)
    >> myunzip.vbs ECHO zipFile = Wscript.Arguments(1)
    >> myunzip.vbs ECHO Set sa = CreateObject("Shell.Application")
    >> myunzip.vbs ECHO Set zip= sa.NameSpace(zipFile)
    >> myunzip.vbs ECHO Set Fol=sa.NameSpace(FolderToZip)
    >> myunzip.vbs ECHO zip.CopyHere Fol.Items, 16
    >> myunzip.vbs ECHO Do Until zip.Items.Count = Fol.Items.Count
    >> myunzip.vbs ECHO   WScript.Sleep 1000
    >> myunzip.vbs ECHO  Loop
GOTO :EOF

:MAKEUNZIP
REM -- create a local unzip helper file
IF %debug%==0 ECHO: -- Function:  MAKEUNZIP >> %log%
REM Usage: myunzip %zipFile% %extractTo%
    > myunzip.vbs ECHO pathToZipFile=Wscript.Arguments(0)
    >> myunzip.vbs ECHO extractTo=Wscript.Arguments(1)
    >> myunzip.vbs ECHO set sa = CreateObject("Shell.Application")
    >> myunzip.vbs ECHO set filesInzip=sa.NameSpace(pathToZipFile).items
    >> myunzip.vbs ECHO sa.NameSpace(extractTo).CopyHere filesInzip, 16
    >> myunzip.vbs ECHO Set fso = Nothing
    >> myunzip.vbs ECHO Set objShell = Nothing
    >> myunzip.vbs ECHO Set FilesInZip = Nothing
GOTO :EOF

:REMOVE DIRECTORY
ECHO:----- Checking Removing Bot Folder ----->>%log%
ECHO:>>%log%
IF EXIST %1 rmdir %1 /s /q
IF EXIST %1 (
ECHO:Problem %1 still exists
) else (
ECHO:%1 is removed
)>>%log%
ECHO:>>%log%
GOTO :EOF

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
ECHO: && ECHO:ECHO TESTING Assignments
ECHO:db    *order   : %order% / iOrder  : %iOrder% / myOrder : %myOrder%
ECHO:db    *borg    : %borg% / iBorg   : %iBorg% / myBorg  : %myBorg%
ECHO:db    *matrix  : %borg% / iMatrix : %iMatrix% / myMatrix : %myMatrix%
ECHO:db    *drone   : %borg% / iDrone  : %iDrone% / myDrone : %myDrone%
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

:TPokeBorg
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
REM -- Tidy up a few things
IF EXIST myunzip.vbs del myunzip.vbs
IF %debug%==0 ECHO: -- Function:  EOF >> %log%