@ECHO off
CLS
@SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
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

REM TODO Add autodetect of steps completed
REM TODO Add option to install Git
REM TODO Add option to check and install Java based on 32/64bit
REM TODO Add option to blow everything away and start over
REM Would need to add the permissions settings

:passedVars
REM -- Determine assigned variables 
SET "debug=%1"
IF NOT DEFINED debug SET debug=0

:init
REM.-- Set the window parameters
SET cols=120
SET lines=40
:: Menu display settings
SET COL=%TAB%:
SET menuCLR=9F
SET waitCLR=C
SET colour=9F
:initDisplay
mode con: cols=%cols% lines=%lines%
COLOR %colour%
Title = PokeBorg Advanced Automation Installation
SET "space= "
SET "tab=	"

:initVars 
SET "situation=%~n0"
SET exec=

:debugMode  
:: Local debug dependent on global debug and parameters
SET "_debug=0"
:: SET _debug here 0-no 1-yes 2-log
IF %debug% EQU 1 ( CHOICE /C YN /M "Enable %situation% debug?" )
IF %ERRORLEVEL% EQU 1 SET "_debug=%debug%"
IF %_debug% EQU 1 ( ECHO: Debug mode activated - debug: %debug%  _debug: %_debug%   para1: %1 )
IF %_debug% EQU 1 ( CHOICE /C YN /M "Turn ECHO on?" )
IF %ERRORLEVEL% EQU 1 ECHO ON

:initPaths
REM -- Determine paths and directories 
REM - Local assignments
REM Paths have the \ at the end
FOR %%A IN ("%~dp0\..") DO SET "home_small=%%~sA"
FOR %%A IN ("%~dp0") DO SET "current_small=%%~sA"
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
FOR %%k IN (%0) DO SET batchName=%%~nk
SET log=%logDir%\%batchname%.log
SET stagesfile=%logDir%\%batchname%-stages.log
SET progressfile=%logDir%\%batchname%-progress.log

:localChecks
:displayChecks
IF %_debug%==1 ECHO:db     Start of Assimilator process
IF %_debug%==1 CALL :TLOCAL

:checkSINGULARITY
IF %_debug% EQU 1 ECHO:db -- Function:  testSINGULARITY
IF %_debug% EQU 1 GOTO Log_Start
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
IF %_debug%==1 ECHO:db -- Function:  CheckInstallPath
TITLE=%borg%
REM -- Check if the user wants to install here
ECHO: %borg%
ECHO:--------------------Assimilation Start -----------------------
ECHO:  
ECHO: Your computer is about to be assimilated, RESISTANCE IS FUTILE! 
ECHO: Your technological and biological distinctiveness will ba added to our own.
ECHO: 
ECHO: PokeBorg Advanced Automation NinjaBotter will be installed in this folder:  
ECHO: & ECHO:      %installPath%
ECHO: 
ECHO:  Is this the location where you want to install the program?
choice /C YN /M ": Click Y to be assimilated or N to run and hide:"
IF %ERRORLEVEL%==2 GOTO RUN
IF %ERRORLEVEL%==1 GOTO CheckCreateDirectories

:RUN
IF %_debug%==1 ECHO:db -- Function:  About to quit
TITLE=RESISTANCE IS FUTILE
ECHO: && ECHO: Move this file to the desired location and re-run the installer from the new folder.

GOTO END

