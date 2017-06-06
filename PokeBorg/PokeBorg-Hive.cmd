@ECHO off
@setlocal enableextensions enabledelayedexpansion
:: =========================================
:: Name     : PokeBorg-Hive.cmd
:: Purpose  : SQLite interface
:: Location : InstallHome\PokeBorg-Hive.cmd
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
::  IF vars then dont call the menu
:: 1 -> 
:: 2 db
:: 3 table
:: 4 Function:
:: 5 SQL statement
:: 6 DEBUG
SET debug=1
:: 7 Return

:: setlocal
:: Global Variables here

:init
REM.-- Set the window parameters
color 9F
REM mode con: cols=100 lines=40
Title = PokeBorg Advanced Automation Hive Control
SET "space= "
REM CALL PokeBorg-settings.cmd

:initVars
REM -- Initialize local variables
SET "situation=%~n0"

:debugMode  :: -- determine debug mode
:: Local debug dependent on global debug and parameters
SET _debug=0
:: SET _debug here 0-no 1-yes 2-log
IF EXIST %6 SET %_debug%=%6
IF %debug%==1 (choice /C YN /M "Turn debug for %situation% on?")
IF %ERRORLEVEL%==1 SET _debug=%debug%
IF %_debug%==1 (ECHO: Debug mode activated - debug: %debug%  _debug: %_debug%   para6: %6)
IF %_debug%==1 (choice /C YN /M "Turn ECHO on?")
IF %ERRORLEVEL%==1 ECHO ON

:initPaths
REM -- Determine paths and directories 
FOR %%A in ("%~dp0\..") DO SET "home_small=%%~sA"
FOR %%A in ("%~dp0") DO SET "current_small=%%~sA"
SET batchPath=%current_small%
SET installPath=%home_small%\
SET downPath=%installPath%PBN-Versions\
REM - Global assignments
SET pbDir=%installPath%PokeBorg
SET logDir=%installPath%PBN-LOGS
SET ptcDir=%installPath%PBN-PTC

:initFiles
IF %_debug%==1 ECHO:db -- Function: initFiles
REM -- Determine fileName variables
FOR %%k in (%0) do SET batchName=%%~nk
SET log=%batchname%.log

:initDatabase
:: Database setup db / table / engine
IF %_debug%==1 ECHO:db -- Database declarations 
SET "_db=drone0614.db"
SET "_table=drones"
SET "_engine=sqlite3.exe"

:initSQLPreferences
:: CMD doesnt seem to like this too much
:: IF %_debug%==1 CALL %_engine% %_db% ".ECHO ON"
:: SET "_cfg=sql_config.sql"
:: CALL %_engine% %_db% < "%_cfg%" >> %log% 2>&1

:initSQL
:: SQL Statements
IF %_debug%==1 ECHO:db -- SQLite statements
SET "_testSql=select * from %_table% limit 0;"
SET "_create=create table %_table% ( id integer primary key asc autoincrement, timestamp text default (datetime()), data text);"
SET "_select=select * from %_table%;"
SET "_insert=insert into %_table% ( data ) values ('%_data%');"
SET "_update=update %_table% SET data='' where id=%_id%;"
SET "_delete=delete from %_table% where id=%_id%;"

:logStart
IF %_debug%==1 ECHO:db -- Function: logStart
(ECHO:
ECHO: PokeBorg Advanced Automation NinjaBotter Logs
ECHO: PokeBorg VER    : %version%
ECHO: Current CMD     : %situation%
FOR /F "tokens=*" %%W IN ('VER') DO ECHO: Windows Version : %%W
FOR /F "tokens=*" %%J IN ('java -fullversion 2^>^&1') DO ECHO: Java            : %%J
ECHO: DATE            : %DATE%, %TIME%
ECHO:=========================================================
ECHO:db -- Configured Global Settings
ECHO:db     Debug             : %debug%
ECHO:db     _debug            : %_debug%
)> %log%
:logLocal
CALL :TLOCAL >> %log% 2>&1

:setupSQLite
ECHO:db -- Function: setup >> %log% 
REM - First run add SQLite to path
 :: check IF sqlite exist or not
 IF NOT EXIST "sqlite3.exe" (
  ECHO: Error: sqlite3.exe not found in current directory.
  GOTO :end
 )
GOTO checkTable

:checkTable
ECHO:db -- Function: checkTable >> %log% 
 :: check table exist or not, IF not then create
 CALL :executeSQL "%_testSql%"
 IF %errorlevel% gtr 0 (
  ECHO: Table may not exist, attempting create statement
  CALL :setupData
 )
