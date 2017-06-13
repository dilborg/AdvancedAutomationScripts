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


:passedVars
REM -- Determine assigned variables 
SET "debug=%1"
IF NOT DEFINED debug SET debug=0

:ShowPassedVars
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
mode con: cols=100 lines=60
CLS
TITLE = PokeBorg Drone Directory Maker

:initVars 
:: Re-assign directories after change
set myBorg=%fstOrder%-%borg%
set myMatrix=%sndOrder%-%borg%%matrix%
set myDrone=%trdOrder%-%borg%%matrix%%drone%
set /a iDrone=%drone%
set /a iMatrix=%matrix%*10+%iDrone%
set /a iBorg=%borg%*100+%iMatrix%
set /a iOrder=%order%*1000+%iBorg%
set /a nMatrix=0

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
REM Initial Directory Assignment
SET borgDir=%collDir%%myBorg%
SET matrixDir=%borgDir%\%myMatrix%
SET droneDir=%matrixDir%\%myDrone%
GOTO Start_Rejenerate

:Start_Rejenerate
:Create_Folders
    ECHO .
    ECHO . Creating folders:
    ECHO . %borgDir%
    ECHO . %sndOrder%: %borg%%matrix%-%borg%9 10x 
    ECHO . %trdOrder%: %borg%%matrix%%drone%-%borg%99 100x
    ECHO .
:: TEST FOR EXISTING DIR
:Check_Borg
if not exist %borgDir% GOTO Check_Matrix
    ECHO .
    ECHO ...................ALERT..........................
    ECHO . The directory structure already exists  
    ECHO . Directory: %borgDir% 
    ECHO . Do you want to overwrite the directories?
    ECHO ..................................................
    ECHO .
    choice /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==1 GOTO Create_Borg
    IF %ERRORLEVEL%==2 GOTO DONE
:Check_Matrix
if not exist %matrixDir% GOTO Check_Drones
    ECHO ...................ALERT..........................
    ECHO . The directory structure already exists         
    ECHO . Directory: %matrixDir% 
    ECHO . Do you want to overwrite the directories?      
    ECHO ..................................................
    ECHO .
    CHOICE /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==1 GOTO Create_Borg
    IF %ERRORLEVEL%==2 GOTO DONE
:Check_Drones
if not exist %droneDir% GOTO Create_Borg
    ECHO ...................ALERT..........................
    ECHO . The directory structure already exists         
    ECHO . Directory: %droneDir%
    ECHO . Do you want to overwrite the directories?      
    ECHO ..................................................
    ECHO .
    CHOICE /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==1 GOTO Create_Borg
    IF %ERRORLEVEL%==2 GOTO DONE

:Create_Borg
IF %_debug%==1 ECHO:db -- Function:  Create_Borg
REM BUILD DIRECTORIES
cd %myPogoDir%

IF %_debug% EQU 1 CALL :TSTART

ECHO:
ECHO: PokeBorg Bots JSON files will be created in this folder:  
ECHO: & ECHO:      %borgDir%
ECHO: 
ECHO:  Is this the location where you want to save JSONs?
choice /C YN /M ": Click Y to be assimilated or N to run and hide:"
IF %ERRORLEVEL%==2 GOTO DONE

mkdir %myBorg% && ECHO: Created %myBorg% Drone directory || ECHO: Problem creating %myBorg%

:Create_Matrix
cd %borgDir%
FOR /L %%A IN (0,1,9) DO (
  mkdir %sndOrder%-%borg%%%A && ECHO: Created %myBorg%\%sndOrder%-%borg%%%A
    FOR /L %%B IN (0,1,9) DO call :Maker %%A %%B
  )   

cd %myPogoDir%

start %borgDir%
ECHO:
ECHO: Finished creating %borgDir% directory structure.
ECHO: Created 10x sub-%sndOrder% directories
ECHO: Created 100X sub-%trdOrder% directories
ECHO:
GOTO DONE


:MAKER    
set nMatrix=%1
set nDrone=%2
set myMatrix=%sndOrder%-%borg%%nMatrix%
set myDrone=%trdOrder%-%borg%%nMatrix%%nDrone%
set matrixDir=%borgDir%\%myMatrix%
set droneDir=%matrixDir%\%myDrone%
CD %matrixDir%
mkdir %droneDir% >> nul
echo echo off >> start-%myDrone%.cmd
echo cls >> start-%myDrone%.cmd
echo for %%%%* in ^(.^) do set matrixD=%%%%~nx* >> start-%myDrone%.cmd
echo cd %droneDir% >> start-%myDrone%.cmd
echo for %%%%* in ^(.^) do set botD=%%%%~nx* >> start-%myDrone%.cmd
echo Title = %%botD%%/%%matrixD%% ** Ninja Bot Running >> start-%myDrone%.cmd
echo echo %%cd%% ** Running Poke%%botD%% >> start-%myDrone%.cmd
echo echo Wait for automated killswitch . . . >> start-%myDrone%.cmd
echo ECHO ................................... >> start-%myDrone%.cmd
echo java -jar %jarDir%\PokeBotNinja.jar -config ninja.json >> start-%myDrone%.cmd
echo pause  >> start-%myDrone%.cmd
cd %borgDir%
goto :eof

REM END of activities
::-----------------------------------------------------------
:: helper functions follow below here
::-----------------------------------------------------------

:No1
    ECHO This program is not intended to be run alone.
    ECHO Use the options in the main PokeBorg program  
    ECHO to create new directories. 
    ECHO Would you like to launch PokeBorg?
    ECHO 
    choice /C YN /M "Enter Y to be assimilated or N to run and hide:"
    IF %ERRORLEVEL%==1 GOTO LAUNCH
    IF %ERRORLEVEL%==2 EXIT

:LAUNCH
    ECHO A new Command window will appear
    ECHO Please wait . . . 
    START cmd /c PokeBorg.cmd
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
    ECHO Fix the Parameters and come back . . 
    PAUSE
GOTO DONE

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
ECHO Press any key to close this window and return to Command Console

:end
REM -- Tidy up a few things
ECHO:db -- Function: end 
IF %_debug% EQU 1 (
  ECHO:
  ECHO: Display SET _ functions
  SET _
 ) 
IF %_debug% EQU 1 START /B /I notepad.exe %log%
IF %_debug% EQU 1 ECHO: && ECHO: %situation% ended as exptected.
PAUSE
endlocal
GOTO :EOF