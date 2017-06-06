@ECHO off
@setlocal enableextensions disabledelayedexpansion
%~d0
cd %~dp0
cls
TITLE = PokeBorg JSON Extraction
REM =========================================
REM  Email: dilborg@hotmail.com
REM  http://pokebot.ninja/thread-4859.html
REM =========================================
REM Probably not a good idea to change these settings
CALL PokeBorg-settings.cmd
SET debug=1

REM TESTING parameter output
IF %debug%==1  GOTO DB1
ECHO:db && ECHO:db TESTING Parameters
ECHO:db Order: %1
ECHO:db Borg: %2
ECHO:db Matrix: %3
ECHO:db Drone: %4
ECHO:db Target-JSON: %5
ECHO:db Sections: %6
ECHO:db NewSetting: %7
ECHO:db Notassigned: %8
PAUSE
:DB1

REM Find out if paramaters sent 
REM IF NO PARAMETERS . . .
    IF %1.==. GOTO No1

REM IF PARAMETER NOT COMPLETE . . . 
    IF %4.==. GOTO No6

REM USE  START cmd /c %pbDir%\jsonextract.cmd %borg% %matrix% %drone% 
REM Parameter -> Target: ninja.json  Borg-0000.json
REM need to set other directory if special borg setting IE XXXX -> means fqpath in json target
REM set sections options Ninja(PBN1,PBN2), Account(PBN3a), Seen(PBN3b,PBN3c), Config(PBN4), Path(PBN5), Display(run display)
REM Todo - extract choice sections PBN1 / PBN2 / PBN3-account PBN3-lastcheck/warning PBN3-Keep PBN-4 PBNSettings PBN-5 Path and location
REM Parameter -> Section: PBN1, PBN2, PBN3, PBN3LAST, PBN3KEEP, PBN4, PBN5
REM Parameter -> Import Destination Directories
REM Destination : pogo\PBN-jsons\PBN-1 - New Installation (language)
REM Destination : pogo\PBN-jsons\PBN-2 - Ninja keys
REM Destination : drone\3a->c  
REM Destination : pogo\PBNJSONS\PBN-4 Save as new setting -> name (filter hard) 
REM Destination : pogo\PBNJSONS\PBN-5 Save as new path -> name 

REM Program activated with Parameter
    set order=%1
    set borg=%2
    set matrix=%3
    set drone=%4
	set targetJSON=%5
	set sections=%6
	set newSetting=%7

REM Reassign directories after ID change
set myBorg=%fstOrder%-%borg%
set myMatrix=%sndOrder%-%borg%%matrix%
set myDrone=%trdOrder%-%borg%%matrix%%drone%
set /a iDrone=%drone%
set /a iMatrix=%matrix%*10+%iDrone%
set /a iBorg=%borg%*100+%iMatrix%
set /a iOrder=%order%*1000+%iBorg%
set /a nMatrix=0
set borgDir=%collDir%\%myBorg%
set matrixDir=%borgDir%\%myMatrix%
set droneDir=%matrixDir%\%myDrone%

TITLE = PokeBorg JSON Extraction %myDrone%
IF %debug%==0 CALL :T3

REM TEST for failures
REM TODO need to add a test for target JSON file integrity / then ask to use a backup
IF NOT EXIST %droneDir%\%targetJSON% GOTO NOJSON
ECHO: Assimilation process started for %targetJSON%
IF %debug%==0 ECHO:db     Working in directory: %CD% 
IF %debug%==0 ECHO:db     Using Target: %targetJSON%, Sections:%sections%, NewSetting: %newSetting%
IF %debug%==0 PAUSE	
GOTO JS1
	
REM JSON Merger	
REM set sections options Ninja(PBN1,PBN2), Account(PBN3a), Seen(PBN3b,PBN3c), Config(PBN4), Path(PBN5), Display(run display)
:JS1
ECHO: 
ECHO: Beginning JSON Extraction
For /f "tokens=1-2 delims=/:" %%a in ("%TIME: =0%") do (set myTime=%%a%%b)
GOTO JS2

