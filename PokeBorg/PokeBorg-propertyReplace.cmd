REM You can call this script with: CALL Script.bat PropKey NewPropValue Filename
@echo off &setlocal
:: script for updating property files
SETLOCAL EnableExtensions
SETLOCAL EnableDelayedExpansion

    ECHO Parameter1: %1
    ECHO Parameter2: %2
    ECHO Parameter3: %3
	ECHO Parameter3: %4


ECHO Script will optionally accept 3 args: PropKey PropVal File
  SET PROPKEY=%1
  SET PROPVAL=%2
  SET FILE=%3
  SET droneDir=%4
  
cd %droneDir%
ECHO %CD%
	
ECHO Find string
ECHO PropKey %PROPKEY%
ECHO File %FILE%
ECHO PROPVAL %PROPVAL%

REM TESTING FINDSTR /B %PROPKEY% %FILE% >nul
CALL :FindLine %file% %PROPKEY%
ECHO Result Find string %line%

REM TESTING
REM IF %ERRORLEVEL% EQU 1 GOTO nowork

ECHO Working

REM SET /A LINE=%LINE:~1,6%
ECHO Line = %LINE%

set searchA=%PROPKEY%: 0.0,
set replaceA=%PROPKEY%: %PROPVAL%,

ECHO searchA %searchA%
ECHO replaceA %replaceA%


REM TODO add variables
ECHO:     Search replace function 
set "search=%searchA%"
set "replace=%replaceA%"
set "textfile=%FILE%"
set "newfile=temp%FILE%"

ECHO %textfile%


(for /f "delims=*" %%i in (%textfile%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%search%=%replace%!"
    echo(!line!
    endlocal
))>"%newfile%"
del %textfile%
rename %newfile%  %textfile%


GOTO end

REM Start of text, line, strint utilities
:FindLine 
REM USE - CALL:FindLine %targetJSON% %string%
ECHO:db     FindLine TargetJSON: %~1 String: %2
REM Get the username line number
for /f "tokens=1* delims=^[^]" %%a in ('find /n %2 "%~1"') do (
	set line=%%a)
ECHO:db     Found %2 at line %line%
GOTO :eof

:nowork
echo Didn't find matching string %PROPKEY% in %FILE%. 
echo No work to do.
GOTO end

:end
PAUSE