:CheckCreateDirectories
REM -- Check if basic directories exist and create them if they do not
IF %_debug%==1 ECHO:db -- Function:  CheckCreateDirectories
REM Test mkdir permission - if fail then ask to elevate
ECHO: && ECHO:------ Checking Pokeborg Path -----
<nul (set/p myDot=-Folder: PokeBorg )
IF exist %pbDir% ( ECHO exists ) ELSE ( mkdir %pbDir% && ECHO created )
ECHO: && ECHO:------ Checking Log  Path -----
<nul (set/p myDot=-Folder: PokeBorg.PBN-LOGS )
IF exist %logDir% ( ECHO exists ) ELSE ( mkdir %logDir% && ECHO created)
ECHO: && ECHO:------ Checking Download Path -----
<nul (set/p myDot=-Folder: PokeBorg.PBN-Versions )
IF exist %downPath% ( ECHO exists ) ELSE ( mkdir %downPath% && ECHO created )
ECHO: && ECHO:------ Checking Ninja.Bot Path -----
<nul (set/p myDot=-Folder: PokeBorg.PBN-JAR )
IF exist %jarDir% ( ECHO exists ) ELSE ( mkdir %jarDir% && ECHO created )
ECHO: && ECHO:------ Checking JSONs Path -----
<nul (set/p myDot=-Folder: PokeBorg.PBN-JSONs )
IF exist %jsnDir% ( ECHO exists ) ELSE ( mkdir %jsnDir% && ECHO created )
ECHO: && ECHO:------ Checking PTC Path -----
<nul (set/p myDot=-Folder: PokeBorg.PBN-PTC )
IF exist %ptcDir% ( ECHO exists ) ELSE ( mkdir %ptcDir% && ECHO created )
ECHO: && ECHO: Initial directories verified and created.
ECHO: 
IF %_debug%==0 PAUSE

:Log_Start
REM -- Determine if log file exists and start logging - jump point if log exists
IF %_debug%==1 ECHO:db -- Function:  beginLogging
REM -- End of Directory creation, skip to here if dir are made
Title = PokeBorg Assimilation Process . . .
REM -- Create Log file if needed
IF %_debug%==1 ECHO:db     Starting log : >> %log%
IF EXIST %log% GOTO Log_Batch
(ECHO:
	ECHO: PokeBorg Advanced Automation Assimilator Logs
	ECHO: PokeBorg VER    : %version%
	ECHO: Current CMD     : %situation%
	FOR /F "tokens=*" %%W IN ('VER') DO ECHO: Windows Version : %%W
	FOR /F "tokens=*"  %%J in ('java -fullversion 2^>^&1') DO  ECHO: Java            : %%J
	ECHO: DATE            : %DATE%, %TIME%
	ECHO:=========================================================
)>> "%log%"
CALL :TLOCAL >> %log% 2>&1
GOTO Start_Batch

:Log_Batch
ECHO: -- Function:  Log_Batch >> %log%
(ECHO:
ECHO: DATE            : %DATE%, %TIME%
ECHO:=========================================================
)>> "%log%"
CALL :TLOCAL >> %log% 2>&1
GOTO Start_Batch

:Start_Batch
::
:: Begin Menu Execution - variable <MenuName>
::
ECHO: -- Function:  Start_Batch >>%log%

:: CALL :Menu - Variable of Menu-Name
CALL :Menu Main
GOTO :EOF

:: Generic Menu Function 
:Menu <1=Menu-Name>
ECHO:db -- Function Menu  >>%log%
SET Menu-Prefix=%~1
SET Menu-Name=Menu-%Menu-Prefix%

:: Obtain Menu options and displays - using Menu-Main
CALL :%Menu-Name%

:: add log entry
(
ECHO:db -- Menu Locals
ECHO:db     Parameter1        : %~1
ECHO:db     Menu-Prefix       : %Menu-Prefix%
ECHO:db     Menu_Name         : %Menu-Name%
ECHO:db     _Menu-Title       : %Menu-Title%
ECHO:db     _Menu-Description : %Menu-Description%
ECHO:db     _Menu-Prompt      : %Menu-Prompt%
) >> %log%


:: Build Menu Steps then Build Menu
:: 
:: Build Steps for this menu 
:: 
:: Step File Initialize
:step_build
:: Create Stages File if it doesn't exit
ECHO: -- Function:  step_build >>%log%