GOTO logDBOutput

:logDBOutput
:: Perform and log checks on db before staring operations
ECHO:db -- Function: logDBOutput >> %log% 
 ::IF %_debug%==1 CALL :checkDb
 ECHO:  Read db test:>> %log% 
 CALL %_engine% %_db% ".read %_db%" >> %log% 2>&1
 ECHO:=========================================================>> %log% 
 ECHO:  %_db% .show >> %log% 
 CALL %_engine% %_db% ".show" >> %log% 2>&1
 ECHO:=========================================================>> %log% 
 CALL %_engine% %_db% ".database" >> %log% 2>&1
 ECHO:  Tables: >> %log% 
 CALL %_engine% %_db% ".tables" >> %log% 2>&1
 ECHO:=========================================================>> %log% 
 ECHO:  Schema sqlite_master: >> %log% 
 CALL %_engine% %_db% ".schema sqlite_master" >> %log% 2>&1
 ECHO:=========================================================>> %log% 
 ECHO:  >> %log% 
GOTO main

:setupData
ECHO:db -- Function: setupData >> %log%
 ECHO: Setup: Database, Data Installation.
 CALL %_engine% %_db% "%_create%"
GOTO :EOF
 
:checkDb
ECHO:db -- Function: testDb >> %log% 
 :: command attempts to verify that a database is intact and not corrupt
 CALL %_engine% ".selftest --init" >> %log% 2>&1
GOTO :EOF

:displayDB
:: On-screen Display database of paramaters, not so much the data
ECHO:db -- Function: displayDB >> %log% 
 ECHO:
 ECHO:        Database details for : %_db%
 ECHO:=========================================================
 CALL %_engine% %_db% ".database"
 ECHO:  Tables:
 CALL %_engine% %_db% ".tables"
 ECHO:=========================================================
 ECHO:  Full Schema
 CALL %_engine% %_db% ".fullschema"
 ECHO:=========================================================
 ECHO:  Full indexes:
 CALL %_engine% %_db% ".indexes"
 ECHO:=========================================================
 ECHO:  Indexes %_db%:
 CALL %_engine% %_db% ".indexes %_db%"
 ECHO:=========================================================
 ECHO:  Schema  %_db%:
 CALL %_engine% %_db% ".schema %_db%"
 ECHO:=========================================================
 ECHO:
 PAUSE
GOTO :EOF

:main
:: IF PARAMETERS SENT THIS IS WHERE TO SKIP the MENU

:loop
ECHO:db -- Function: loop  >> %log%
IF %_debug%==0 CLS
ECHO:=========================================================>> %log% 
 SET _contd=
 SET _input= 
 ECHO: SQLite within Windows Batch
 CALL :printMenu
 SET /p _input="Enter your choice:"
 ECHO:db     _input             : %_input%  >> %log%
 IF "%_input%"=="b" CALL :displayDB
 IF "%_input%"=="i" CALL :importCSV
 IF "%_input%"=="s" CALL :showTables
 IF "%_input%"=="c" CALL :createData
 IF "%_input%"=="r" CALL :retrieveData
 IF "%_input%"=="s" CALL :selectTest
 IF "%_input%"=="u" CALL :updateData
 IF "%_input%"=="d" CALL :deleteData
 IF "%_input%"=="t" CALL :testFunction
 IF "%_input%"=="l" CALL :customSQL
 IF "%_input%"=="x" GOTO end
 REM Continue once operation is complete
 choice /C YN /M "Do you want to continue? "
 IF %ERRORLEVEL%==1 GOTO LOOP 
 GOTO END

:printMenu
ECHO:db -- Function: printMenu >> %log%
 ECHO: *******************************
 ECHO: 
 ECHO: Available Options:
 ECHO: 
 ECHO:  B. Display db info
 ECHO:  I. Import CSV
 ECHO:  C. Create Data Record
 ECHO:  R. Retrieve Data
 ECHO:  S. Select Test
 ECHO:  U. Update Data
 ECHO:  D. Delete Data
 ECHO:  T. Test new SQLite function
 ECHO:  L. Custom SQL Statement
 ECHO:  X. Exit
 ECHO: 
 ECHO: *******************************
 GOTO :EOF
 
:testFunction
ECHO:db -- Function: testFunction >> %log%
	:: Test this output
	echo @echo  SELECT name from person where id=^%1^;^|  sqlite3.exe mydatabase.sqlite > person.bat
	echo @echo  SELECT phone from person where id=^%1^;^|  sqlite3.exe mydatabase.sqlite > phone.bat
	:: use - person 4 - output the 4th entry
