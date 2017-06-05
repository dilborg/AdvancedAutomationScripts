@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
cls
TITLE = PokeBorg JSON Display
REM =========================================
REM  Email: dilborg@hotmail.com
REM  http://pokebot.ninja/thread-4859.html
REM =========================================
REM Probably not a good idea to change these settings
CALL PokeBorg-settings.cmd

REM Find out if paramaters sent 
REM IF NO PARAMETERS . . .
    IF %1.==. GOTO No1
	
IF NOT EXIST %1 GOTO NOJSON

REM Displaying a JSON
:Display
TITLE = PokeBorg JSON Display: %~1
REM USE - CALL:Display %targetJSON%
ECHO.
ECHO. Displaying data from %~1
ECHO.
for /F "tokens=*" %%A in (%~1) do echo %%A
ECHO. End of display
GOTO :EOF

REM END of activities
GOTO EOF

:NOJSON
REM TODO create or search if its missing
ECHO. ERROR: File %targetJSON% file does not exist.
GOTO WHAT

:WHAT
COLOR 74
ECHO. *************************************
ECHO. ****  BIOTECHNILOGICAL ERROR ********
ECHO. *************************************
ECHO. 
ECHO. An error in communication has occured.
ECHO. Press any key for system diagnostics. 
PAUSE 
ECHO. Error details . . .
CALL :TSTART
ECHO. Fix the communication array and come back: 
Pause
EXIT

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

:EOF