if not exist "%stagesfile%" (
	ECHO:     Stages File Create >>%log%
	findstr /b ":Step_%Menu-Prefix%" "%~f0">%stagesfile%
	rem Reset progress if starting over from the beginning
	if exist "%progressfile%" del "%progressfile%"
)

:step_read
:: Read the current steps file
ECHO: -- Function:  step_read >>%log%

if exist "%progressfile%" (
	ECHO:     ProgressFile Exists >>%log%
	for /f "usebackq" %%a in ("%progressfile%") do set curstep=%%a
	ECHO:     Current Step : %curstep% >>%log%
) else (
	ECHO:     ProgressFile Missing >>%log%
	set exec=1
	ECHO:db     exec       : %exec% >>%log%
)

:: Build Menu after Steps are determined

REM call :Menu_Build "MyMainMenu" MainMenu
	ECHO:db     Function Menu:Before Menu_Build >>%log%

call :Menu_Build %Menu-Prefix% Menu-Array
	ECHO:db     Function Menu: After Menu_Build >>%log%

:Menu_Show
:: Start Menu loop based on Menu variable
ECHO: -- Function:  Menu_Show >>%log%
IF %_debug%==1 ECHO: -- Function:  Menu_Show

ECHO:db -- Menu Locals >>%log%
ECHO:db     Parameter1        : %~1 >>%log%
ECHO:db     Menu-Prefix       : %Menu-Prefix% >>%log%
ECHO:db     Menu-Name         : %Menu-Name% >>%log%

	:: Go over all the stages
	SET /A _ExecNext=%exec%+1
	call :Menu_Display Menu-Array %Menu-Prompt% Selection

	:: Execute each step in progression
	:Menu_Execute
	IF %_debug%==1 ECHO: -- Selection       : %Selection%
	SET "vSelection=:Step_%Menu-Prefix%_%Selection%"
	IF %_debug%==1 ECHO: -- About to Execute: %vSelection%
	IF %_debug%==1 PAUSE
	
	TITLE=%Menu-Title% - %vSelection%
	CALL %vSelection%
	IF %Selection% EQU Q GOTO END
	
	REM ECHO: The Ninja.Bot Program was downloaded.
	REM choice /C YN /M " Click Y to Install Ninja.Bot or N for Options Menu:"
	REM IF %ERRORLEVEL%==2 GOTO installOptions
	REM IF %ERRORLEVEL%==1 GOTO installNinja
	
	:: loop back to Menu_Show
	ECHO: -- End of Menu_Show:  loop back to Menu_Show >>%log%
	ECHO: +----------------------------------------------------------------------+
	choice /C YN /M "==============Continue to next step?=============="
	IF %ERRORLEVEL% EQU 1 GOTO Menu_Show

	:: All done!
	GOTO END

:Menu_Build <1=Menu-Prefix> <2=MenuVar-Out>
:: Build the menu one time
ECHO: -- Function:  Menu_Build >>%log%
IF %_debug%==1 ECHO: -- Function:  Menu_Build
IF %_debug% EQU 1 ( CHOICE /C YN /M "Turn ECHO on?" )
IF %ERRORLEVEL% EQU 1 ECHO ON

ECHO:db     Parameter1       : %~1  >>%log%
ECHO:db     Parameter2       : %~2  >>%log%
ECHO:db     Menu-Name        : %Menu-Name%  >>%log%
ECHO:db     Menu-Prefix      : %Menu-Prefix%  >>%log%

	ECHO:db   -- Start Search loop >>%log%
	set nmenu=1
	SET "vStepSearch=:Step_%~1"
	ECHO:db  vStepSearch - sb :Step-Main  - %vStepSearch%  >>%log%
	
	:: Search each :Step-Main_X
	for /F "tokens=3* delims=_ " %%i in ('findstr /c:"%vStepSearch%" /b "%~f0"') do (
		ECHO:db  Token-%%i  Display-%%j >>%log%
		SET %~2-N[!nmenu!]=%%i
		SET %~2-Display[!nmenu!]=%%j
		set /A nmenu+=1
	)
	ECHO:db   -- Stop Search loop >>%log%
	
	:: This is used again in Display
	set /a vCount=%nmenu%-1
	
	set nmenu=
	:: Return the number of menu items built
	@ECHO OFF
