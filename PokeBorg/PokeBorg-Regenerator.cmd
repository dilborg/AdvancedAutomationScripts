@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
:: =========================================
:: Name     : PokeBorg-Regenerator.cmd
:: Purpose  : Create Bot directories and stucture
:: Location : InstallHome\Pokeborg\PokeBorg-Regenerator.cmd
:: Author   : Lou Langelier
:: Email    : dilborg@hotmail.com
:: https://github.com/dilborg/AdvancedAutomationScripts
:: =========================================
:: initGlobalSettings
CALL PokeBorg-settings.cmd

:debugMode
:: Local debug dependent on global debug and parameters
SET "_debug=0"
:: SET _debug here 0-no 1-yes 2-log
SET "situation=%~n0"
IF %debug% EQU 1 ( CHOICE /C YN /M "Enable %situation% debug?" )
IF %ERRORLEVEL% EQU 1 SET "_debug=%debug%"
IF %_debug% EQU 1 ( ECHO: Debug mode activated - debug: %debug%  _debug: %_debug%   para9: %9 )
IF %_debug% EQU 1 ( CHOICE /C YN /M "Turn ECHO on?" )
IF %ERRORLEVEL% EQU 1 ECHO ON

:passedVars
REM -- Determine assigned variables 
:ShowPassedVars
REM TESTING parameter output
IF %_debug%==0 GOTO DB1
ECHO:db && ECHO:db TESTING Parameters
ECHO:db myOrder	: %1
ECHO:db order	: %2
ECHO:db fstOrder	: %3
ECHO:db borg		: %4
ECHO:db sndOrder	: %5
ECHO:db matrix	: %6
ECHO:db trdOrder	: %7
ECHO:db drone	: %8
ECHO:db debug	: %debug%
ECHO:db _debug	: %_debug%
PAUSE
:DB1

:TestPassedVars
REM Find out if paramaters sent 
REM IF NO PARAMETERS . . .
    IF %1.==. GOTO No1

REM IF PARAMETER NOT COMPLETE . . . 
    IF %6.==. GOTO No6

:AssignPassedVars
REM Program activated with Parameter
    set myOrder=%1
    set order=%2
    set fstOrder=%3
    set borg=%4
    set sndOrder=%5
    set matrix=%6
    set trdOrder=%7
    set drone=%8

:init
:initDisplay
REM.-- Set the window parameters
MODE CON: cols=100 lines=60
IF %_debug%==0 CLS
IF %_debug%==1 MODE CON: cols=120 lines=200
TITLE = PokeBorg Drone Directory Maker

:initVars 
:: Re-assign variables after change
set myBorg=%fstOrder%-%borg%
set myMatrix=%sndOrder%-%borg%%matrix%
set myDrone=%trdOrder%-%borg%%matrix%%drone%
set /a iDrone=%drone%
set /a iMatrix=%matrix%*10+%iDrone%
set /a iBorg=%borg%*100+%iMatrix%
set /a iOrder=%order%*1000+%iBorg%
set /a nMatrix=0

:initPaths
:: Reassign directories after ID change
SET borgDir=%collDir%%myBorg%
SET matrixDir=%borgDir%\%myMatrix%
SET droneDir=%matrixDir%\%myDrone%

:initFiles
REM -- Determine fileName variables
FOR %%k IN (%0) DO SET batchName=%%~nk
SET log=%logDir%\%batchname%.log

:localChecks
:displayChecks
IF %_debug%==1 ECHO:db     Start of Regenerator process
IF %_debug%==1 CALL :TSTART
IF NOT EXIST %pbDir% GOTO NOPOKEBORG
IF NOT EXIST %logDir% GOTO NOLOGS

