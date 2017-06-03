REM Setup and first run . . .
REM TASKS
REM   1st run
		Ask Quick scan . . .
			NO
				Where is key
				WHere is existing JSON?
			Yes (recomended)
				Confirm KEY
				Ask Key RPM? 1/10/1000
					Shared on multiple systems?
					Sub - Confirm System Details SSD
				Confirm Ninja.Botter
				Confirm PBN1 and PBN22 data
				
				
REM 	SCAN
Find NinjaBot JAR and NinjaBot jsons
- cheat - check path
DIR scan CDs current directories
DIR scan SDs current sub-directories (going down)
DIR scan up one level 
	DIRSCAN CDs
	DIRSCAN SDs

IF C users, end when users

IF C root, end when root (ie, not search parent C)

Search order
 Current Directory
 From Root of C
	
				
		NEW Pokeborg directories
		NEW PBN directories
		NEW BORG-0 directories
		NEW - Ask for BOKEBORG Settings (keys)
		-> save to JSON
		START BOT CSV
		GOTO created
REM   New Borg (grow)
		NEW BORG-1 directories
		GOTO Created
REM   New Matrix (grow)
		Populate the CSV
		GOTO Created
REM   New Drone (grow)
		COPY JSON
		GOTO Created
REM Ask to confirm settings . . .

IF EXIST PokeBorg\PokeBorg.cdb FOR /F "delims=" %%A IN (config.txt) DO SET "%%A"
IF NOT EXIST PokeBorg\PokeBorg.cdb GOTO HEY 
REM HEY -> Possible 1st run, call pbSetup, in PBsetup, have the same test

REM new setting 

If new, create directories
- Make PokeBorg Dir
- Make PBN-JAR
- Make PBN-JSON

Seperate
-Make BORG-0 Dir

Search for ninja.json
- import to directories
DETERMINE 1-10 / 11-100 / 101-1000
Set botMode
Confirm with user . . .

Found X many JSON . . . how many bot do you plan to have ->  


Optional-change settings

1st time run
- Create settings file (know 1st run)
- 


:NEW
Title = PokeBorg Assimilation Process . . .
CLS
ECHO .
ECHO . Hailing frequency open . . . 
ECHO -----------------------------
ECHO . 
ECHO . The %borgDir% folder doesn't exist.
ECHO . You might be running Dilly Batch Botter
ECHO . or opening %fstOrder%-%borg% for the first time.
ECHO . and we need to assimilate you.
ECHO .
ECHO . Would you like to create the required folders? 
ECHO .
choice /C YN /M "Click Y to be assimilated or N to run and hide:"
IF %ERRORLEVEL%==1 GOTO NEW2
IF %ERRORLEVEL%==2 exit

:NEW2
ECHO A new Command window will appear
ECHO Please wait . . . 
START cmd /c %pbDir%\PBCreator.cmd %fstOrder% %borg% %sndOrder% %matrix% %trdOrder% %drone%
set borgDir=%collDir%%myBorg%
GOTO matrix