exit /b %nmenu%
	
:Menu_Display <1=MenuVar-In> <2=Prompt-Text> <3=Dispatch-Label-Out>
ECHO: -- Function:  Menu_Display >>%log%
ECHO:db     Parameter1       : %~1 >>%log%
ECHO:db     Parameter2       : %~2 >>%log%
ECHO:db     Parameter3       : %~3 >>%log%
ECHO:db     exec             :  %exec% >>%log%

	SETLOCAL
	IF %_debug% EQU 0 CLS
	TITLE=%Menu-Title%
	ECHO: +============== PokeBorg Advanced Automation NinjaBotter ==============+
	ECHO: +----------------------------- %Menu-Prefix% Menu ------------------------------+
	ECHO:                           %Menu-Description%
	ECHO: +----------------------------------------------------------------------+
	ECHO:db -- Menu Display Local: Start >>%log%
	ECHO:db    -- Start Item loop >>%log%
	set choices=
	:: FOR every item-%i in Menu
	for /l %%i in (1, 1, %vCount%) do (
		for /f "tokens=*" %%c in ("!%~1-N[%%i]!") do (
			set choice=%%c
			set choices=!choices!!choice!
		)
		:: This echo call is delayed, spits out return
		ECHO:     ^!choice!^ - !%~1-Display[%%i]!
	)
	:: This is where the Footer would go
	ECHO: +----------------------------------------------------------------------+
	ECHO:   
	ECHO: ===========================PRESS 'Q' TO QUIT============================
	ECHO:	
	:: TODO check if choice is empty and rebuild
	choice /C:%choices% /M "==============%~2=============="
	========================
	========================
	(
		ECHO: -- Menu Display Local: Stop >>%log%
		ENDLOCAL
		set %~3=!%~1-N[%errorlevel%]!
		exit /b 0
	)

:Menu-Main
:: Initialize Menu options and displays
SET Menu-Title=PokeBorg Advanced Automation Installater
SET Menu-Description=PokeBorg Installer
SET Menu-Prompt="Select an installation option:"
GOTO :EOF

::menu_activity_A "Description Here"

:Step_Main_1 Download Pokeborg from GITHUB
	CALL :Download_Pokeborg
	goto :eof
	
:Step_Main_2 Extract Pokeborg ZIP and install Pokeborg
	CALL :Install_Borg
	goto :eof

:Step_Main_3 Download Ninja-Bot from GITHUB
	CALL :Download_Ninja
	goto :eof

:Step_Main_4 Extract Ninja-Bot ZIP and install Ninja-Bot
	CALL :Install_Ninja
	goto :eof
	
:Step_Main_5 Configure Pokeborg installation  
	CALL :Config_Pokeborg
	goto :eof
	
:Step_Main_Q Quit
	ECHO: && ECHO:    Terminating script operations. 
	ECHO: ===========================THANKYOU=========================== && ECHO:
GOTO :EOF

:Download_Pokeborg
REM -- Function downBORG
ECHO: -- Function:  downBORG >> %log%
ECHO: 
ECHO: +-------------------------Downloading PokeBorg-------------------------+
ECHO: Please wait while PokeBorg is downloaded.
ECHO: 
curl -L https://github.com/dilborg/AdvancedAutomationScripts/raw/master/PBN-Resources/PokeBorg.zip > %downPath%\PokeBorg.zip && ECHO: Download Succeeded || ECHO: Download Failed