:Log_Start
REM -- Determine if log file exists and start logging - jump point if log exists
IF %_debug%==1 ECHO:db -- Function:  beginLogging
REM -- End of Directory creation, skip to here if dir are made
Title = PokeBorg Assimilation Process . . .
REM -- Create Log file if needed
IF %_debug%==1 ECHO:db     Starting log : 
IF EXIST %log% GOTO Log_Batch
(ECHO:
	ECHO: PokeBorg Advanced Automation Regenerator Logs
	ECHO: PokeBorg VER    : %version%
	ECHO: Current CMD     : %situation%
	FOR /F "tokens=*" %%W IN ('VER') DO ECHO: Windows Version : %%W
	FOR /F "tokens=*"  %%J in ('java -fullversion 2^>^&1') DO  ECHO: Java            : %%J
	ECHO: DATE            : %DATE%, %TIME%
	ECHO:=========================================================
)>> "%log%"
CALL :T3 >> %log% 2>&1
GOTO Start_Regenerate

:Log_Batch
ECHO: -- Function:  Log_Batch >> %log%
(ECHO:
ECHO: PokeBorg VER    : %version%
ECHO: DATE            : %DATE%, %TIME%
ECHO:=========================================================
)>> "%log%"
CALL :T3 >> %log% 2>&1
GOTO Start_Regenerate

:Start_Regenerate
:Create_Folders
    ECHO:
    ECHO:  Creating folders:
    ECHO:   %borgDir%
    ECHO:    %sndOrder%: %borg%%matrix%-%borg%9 10x 
    ECHO:     %trdOrder%: %borg%%matrix%%drone%-%borg%99 100x
    ECHO:
:: TEST FOR EXISTING DIR
:Check_Borg
if not exist %borgDir% GOTO Check_Matrix
    ECHO:  
    ECHO:  ..................ALERT..........................
    ECHO:   The directory structure already exists  
    ECHO:   Directory: %borgDir% 
    ECHO:   Do you want to overwrite the directories?
    ECHO:  .................................................
    ECHO:  
    choice /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==2 GOTO DONE
	IF %ERRORLEVEL%==1 GOTO Create_Borg
    
:Check_Matrix
if not exist %matrixDir% GOTO Check_Drones
    ECHO:  ..................ALERT..........................
    ECHO:   The directory structure already exists         
    ECHO:   Directory: %matrixDir% 
    ECHO:   Do you want to overwrite the directories?      
    ECHO:  .................................................
    ECHO:  
    CHOICE /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==2 GOTO DONE
    IF %ERRORLEVEL%==1 GOTO Create_Borg

:Check_Drones
if not exist %droneDir% GOTO Create_Borg
    ECHO:  ..................ALERT..........................
    ECHO:   The directory structure already exists         
    ECHO:   Directory: %droneDir%
    ECHO:   Do you want to overwrite the directories?      
    ECHO:  .................................................
    ECHO:  
    CHOICE /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==2 GOTO DONE
    IF %ERRORLEVEL%==1 GOTO Create_Borg

:Create_Borg
:: BUILD DIRECTORIES
ECHO:db -- Function:  Create_Borg >> %log%
CALL :T2 >> %log% 2>&1

cd %myPogoDir%
ECHO:
ECHO: %fstOrder% and %sndOrder% directories will be created in this folder:  
ECHO: & ECHO:      %borgDir%
ECHO: 
ECHO:  Is this location correct?
ECHO: 
choice /C YN /M ": Click Y to Generate directories, or N to return to Command Console:"
IF %ERRORLEVEL%==2 GOTO DONE

mkdir %myBorg% >> %log% 2>&1
ECHO: & ECHO: Creating %myBorg% Drone directory >> %log% 2>&1
ECHO: & ECHO: Created %myBorg% Drone directory || ECHO: Problem creating %myBorg%

:Create_Matrix
cd %borgDir%
FOR /L %%A IN (0,1,9) DO (
  ECHO: Creating %myBorg%\%sndOrder%-%borg%%%A Drone directory >> %log% 2>&1
  mkdir %sndOrder%-%borg%%%A >> %log% 2>&1
  ECHO: Created %myBorg%\%sndOrder%-%borg%%%A
    FOR /L %%B IN (0,1,9) DO call :Maker %%A %%B
  )   

cd %myPogoDir%

start %borgDir%
ECHO:
ECHO: Finished creating %MyBorg% directory structure.
ECHO:  Created 10x sub-%sndOrder% directories
ECHO:   Created 100X sub-%trdOrder% directories
ECHO:
GOTO DONE