:JS2
REM Parameter -> Section: PBN1, PBN2, PBN3, PBN4, PBN5, 
CD %droneDir%
IF %debug%==0 ECHO:db     Current Dir : %cd%
SET droneJSON=%myDrone%.json
REM Assign target as ninja.json HARD CODING
SET %targetJSON%=ninja.json
REM SET %targetJSON% = %target%
IF %debug%==0 ECHO:db     TargetJSON: %targetJSON%
IF NOT EXIST %targetJSON% GOTO NOJSON
CALL :GETLINES
ECHO: 
ECHO: Start of %sections% extraction data from target: %CD%\%targetJSON%
ECHO: 
IF %debug%==0 ECHO:db     GOing to : %sections%
GOTO %sections%
EXIT

:Ninja
REM TODO deal with Google API - extract and add to paths with replace
REM Extract language and Ninja data
REM CALL :PBN1
IF %debug%==0 ECHO:db     PBN1
IF %debug%==0 PAUSE
CALL :PBN2
ECHO: End of %section% extraction, press any key to return to main program
PAUSE
EXIT

:PBN1
REM Extracting Ninja header data - language
SET destJSON=PBN1ninjaBot.json
SET propKEY="lang"

REM Temp test environment
IF %debug%==0 set jsnDir=%CD%\
IF %debug%==0 ECHO:db     jsnDir : %jsnDir%

set backupNinja=PBN1Ninja-%DATE%_%myTime%.json
IF %debug%==0 ECHO:db     Backup file: %jsnDir%%backupNinja%
IF EXIST %jsnDir%%destJSON% ECHO:  Backup of %destJSON% 
IF EXIST %jsnDir%%destJSON% copy %jsnDir%%destJSON% %jsnDir%%backupNinja%
IF EXIST %jsnDir%%destJSON% ECHO:  Deleting old %destJSON% 
IF EXIST %jsnDir%%destJSON% del %jsnDir%%destJSON% 
IF EXIST raw_%droneJSON% del raw_%droneJSON%

ECHO:
ECHO:  Extracting Ninja data from %targetJSON%, writing to raw_%droneJSON%
IF %debug%==0 find /i %propKey% %targetJSON%
CALL :ReadLine %targetJSON% 1
find /i %propKey% %targetJSON% >> raw_%droneJSON%
ECHO:  %propKey% extracted from %targetJSON%, write to raw_%droneJSON%
IF %debug%==0 ECHO:db     Finished creating raw_%droneJSON%
CALL :SEARCHTEXT
CALL :SEARCHSPACE

REM Backup destJSON if there is one there?
ECHO: 
ECHO:  Rebuild a new %destJSON% from raw_%droneJSON%
type raw_%droneJSON% > %destJSON%
type %jsnDir%\PBN8Line.json >> %destJSON%
ECHO: 
ECHO: Completed extraction of Ninja data from %targetJSON% to %destJSON%
ECHO:

IF %debug%==0 ECHO:db     Clean up the temporary file
del raw_%droneJSON% > nul
IF %debug%==0 ECHO:db     End of process, display new %destJSON%?
IF %debug%==0 PAUSE
IF %debug%==0 CALL :Display %destJSON%
GOTO EOF

:PBN2
REM Extracting Ninja key and user data 
SET destJSON=PBN2user.json
SET propKEY="donator"

REM Temp test environment
IF %debug%==0 set jsnDir=%CD%\
IF %debug%==0 ECHO:db     jsnDir : %jsnDir%

set backupNinja=PBN2user-%DATE%_%myTime%.json
IF %debug%==0 ECHO:db     Backup file: %jsnDir%%backupNinja%
IF EXIST %jsnDir%%destJSON% ECHO:  Backup of %destJSON% 
IF EXIST %jsnDir%%destJSON% copy %jsnDir%%destJSON% %jsnDir%%backupNinja%
IF EXIST %jsnDir%%destJSON% ECHO:  Deleting old %destJSON% 
IF EXIST %jsnDir%%destJSON% del %jsnDir%%destJSON% 
IF EXIST raw_%droneJSON% del raw_%droneJSON%

ECHO:
ECHO:  Extracting %sections% data from %targetJSON%, writing to %destJSON%
IF %debug%==0 ECHO:db     Test if %propKey% exists in %targetJSON%
IF %debug%==0 find /i %propKey% %targetJSON%
IF %debug%==0 PAUSE

set propKEY=PBN2user.key