REM -TODO Test to see if the download really worked . . 
ECHO:db     PokeBorg download result: %ERRORLEVEL% >> %log%
ECHO: The PokeBorg Program was downloaded.
GOTO :EOF

:Download_Ninja
REM -- Function downNINJA
ECHO: -- Function:  downNINJA >> %log%
ECHO: 
ECHO: +------------------------Downloading Ninja.Bot-------------------------+
ECHO: Please wait while PokeNinja.BOT is downloaded.
ECHO: 
curl -L https://github.com/dilborg/AdvancedAutomationScripts/raw/master/PBN-Resources/PokeBotNinja.zip > %downPath%\PokeBotNinja.zip  && ECHO: Download Succeeded || ECHO: Download Failed

REM -TODO Test to see if the download really worked . . 
ECHO:db     Ninja.Bot download result: %ERRORLEVEL% >> %log%
ECHO: The Ninja-Bot Program was downloaded.
GOTO :EOF

:Install_Borg
REM -- Function installBORG
ECHO: -- Function:  installBORG >> %log%
SET zipFile=%downPath%PokeBorg.zip
ECHO:db     zipFile : %zipFile%  >> %log%
ECHO: 
ECHO: +---------------------------Installing PokeBorg------------------------+
CALL :MAKEUNZIP
ECHO: Please wait while files are extracted from: 
ECHO: %zipFile% 
ECHO:
cscript myunzip.vbs %zipFile%  %installPath%  >> %log%
ECHO: The PokeBorg installation is complete.
del myunzip.vbs
GOTO :EOF

:Install_Ninja
REM -- Function installNinja
ECHO: -- Function:  installNinja >> %log%
SET zipFile=%downPath%PokeBotNinja.zip
ECHO:db     zipFile : %zipFile%  >> %log%
ECHO:db     jarDir : %jarDir%  >> %log%
ECHO: 
ECHO: +-------------------------Installing Ninja.Bot-------------------------+
CALL :MAKEUNZIP
ECHO: Please wait while files are extracted from: 
ECHO: %zipFile% 
ECHO:
cscript myunzip.vbs %zipFile%  %jarDir%  >> %log%
ECHO: The Ninja.Bot installation is complete.
del myunzip.vbs
GOTO :EOF

:Config_Pokeborg
REM -- Function configPokeBorg - used to start the configPokeBorg
ECHO: *** Calling the Installation function from %situation% >> %log% 
ECHO: 
ECHO: +----------------------Begining Configurator---------------------------+
ECHO:   This function will open the PokeBorg Configurator
ECHO:
PAUSE
ECHO: *** Calling %pbDir%\PokeBorg-Configurator.cmd >> %log% 
CALL "%pbDir%\PokeBorg-Configurator.cmd" %debug%
EXIT

:MAKEZIP
REM -- create a local zip helper file
ECHO: -- Function:  MAKEZIP >> %log%
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
ECHO: -- Function:  MAKEUNZIP >> %log%
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
IF %_debug%==2 choice /C YN /M "Turn ECHO on?"
IF %_debug%==2 IF %ERRORLEVEL%==1 ECHO ON
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
ECHO:db     DEBUG       : %debug%
ECHO:db     _DEBUG      : %_debug%
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
ECHO:db     stagesfile  : %stagesfile%
ECHO:db     progressfile: %progressfile%
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

:end
REM -- Tidy up a few things
ECHO:db -- Function: end >> %log%
IF EXIST myunzip.vbs del myunzip.vbs
 (
  ECHO:
  ECHO: Display SET _ functions
  SET _
 ) >> %log% 2>&1
IF %_debug% EQU 1 START /B /I notepad.exe %log%
ECHO: && ECHO: %situation% ended as exptected. && ECHO:
set /p "=This script will terminate in 5 seconds" < nul
for /l %%a in (1, 1, 7) do (
	set /p "=." < nul
	timeout /t 1 > nul
)
endlocal
GOTO :EOF