:MAKER
:: Sub helper function for creating Drone directory and create Drone starter CMD
set nMatrix=%1
set nDrone=%2
set myMatrix=%sndOrder%-%borg%%nMatrix%
set myDrone=%trdOrder%-%borg%%nMatrix%%nDrone%
set matrixDir=%borgDir%\%myMatrix%
set droneDir=%matrixDir%\%myDrone%
ECHO: Creating myDrone : %myDrone% - droneDir : %droneDir% >> %log% 2>&1
CD %matrixDir%
mkdir %droneDir% >> %log% 2>&1
:: Create Drone starter CMD -- start-%myDrone%.cmd 
echo ECHO OFF >> start-%myDrone%.cmd
echo CLS >> start-%myDrone%.cmd
echo FOR %%%%* in ^(.^) do set matrixD=%%%%~nx* >> start-%myDrone%.cmd
echo CD %droneDir% >> start-%myDrone%.cmd
echo FOR %%%%* in ^(.^) do set botD=%%%%~nx* >> start-%myDrone%.cmd
echo Title = %%botD%%/%%matrixD%% ** Ninja Bot Running >> start-%myDrone%.cmd
echo ECHO %%cd%% ** Running Poke%%botD%% >> start-%myDrone%.cmd
echo ECHO Wait for automated killswitch . . . >> start-%myDrone%.cmd
echo ECHO................................... >> start-%myDrone%.cmd
echo java -jar %jarDir%\PokeBotNinja.jar -config ninja.json >> start-%myDrone%.cmd
echo PAUSE >> start-%myDrone%.cmd
cd %borgDir%
goto :eof

REM END of activities
::-----------------------------------------------------------
:: helper functions follow below here
::-----------------------------------------------------------
:: ERROR RESPONSE FUNCTIONS
::-----------------------------------------------------------

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
    START cmd /c %borgDir%\PokeBorg.cmd
    EXIT

:No6
    ECHO An error in communication has occured.
    ECHO Paramaters incorrect . . .
    ECHO Parameter1: %1
    ECHO Parameter2: %2
    ECHO Parameter3: %3
    ECHO Parameter4: %4
    ECHO Parameter5: %5
    ECHO Parameter6: %6
    ECHO Parameter5: %7
    ECHO Parameter6: %8
    ECHO Parameter6: %9
    ECHO Fix the Parameters and come back . . 
    PAUSE
GOTO DONE

:NOPOKEBORG
ECHO: ERROR: Directory %borgDir% does not exist.
ECHO: There must be an error with the Pokeborg-Settings file.
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
GOTO DONE

:: -------------------------------
:: TESTING HELPER FUNCTIONS
:: -------------------------------

:TSTART
REM TESTING START Print test series
CALL :T2
CALL :T3
IF %_debug%==2 choice /C YN /M "Turn ECHO on?"
IF %_debug%==2 IF %ERRORLEVEL%==1 ECHO ON
goto :eof

:T1
ECHO: & ECHO:TESTING Parameter and Escape Values
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
ECHO: & ECHO:TESTING Directories
ECHO:db     Pogo       : %myPogoDir%
ECHO:db     Collective : %collDir%
ECHO:db     Borg       : %borgDir%
ECHO:db     Matrix     : %matrixDir%
ECHO:db     Drone      : %droneDir%
ECHO:db     PokeBot    : %pbDir%
ECHO:db     PBN-Jar    : %jarDir%
ECHO:db     PBN-JSON   : %jsnDir%
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

:DONE
ECHO: & ECHO: Pokeborg Regenerator Complete
ECHO: & ECHO: Press any key to return to the PokeBorg Command Console
PAUSE > NUL

:end
REM -- Tidy up a few things
ECHO:db -- Function: end >> %log%
IF %_debug% EQU 1 (
  ECHO:
  ECHO: Display SET _ functions
  SET _
 ) >> %log% 2>&1
IF %_debug% EQU 1 START /B /I notepad.exe %log%
IF %_debug% EQU 1 ECHO: && ECHO: %situation% ended as expected.
set /p "=This window will self-destruct in 3 seconds" < nul
for /l %%a in (1, 1, 5) do (
	set /p "=." < nul
	timeout /t 1 > nul
)
ENDLOCAL
EXIT