IF %debug%==0 ECHO:db     Propkey: %propKEY%
IF %debug%==0 PAUSE

for /f "tokens=*" %%P in (%propKey%) do (
	IF %debug%==0 ECHO:db     propKEY: %%P
	IF %%P == ENDBRACKET type %jsnDir%PBN8Bracket.json >> raw_%droneJSON%
	find /i %%P %targetJSON% >> raw_%droneJSON%
	ECHO:  %%P extracted from %targetJSON%, write to raw_%droneJSON%
	)
IF %debug%==0 ECHO:db     PAUSE

IF %debug%==0 ECHO:db     Finished creating raw_%droneJSON%
CALL :SEARCHTEXT
CALL :SEARCHSPACE

REM Backup destJSON if there is one there?
ECHO: 
ECHO:  Rebuild a new %destJSON% - add bracket 
type raw_%droneJSON% > %destJSON%
type %jsnDir%\PBN8Line.json >> %destJSON%
ECHO: 
ECHO: Completed extraction of %sections% data from %targetJSON% to %destJSON%
ECHO:

IF %debug%==0 ECHO:db     Clean up the temporary file
del raw_%droneJSON% > nul
IF %debug%==0 ECHO:db     End of process, display new %destJSON%?
IF %debug%==0 PAUSE
IF %debug%==0 CALL :Display %destJSON%
GOTO EOF

:Account
ECHO: Start of %sections% extraction
CALL :PBN3a
CALL :PBN3b
CALL :PBN3c
ECHO:
ECHO: Rebuilding full PBN3%droneJSON% from PBN3 sections
type PBN3a%droneJSON% > PBN3%droneJSON%
type PBN3b%droneJSON% >> PBN3%droneJSON%
type PBN3c%droneJSON% >> PBN3%droneJSON%
IF %debug%==0 ECHO:db     Clean up the temporary file
IF EXIST raw_%droneJSON% del raw_%droneJSON% 
IF %debug%==0 ECHO:db     End of process, display new PBN3%droneJSON%?
IF %debug%==0 PAUSE
IF %debug%==0 CALL :Display PBN3%droneJSON%
  ECHO:  End of JSON Extract, press any key to return to main program
IF %debug%==0 PAUSE
GOTO EOF

:PBN3a
REM Extracting account and device data
SET destJSON=PBN3a%droneJSON%
SET propKEY="username"

ECHO:
ECHO:  Extracting Account/Device data from %targetJSON%, writing to %destJSON%

REM If username not found - goto error
CALL :FindLine %targetJSON% "username"
IF %line% ==0 GOTO NONAME

find /i "username" %targetJSON% > raw_%droneJSON%
ECHO:  "username" extracted from %targetJSON%, write to Drone JSON
find /i "password" %targetJSON% >> raw_%droneJSON%
ECHO:  "password" extracted from %targetJSON%, write to Drone JSON
find /i "device" %targetJSON% >> raw_%droneJSON%
ECHO:  "device" extracted from %targetJSON%, write to Drone JSON
find /i "deviceBrand" %targetJSON% >> raw_%droneJSON%
ECHO:  "deviceBrand" extracted from %targetJSON%, write to Drone JSON
find /i "deviceID" %targetJSON% >> raw_%droneJSON%
ECHO:  "deviceID" extracted from %targetJSON%, write to Drone JSON
find /i "deviceModel" %targetJSON% >> raw_%droneJSON%
ECHO:  "deviceModel" extracted from %targetJSON%, write to Drone JSON
find /i "deviceModelBoot" %targetJSON% >> raw_%droneJSON%
ECHO:  "deviceModelBoot" extracted from %targetJSON%, write to Drone JSON	
find /i "hardwareManufacturer" %targetJSON% >> raw_%droneJSON%
ECHO:  "hardwareManufacturer" extracted from %targetJSON%, write to Drone JSON
find /i "hardwareModel" %targetJSON% >> raw_%droneJSON%
ECHO:  "hardwareModel" extracted from %targetJSON%, write to Drone JSON
find /i "firmwareBrand" %targetJSON% >> raw_%droneJSON%
ECHO:  "firmwareBrand" extracted from %targetJSON%, write to Drone JSON
find /i "firmwareType" %targetJSON% >> raw_%droneJSON%
ECHO:  "firmwareType" extracted from %targetJSON%, write to Drone JSON
IF %debug%==0 ECHO:db     Finished creating raw_%droneJSON%
CALL :SEARCHTEXT
CALL :SEARCHSPACE
ECHO: 
ECHO:  Rebuild a new %destJSON% - add device and closing space
type raw_%droneJSON% > %destJSON%
type %jsnDir%PBN8Bracket.json >> %destJSON%
ECHO: 
ECHO: Completed extraction of Account Drone data from %targetJSON% to %destJSON%
ECHO:
GOTO :eof

