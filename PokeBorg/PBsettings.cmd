@ECHO off
REM %~d0
cd %~dp0

REM Settings configuration
REM Probably not a good idea to change these settings

REM Program activated with Parameter
    SET debug=%1

REM Find out if debug sent as parameter 
REM DEBUG 1 - for no debug
    IF %1.==. SET debug=1

IF %debug%==0 ECHO:db     Getting SETTINGS from ECHO %~dp0

REM Delay setting - depends on System speed SSD, etc
REM Delay is a Multiplier value 0-no delay, 1-3seconds
SET myDelay=1
REM botModes 1-10 bots 2-100 bots 3-1000 bots
SET botMode=1
REM Bot Structure
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

REM Initial Directory Assignment
for %%A in ("%~dp0\..") do SET "root_parent=%%~fA"
REM SET Bot directories
SET myPogoDir=%root_parent%
SET collDir=%myPogoDir%
SET borgDir=%collDir%\%myBorg%
SET matrixDir=%borgDir%\%myMatrix%
SET droneDir=%matrixDir%\%myDrone%
REM SET other utility Directory
SET pbDir=%myPogoDir%\PokeBorg
SET jarDir=%myPogoDir%\PBN-JAR
SET jsnDir=%myPogoDir%\PBN-JSONs
SET ptcDir=%myPogoDir%\PTC

REM PokeBorgUnit default launch config
REM Modes 0-Test 1-Farm 2-Snipe 3-Maintain 5-New 6-Battle
SET unitMode=1

REM jsonMerger default configs for JSON file creation
REM PNB4 Activity JSON File - Farm level (20) - Sniper - Gym 
REM Options: activity_20 / activity_25 / sniper / gymstrat
SET activity=activity_25
REM PBN5 Coordinates JSON File
REM Options: vegas / ottawa / nywoodlawn / coords-blank
SET coords=ottawa

REM jsonExtract Configs
REM Sections options Ninja(PBN1,PBN2), Account(PBN3abc), Seen(PBN3b,PBN3c), Config(PBN4), Path(PBN5), Display(run display)
SET sections=Account
REM SET new path or new settings
SET newSettings=ottawa

REM SET target JSON - normally will be ninja.json
REM TODO: soft code the JSON file
SET currentJSON=ninja.json
REM Eventually want to make this equal myDrone.json
SET gymJSON=%myDrone%GymStrat.json
SET sniperJSON=%myDrone%Sniper.json

REM Default properties replace settings
SET latKey="lat"
SET longKey="lng"
REM Create initial coord settings
SET lng=0.0
SET lat=0.0

REM Menu display settings
FOR /f "delims=" %%x IN (spacer.txt) DO set TAB=%%x
SET COL=%TAB%:
SET cols=80 
SET lines=40
SET colour=9F

IF %debug%==0 ECHO:db     End of PBSettings.cmd