GOTO :EOF

:importCSV
ECHO:db -- Function: importCSV >> %log%
	ECHO:  Import CSV from SQL file
	REM ASk for file  or 
	SET "_tmp=import.sql"
	CALL %_engine% %_db% < "%_tmp%" >> %log% 2>&1
	CALL %_engine% -header -column %_db% "%_select%"
GOTO :EOF
 
:exportCSV
ECHO:db -- Function: importCSV >> %log%
	ECHO:  Import CSV from SQL file
	REM ASk for file  or 
	SET "_tmp=export.sql"
	CALL %_engine% %_db% ".output %_tmp%" >> %log% 2>&1
	CALL %_engine% %_db% "%_select%"
GOTO :EOF

 :testCreateTableSQL :: WORKS
	ECHO: Test Function
	ECHO:  Create table from SQL file
	SET "_tmp=createTable.sql"
	SET "_db"="table.sqlite"
	REM sqlite3.exe test.sqlite < import.sql
	CALL %_engine% %_db% < "%_tmp%"
GOTO :EOF

:executeSQL
 ECHO:db -- Function: executeSQL >> %log%
 ECHO:db  Executing SQL : %* >> %log%
 ECHO: Executing SQL: %*
 CALL %_engine% %_db% "%*" >> %log% 2>&1
 ECHO:db    errorlevel: %errorlevel% >> %log%
 IF %errorlevel% gtr 0 ECHO: Execution Failure
GOTO :EOF

:createData
ECHO:db -- Function: createData >> %log%
 SET _data=
 ECHO: Create Data Record
 ECHO: Enter Data and press return to save.
 SET /p _data=
 SET "_sql=insert into %_table% ( data ) values ('%_data%');"
 CALL :executeSQL "%_sql%"
GOTO :EOF

:selectTest
ECHO:db -- Function: selectTest >> %log%
 ECHO: Test New Select Statement
 CALL :executeSQL "%_selTest%"
GOTO :EOF

:retrieveData
ECHO:db -- Function: retrieveData >> %log%
 ECHO: Retrieve Data
 :: -html -csv -list -separator 'x' -line -header
 CALL %_engine% -header -column %_db% "%_select%"
GOTO :EOF
 
:updateData
ECHO:db -- Function: updateData >> %log%
 SET _id=
 SET _data=
 ECHO: Update Data
 SET /p _id="Enter Id:"
 ECHO: Enter Data and press return to save.
 SET /p _data=
 SET "_sql=update %_table% SET data='%_data%' where id=%_id%;"
 CALL :executeSQL "%_sql%"
GOTO :EOF

:deleteData
ECHO:db -- Function: deleteData >> %log%
 ECHO: Delete Data
 SET _id=
 SET /p _id="Enter Id:"
 SET /p _tmp="Are you sure (y/n):"
 IF /i "%_tmp%"=="y" (
  SET "_sql=delete from %_table% where id=%_id%;"
  CALL:executeSQL "%_sql%"
 ) else ECHO: Delete cancelled.
GOTO :EOF

:customSQL
ECHO:db -- Function: customSQL >> %log%
ECHO: Custom SQL
ECHO: Enter SQL Statement and press return.
 SET /p _tmp=
 CALL:executeSQL "%_tmp%"
GOTO :EOF
 
 :: Testing parameters

:TLOCAL 
ECHO:db   --database variables
ECHO:db     _db               : %_db%
ECHO:db     _table            : %_table%
ECHO:db     _engine           : %_engine%
ECHO:db   --sql statenents
ECHO:db     _testSql          : %_testSql%
ECHO:db     _create           : %_create%
ECHO:db     _select           : %_select%
ECHO:db     _selTest          : %_selTest%
ECHO:db     _insert           : %_insert%
ECHO:db     _update           : %_update%
ECHO:db     _delete           : %_delete%
ECHO:
GOTO :EOF
 
:end
ECHO:  >> %log% 
ECHO:db -- Function: end >> %log%
 (
  ECHO:
  ECHO: Display SET _ functions
  SET _
 ) >> %log% 2>&1
 CALL %_engine% %_db% ".EXIT" >> %log% 2>&1
 START /B /I notepad.exe PokeBorg-Hive.log
 endlocal
EXIT /B %ERRORLEVEL%
ECHO: Done, IF still active, then it is safe to close.

:EOF