:Seen
ECHO: Start of %section% extraction
ECHO: Not done yet . . .
ECHO: End of %section% extraction.
PAUSE
EXIT

:PBN3b
REM Extracting lastcheck/warning data
SET destJSON=PBN3b%droneJSON%
SET propKEY="warningDone"

ECHO:
ECHO:  Extracting Warning/LastCheck data from %targetJSON%, writing to %destJSON%

find /i "warningDone" %targetJSON% > raw_%droneJSON%
ECHO:  "warningDone" extracted from %targetJSON%, write to Drone JSON
find /i "lastCheck" %targetJSON% >> raw_%droneJSON%
ECHO:  "lastCheck" extracted from %targetJSON%, write to Drone JSON
IF %debug%==0 ECHO:db     Finished creating raw_%droneJSON%
CALL :SEARCHTEXT
CALL :SEARCHSPACE

ECHO: 
ECHO:  Rebuild a new %destJSON% - last check and warning done
type raw_%droneJSON% > %destJSON%
ECHO: 
ECHO: Completed extraction of LastCheck Drone data from %targetJSON% to %destJSON%
ECHO:
GOTO :EOF

:PBN3c
REM Extracting seen data
SET destJSON=PBN3c%droneJSON%
SET propKEY="seen"

ECHO:
ECHO: Extracting Seen data from %targetJSON%, writing to %destJSON%
IF EXIST raw_%droneJSON% del raw_%droneJSON%

REM Find lines for seen start and seen end
SET line=0
CALL:FindLine %targetJSON% "seen"
IF %debug%==0 ECHO:db     ECHO Line = %line%
IF %line%==0 GOTO WHAT
SET /a seenLine = %line%
IF %debug%==0 ECHO:db     ECHO Seen = %seenLine%
CALL:FindLine %targetJSON% "autotransferEnabled"
IF %line%==0 GOTO WHAT
SET /a endLine = %line%-1
IF %debug%==0 ECHO:db     ECHO End = %endLine%
ECHO:
ECHO: Please wait . . . extracting all Seen items
<nul (set/p myDot=..Progress: .)
FOR /L %%C IN (%seenLine%,1,%endLine%) DO CALL:ReadLine %targetJSON% %%C
IF %debug%==0 ECHO:db     Extraction of Seen done~!
type %jsnDir%PBN8Line.json >> PBN3a%droneJSON%
ECHO:
ECHO:  Rebuild a new %destJSON% - add seen and closing space
type raw_%droneJSON% > %destJSON%
ECHO: 
ECHO: Completed extraction of Seen Drone data from %targetJSON% to %destJSON%
GOTO :EOF

:Config
REM TODO - wrap this up
ECHO: Not done yet.
PAUSE
REM Eventually -> call PBN4
EXIT

:PBN4
REM Assign to specific Matrix or Borg?
REM Extracting Settings key and user data 
REM Using new setting variable %newSettings%
SET destJSON=PBN4%newSettings%.json
SET propKEY=PBN4settings.key

IF %debug%==1 ECHO:  Warning, this script is a best effort to extract settings from a JSON,
IF %debug%==1 ECHO:  owever, the best way to create a new settings file is to open a JSON
IF %debug%==1 ECHO:  in Notepad++ and edit a settings JSON manually.  The only reason I 
IF %debug%==1 ECHO:  created this function is out of pure curiosity.  It helped me to build
IF %debug%==1 ECHO:  other more efficient extraction functions.
IF %debug%==1 PAUSE

REM Temp test environment
IF %debug%==0 set jsnDir=%CD%\
IF %debug%==0 ECHO:db     jsnDir : %jsnDir%

