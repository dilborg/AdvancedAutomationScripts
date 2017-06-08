@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
cls
TITLE = PokeBorg Directory Maker
REM =========================================
REM  Email: dilborg@hotmail.com
REM  http://pokebot.ninja/thread-4859.html
REM =========================================
REM Probably not a good idea to change these settings
CALL PokeBorg-settings.cmd
REM Debug - `0 for debug
SET debug=1
mode con: cols=80 lines=40

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

REM Find out if paramaters sent 
REM IF NO PARAMETERS . . .
    IF %1.==. GOTO No1

REM IF PARAMETER NOT COMPLETE . . . 
    IF %6.==. GOTO No6

REM Program activated with Parameter
    set myOrder=%1
    set order=%2
    set fstOrder=%3
    set borg=%4
    set sndOrder=%5
    set matrix=%6
    set trdOrder=%7
    set drone=%8
    
set myBorg=%fstOrder%-%borg%
set myMatrix=%sndOrder%-%borg%%matrix%
set myDrone=%trdOrder%-%borg%%matrix%%drone%
set /a iDrone=%drone%
set /a iMatrix=%matrix%*10+%iDrone%
set /a iBorg=%borg%*100+%iMatrix%
set /a iOrder=%order%*1000+%iBorg%
set /a nMatrix=0
REM Initial Directory Assignment
set borgDir=%collDir%\%myBorg%
set matrixDir=%borgDir%\%myMatrix%
set droneDir=%matrixDir%\%myDrone%
set jarDir=%myPogoDir%\PBN-JAR
GOTO T1

:No1
    ECHO This program is not intended to be run alone.
    ECHO Use the options in 100 Bot Manager Program 
    ECHO to create new directories. 
    ECHO Would you like to launch the 100 Bot Manager?
    ECHO 
    choice /C YN /M "Enter Y to be assimilated or N to run and hide:"
    IF %ERRORLEVEL%==1 GOTO LAUNCH
    IF %ERRORLEVEL%==2 GOTO DONE

:LAUNCH
    ECHO A new Command window will appear
    ECHO Please wait . . . 
    START cmd /c 100BotManager.cmd
    GOTO End

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

:T1
    ECHO .
    ECHO . Creating folders:
    ECHO . %borgDir%
    ECHO . %sndOrder%: %borg%%matrix%-%borg%9 10x 
    ECHO . %trdOrder%: %borg%%matrix%%drone%-%borg%99 100x
    ECHO .
REM TEST FOR EXISTING DIR
if not exist %borgDir% GOTO T2
    ECHO .
    ECHO ...................ALERT..........................
    ECHO . The directory structure already exists  
    ECHO . Directory: %borgDir% 
    ECHO . Do you want to overwrite the directories?
    ECHO ..................................................
    ECHO .
    choice /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==1 GOTO T4
    IF %ERRORLEVEL%==2 GOTO DONE
:T2
if not exist %matrixDir% GOTO T3
    ECHO ...................ALERT..........................
    ECHO . The directory structure already exists         
    ECHO . Directory: %matrixDir% 
    ECHO . Do you want to overwrite the directories?      
    ECHO ..................................................
    ECHO .
    CHOICE /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==1 GOTO T4
    IF %ERRORLEVEL%==2 GOTO DONE
:T3
if not exist %droneDir% GOTO T4
    ECHO ...................ALERT..........................
    ECHO . The directory structure already exists         
    ECHO . Directory: %droneDir%
    ECHO . Do you want to overwrite the directories?      
    ECHO ..................................................
    ECHO .
    CHOICE /C YN /M "Enter Y to overwrite or N to quit:"
    IF %ERRORLEVEL%==1 GOTO T4
    IF %ERRORLEVEL%==2 GOTO DONE
:T4
REM BUILD DIRECTORIES
ECHO.
ECHO. Please wait, creating directory stucture
ECHO. 
mkdir %myBorg% >> nul
ECHO. Created %borgDir%
cd %myBorg%
FOR /L %%A IN (0,1,9) DO (
  mkdir %sndOrder%-%borg%%%A  >> nul
  ECHO Created %myBorg%\%sndOrder%-%borg%%%A
    FOR /L %%B IN (0,1,9) DO call :Maker %%A %%B
  )   

cd %myPogoDir%

start %borgDir%
ECHO .
ECHO Finished creating %borgDir% directory structure.
ECHO Created 10x sub-%sndOrder% directories
ECHO Created 100X sub-%trdOrder% directories
ECHO .
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


:DONE
ECHO Press any key to close this window and return to Bot Manager
PAUSE
:End