set backupNinja=PBN4%newSettings%-%DATE%_%myTime%.json
IF %debug%==0 ECHO:db     Backup file: %jsnDir%%backupNinja%
IF EXIST %jsnDir%%destJSON% ECHO:  Backup of %destJSON% 
IF EXIST %jsnDir%%destJSON% copy %jsnDir%%destJSON% %jsnDir%%backupNinja%
IF EXIST %jsnDir%%destJSON% ECHO:  Deleting old %destJSON% 
IF EXIST %jsnDir%%destJSON% del %jsnDir%%destJSON% 
IF EXIST raw_%droneJSON% del raw_%droneJSON%

ECHO:
ECHO:  Extracting %sections% data from %targetJSON%, writing to %destJSON%
IF %debug%==0 ECHO:db     Test if %propKey% exists in %targetJSON%
IF %debug%==0 find /i %propKey% %targetJSON%
IF %debug%==0 PAUSE


IF %debug%==0 ECHO:db     Propkey: %propKEY%
IF %debug%==0 PAUSE

for /f "tokens=*" %%P in (%propKey%) do (
	IF %debug%==0 ECHO:db     propKEY: %%P
	IF %%P == ENDBRACKET type %jsnDir%PBN8Bracket.json >> raw_%droneJSON%
	find /i %%P %targetJSON% >> raw_%droneJSON%
	ECHO:  %%P extracted from %targetJSON%, write to raw_%droneJSON%
	)
IF %debug%==0 ECHO:db     PAUSE

IF %debug%==0 ECHO:db     Finished creating raw_%droneJSON%
CALL :SEARCHTEXT
CALL :SEARCHSPACE

REM Backup destJSON if there is one there?
ECHO: 
ECHO:  Rebuild a new %destJSON% - add bracket 
type raw_%droneJSON% > %destJSON%
type %jsnDir%\PBN8Line.json >> %destJSON%
ECHO: 
ECHO: Completed extraction of %sections% data from %targetJSON% to %destJSON%
ECHO:

IF %debug%==0 ECHO:db     Clean up the temporary file
del raw_%droneJSON% > nul
IF %debug%==0 ECHO:db     End of process, display new %destJSON%?
IF %debug%==0 PAUSE
IF %debug%==0 CALL :Display %destJSON%
GOTO EOF

:Path
REM TODO - extract path
ECHO: Not done yet.
PAUSE
REM Eventually -> call PBN5
EXIT

:PBN5
ECHO: Start of %section% extraction
ECHO: Not done yet . . .
ECHO: End of %section% extraction.
PAUSE
EXIT

REM Displaying a JSON
:Display
REM USE - CALL:Display %targetJSON%
IF %debug%==0 ECHO:db     Starting JSON Caller
IF %debug%==0 ECHO:db     Variable : %1
SET FQJSON=%droneDir%\%1
IF %debug%==0 ECHO:db     PokeBorg Directory: %pbDir%
IF %debug%==0 ECHO:db     FullPathTarger: %FQJSON%
IF %debug%==0 PAUSE
START cmd /c %pbDir%\jsonDisplay.cmd %FQJSON%
IF %debug%==0 ECHO:db     ErrorLevel: %errorlevel%
IF %debug%==0 ECHO:db     End of display
IF %debug%==0 ECHO:db     PAUSE
GOTO :EOF

REM Start of text, line, strint utilities
:FindLine 
REM USE - CALL:FindLine %targetJSON% %string%
IF %debug%==0 ECHO:db     FindLine TargetJSON: %~1 String: %2
REM Get the username line number
for /f "tokens=1* delims=^[^]" %%a in ('find /n %2 "%~1"') do (
	set line=%%a)
IF %debug%==0 ECHO:db     Found %2 at line %line%
GOTO :eof

:ReadLine
REM USE - CALL:ReadLine %targetJSON% %%C
REM removed the next line for speed, just a test
IF %debug%==0 ECHO:db     Reading Target-JSON: %~1 Line: %2
IF %debug%==1 <nul (set/p myDot=.)
FOR /F %%A IN ('^<"%~1" FIND /C /V ""') DO IF %2 GTR %%A (ECHO Error: No such line %2. 1>&2 & EXIT /b 1)
FOR /F "tokens=1* delims=]" %%A IN ('^<"%~1" FIND /N /V "" ^| FINDSTR /B /C:"[%2]"') DO ECHO %%B >> raw_%droneJSON%
EXIT /b

:GETLINES
:: Get the number of lines in the file
set lines=0
for /f "delims==" %%I in (%targetJSON%) do (
    set /a lines=lines+1
)
ECHO:     There are %lines% lines in %targetJSON%
GOTO :EOF

:SEARCHTEXT
REM  Removing the search parameter the 1st time
IF %debug%==0 ECHO:db     Removing text from raw_%droneJSON%s
CALL :SEARCHREPLACE
GOTO :EOF

:SEARCHSPACE
REM This is a bug fix unable to define empty space as variable
REM Run the 2nd time to remove spaces
IF %debug%==0 ECHO:db     Removing spaces from raw_%droneJSON%s
CALL :SEARCHREPLACE
GOTO :EOF

:SEARCHREPLACE
REM TODO add variables
@ECHO off &setlocal
IF %debug%==0 ECHO:db     Search replace function for raw_%droneJSON%
set "search=---------- NINJA.JSON"
set "replace="
set "textfile=raw_%droneJSON%"
set "newfile=temp%droneJSON%"

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

REM END of activities
GOTO EOF

:NOJSON
REM TODO create or search if its missing
ECHO: ERROR: File %targetJSON% file does not exist.
GOTO WHAT

:NONAME
REM TODO create or search if its missing
ECHO: ERROR: Username missing from JSON.
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

:No6
ECHO:
ECHO: Parameters are missing.
GOTO WHAT

:TSTART
REM TESTING START Print test series
CALL :T2
CALL :T3
CALL :T4
CALL :T5
PAUSE
ECHO on
goto :eof

:T1
ECHO: && ECHO TESTING Parameters
    ECHO Parameter1: %1
    ECHO Parameter2: %2
    ECHO Parameter3: %3
    ECHO Parameter4: %4
    ECHO Parameter5: %5
    ECHO Parameter6: %6
    ECHO Parameter7: %7
    ECHO Parameter8: %8
GOTO :eof

:T2
ECHO: && ECHO ECHO TESTING Assignments
ECHO order   : %order%
    ECHO iOrder  : %iOrder%
    ECHO myOrder : %myOrder%
ECHO borg    : %borg%
    ECHO iBorg   : %iBorg%
    ECHO myBorg  : %myBorg%
ECHO matrix  : %matrix%
    ECHO iMatrix : %iMatrix%
    ECHO myMatrix : %myMatrix%
ECHO drone   : %drone%
    ECHO iDrone  : %iDrone%
    ECHO myDrone : %myDrone%
GOTO :eof

:T3
ECHO: && ECHO TESTING Directories
ECHO Pogo       : %myPogoDir%
ECHO Collective : %collDir%
ECHO Borg       : %borgDir%
ECHO Matrix     : %matrixDir%
ECHO Drone      : %droneDir%
ECHO PokeBot    : %pbDir%
ECHO PBN-Jar    : %jarDir%
GOTO :eof

:T4
ECHO: && ECHO TESTING Auto Values
ECHO: %%~0     =      %~0 
ECHO: %%~1     =      %~1
ECHO: %%~f1     =      %~f0
ECHO: %%~d1     =      %~d0
ECHO: %%~p0     =      %~p0
ECHO: %%~p1     =      %~p1
ECHO: %%~n1     =      %~n0
ECHO: %%~x1     =      %~x0
ECHO: %%~s1     =      %~s0
ECHO: %%~a1     =      %~a0
ECHO: %%~t1     =      %~t0
ECHO: %%~z1     =      %~z0
ECHO: %%~dp0     =      %~dp0
ECHO: %%~dp1     =      %~dp1
ECHO: %%~nx1     =      %~nx0
GOTO :eof

:T5
ECHO: && ECHO TESTING JSON call values
ECHO: Activity = %activity%
ECHO: CoordSet = %coords%
ECHO: Sections %sections%
ECHO newSettings %newSettings%
ECHO targetJSON %targetJSON%
ECHO destJSON %destJSON%
GOTO :eof

:TEND
REM TESTING END
ECHO OFF
ECHO:
ECHO Test/ECHO: off done
PAUSE
GOTO :eof

:EOF