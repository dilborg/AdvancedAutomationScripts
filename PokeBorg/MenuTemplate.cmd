@ECHO off
@setlocal enableextensions enabledelayedexpansion
%~d0
cd %~dp0
:: =========================================
:: Name     : MenuTemplate.cmd
:: Purpose  : Template for menus
:: Location : InstallHome\MenuTemplate
:: Author:   Lou Langelier
:: Email: dilborg@hotmail.com
:: https://github.com/dilborg/AdvancedAutomationScripts
:: =========================================
:: -- Version History --
:: Revision:01.100-beta     May 12 2017 - initial version 100 bot manager
::          02.101-beta     Jun 01 2017 - added support for CSV Import
SET version=02.102-beta&REM Jun 03 2017 - installation and configurations support

GOTO Init_Batch
GOTO END


Assimilator - determine column, if less than 120, set 120 -> confirm with user

Various TODO:

** Enable debugging and logging

** Better display - dynamic menu size

Merge Step Build and Item Build
	Or . . . if its step based, work with step display as well.
	Step based . . . loop through the steps - 
	  menu display is for display only, yes to next step option
					Continue or Return/Select option 


Menu -> Name rcd
Set vars and test files

Build
Is there build file?
	Y - move on
		N - scan for menu
			Build the file
	Read the file
		Build array of displays
		Build array of choices

Is there Step or Menu or List file?
	Create Step or List file
		
Show
	Determine step tasks
		If Step X is next
	Call display NextStep
	Choice
	Call :Selection
	Determine Continue or NextStep
		User input continue
	NextStep
		Mark current step as complete
	Loop back to show
	
Display
	Know if Step or Menu or List file
	Pure ECHO to screen
	
	Call header
	call sections
	IF step - current step - mark regular
		Next steps - add a X
		Have a column for completed!
	Call footer
	

Scan:: Menu name ie Main
- scan Self for Main_
- IF Step or Option or Info
	Main_Step_1_X 
	Main_Option_A_A
	Main_Info_1_1

Display option for exit . . . 
	
List = Auto Populate menu from scan of CSV or Database



:Init_Batch

:Init_Params
REM -- Determine assigned variables 
SET /A debug=%1
IF NOT DEFINED debug SET /A debug=0

:Init_Debug
:: Local debug dependent on global debug and parameters
SET /A _debug=0
:: SET _debug here 0-no 1-yes 2-log
IF %debug% EQU 1 ( CHOICE /C YN /M "Enable %situation% debug?" )
IF %ERRORLEVEL% EQU 1 SET /A _debug=%debug%
IF %_debug% EQU 1 ( ECHO: Debug mode activated - debug: %debug%  _debug: %_debug%   para1: %1 )
IF %_debug% EQU 1 ( CHOICE /C YN /M "Turn ECHO on?" )
IF %ERRORLEVEL% EQU 1 ECHO ON

:Init_Globals
:: Call Settings from here
CALL PokeBorg-settings.cmd

:Init_Paths
:: Local paths needed

:Init_Log
:: Ensure logging is working
FOR %%k IN (%0) DO SET batchName=%%~nk
SET log=%logDir%\%batchname%.log

:Init_Locals
REM -- Initialize local variables
SET "situation=%~n0"

:: Format parameter-pairs by right-pad/left-pad
:Init_Local_Pads
SET "spaces=                                                                                                                        "
SET "line="

:Init_Local_Menu
:: Menu display settings
REM TODO Test if file exists and create 120 spacer if not exist
FOR /f "delims=" %%x IN (%pbDir%\tabfile.txt) DO SET tab=%%x
FOR /f "delims=" %%x IN (%pbDir%\space.txt) DO SET space=%%x
SET "colon=^:"
SET "quote=^""
SET "excla=^!"
SET "vline=^|"
SET "eSign=^="
SET "eDash=^-"
SET "meDot=^."
SET "_strSpace= "
SET "_strTAB8=00000000"
SET "_strTAB10=0000000000"
SET "_strTAB30=%_strTAB10%%_strTAB10%%_strTAB10%"
SET "_strTAB40=%_strTAB30%%_strTAB10%"

:Init_Display
Title = PokeBorg Advanced Automation %_situation%
SET cols=121
SET lines=60
SET colour=9F
SET menuCLR=9F
SET waitCLR=C

:Check_Batch
:: Beging Testing

:Main
::Beging Batch Operations

:Begin_Display
IF %_debug% == 0 CLS
COLOR %colour%
MODE CON: cols=%cols% lines=%lines%
IF %_debug%==1 MODE CON: cols=120 lines=200

:Begin_Menu
::
:: Begin Menu Execution - variable <MenuName>
::
ECHO: -- Function:  Begin_Menu >> %log%

CALL :Calculate_Display
CALL :Calculate_Dividers
CALL :Calculate_Tabs

:: CALL :Menu - Variable of Menu-Name
CALL :Menu Main
GOTO :EOF

:: Generic Menu Function 
:Menu <1=Menu-Name>
ECHO:db -- Function Menu  >> %log%
SET Menu-Prefix=%~1
SET Menu-Name=Menu-%Menu-Prefix%

:: Obtain Menu options and displays - using Menu-Main
CALL :%Menu-Name%

:: add Menu details to log
(ECHO:
ECHO:db -- Menu Locals
ECHO:db     Parameter1        : %~1
ECHO:db     Menu-Prefix       : %Menu-Prefix%
ECHO:db     Menu_Name         : %Menu-Name%
ECHO:db      Menu-Title       : %Menu-Title%
ECHO:db      Menu-Type        : %Menu-Type%
ECHO:db      Menu-Description : %Menu-Description%
ECHO:db      Menu-Prompt      : %Menu-Prompt%
) >> %log%

SET stagesfile=%logDir%\%batchname%-%Menu-Prefix%%Menu-Type%.log
SET progressfile=%logDir%\%batchname%-%Menu-Prefix%progress.log

:: Build Menu 
:Menu-Build  <1-Menu-Type> <2-Menu-Prefix> <3=MenuArray-Out> <4-MenuChoices-Out
REM GOTO BUILD  %Menu-Type% %Menu-Prefix% Menu-Array Menu-Choices
ECHO: & ECHO: -- Function:  Menu_Build >> %log%

:: Search Step - Read Steps then Build Menu
:: 
:: Build Steps for this menu 
:: 
:: Step File Initialize

:Menu_Item_Build
:: Create Stages File if it doesn't exit
ECHO: -- Function:  step_build >>%log%
:: Enable Function level debugging
IF %_debug%==1 ECHO: -- Function:  Menu_Build
IF %_debug% EQU 1 ( CHOICE /C YN /M "Turn ECHO on?" )
IF %ERRORLEVEL% EQU 1 ECHO ON

( ECHO:db     1-Menu-Type        : %~1
ECHO:db     2-Menu-Prefix      : %~2
ECHO:db     3=Menu-Array Out   : %~3
ECHO:db     4-Menu-Choices Out : %~4
ECHO:db     Menu-Name          : %Menu-Name%
ECHO:db     Menu-Prefix        : %Menu-Prefix%
ECHO:db     Menu-Type          : %Menu-Type%
) >> %log%

IF NOT DEFINED Menu-Type SET Menu-Type=%1
IF NOT DEFINED Menu-Prefix SET Menu-Type=%2

:Menu_Item_Search
rem if not exist "%stagesfile%" (
	:: Build the menu one time
	ECHO:     Stages File Create >> %log%
	:: Initialize Search Variable - ie Step_Main
	SET vStepSearch=":%Menu-Type%_%Menu-Prefix%"
	ECHO:db     vStepSearch : %vStepSearch%  >> %log%
	:: Search each :Step_Main_X
	findstr /b %vStepSearch% "%~f0" > %stagesfile%
reM )

:Menu_Item_Read
:: Read the current steps file
ECHO: -- Function:  Menu_Item_Read >> %log%

IF NOT EXIST %stagesfile% GOTO NOFILERROR

	ECHO:db   -- Begin Read loop >> %log%
	set nmenu=1
	set choices=
	:: FOR every item-%i in Menu
	FOR /F "tokens=3* delims=_ " %%i in (%stagesfile%) DO (
		ECHO:db  Token-%%i  Display-%%j >>%log%
		SET Menu-Array-N[!nmenu!]=%%i
		SET choice=%%i
		SET choices=!choices!!choice!
		SET Menu-Array-Display[!nmenu!]=%%j
		set /A nmenu+=1
	)
	ECHO:db   -- Stop Search loop >> %log%
	ECHO:db     Choices : %choices% >> %log%
	
	:: This is used again in Display
	set /a ItemCount=%nmenu%-1
	ECHO:db     ItemCount : %ItemCount% >> %log%
	
:Menu_Progress_Read
ECHO:db   -- Begin Menu_Progress_Read >> %log%

	if exist "%progressfile%" (
		ECHO:     ProgressFile Exists >> %log%
		for /f "usebackq" %%a in ("%progressfile%") do set currStep=%%a
		ECHO:     Current Step : %currStep% >> %log%
	) else (
		ECHO:db     ProgressFile Creation >> %log%
		IF %Menu-Type%==Step (
			ECHO:     ProgressFile Steps >> %log%
			set currStep=1
			ECHO %currStep% > "%progressfile%"
		) ELSE (
			ECHO:     ProgressFile Items >> %log%
			ECHO %ItemCount% > "%progressfile%"
		)
	)

ECHO:db     Function Build_Menu: After Menu_Build >>%log%
:: Roll over into Menu_Show

:Menu_Show
:: Loop over Menu ItemCount and Step variables
(ECHO: 
ECHO: -- Function:  Menu_Show
ECHO:db -- Menu SHOW Locals
ECHO:db     Parameter1        : %~1 
ECHO:db     Menu-Name         : %Menu-Name%
ECHO:db     currStep          : %currStep%
ECHO:db     ItemCount         : %ItemCount%
) >>%log%

	:: Display menu
	SET /a Max_Item=%ItemCount%-1
	call :Menu_Display Menu-Array %Menu-Prompt% Selection

	:: Execute result from Selection
	IF %_debug%==1 ECHO:db -- Selection       : %Selection%
	SET "vSelection=%Menu-Type%_%Menu-Prefix%_%Selection%"
	:Menu_Execute
	IF %_debug%==1 ECHO:db -- About to Execute: %vSelection%
	IF %_debug%==1 PAUSE
	
	TITLE=%Menu-Title% - %vSelection%
	CALL :%vSelection%
	
	IF %Selection% EQU Q GOTO END
	
	:: Determine post execution of item
	
	:: loop back to Menu_Show
	IF %Menu-Type%==Item GOTO Menu_Show

	IF %currStep% == %ItemCount% (
		ECHO:  Congratulation! All steps completed.  Press any key to continue.
		PAUSE > NUL
		GOTO Menu_Show
		)

	ECHO:   -- Determine Next Step to Current step : %currStep% >> %log%
	ECHO: & ECHO: Step %currStep% successfully completed.
	SET /a currStep+=1
	ECHO %currStep% > "%progressfile%"
	
	ECHO:     Next Step   : %currStep%  - ItemCount : %ItemCount% >> %log%
	ECHO:     Next Display   : !Menu-Array-Display[%currStep%]!  >> %log%
	
	SET "vSelection=%Menu-Type%_%Menu-Prefix%_%currStep%"
	choice /C YN /M "Do you want to continue to Step %currStep% - !Menu-Array-Display[%currStep%]!"
	IF %ERRORLEVEL%==2 GOTO Menu_Show
	IF %ERRORLEVEL%==1 GOTO Menu_Execute
	
:: All done!
GOTO END

:Menu_Display <1=MenuVar-In> <2=Prompt-Text> <3=Dispatch-Label-Out>
(ECHO: 
ECHO: -- Function:  Menu_Display 
ECHO:db     MenuVar-In         : %~1
ECHO:db     Prompt-Text        : %~2
ECHO:db     Dispatch-Label-Out : %~3
ECHO:db     Menu-Name          : %Menu-Name%
ECHO:db     currStep           : %currStep%
ECHO:db     ItemCount          : %ItemCount%
) >>%log%


	SETLOCAL
	:Menu_Display_Internal
	IF %_debug% == 0 CLS
	TITLE=%Menu-Title%
	:: Display Menu Header
	ECHO:
	IF NOT DEFINED smdHeader CALL :Columns_Center "PokeBorg Advanced Automation NinjaBotter" %Menu_Center% "=" smdHeader
	ECHO:%Tab1S%%smdHeader%%TabFC%
	IF NOT DEFINED smdDesc CALL :Columns_Center "%Menu-Description%" %Menu_Center% " " smdDesc
	ECHO:%Tab1S%%smdDesc%%TabFC%
	IF NOT DEFINED smdMenuName CALL :Columns_Center "%Menu-Prefix% Menu" %Menu_Center% "-" smdMenuName
	ECHO:%Tab1S%%smdMenuName%%TabFC%
	IF NOT DEFINED smdSpacer CALL :Columns_Center " " %Menu_Center% " " smdSpacer
	ECHO:%Tab1S%%smdSpacer%%TabFC%
	ECHO:db -- Menu Display Local: Begin >> %log%
	ECHO:db    -- Begin Item loop >> %log%
	:: Display Menu Items using delayed call
	:: FOR every item-%i in Menu
	SET vDone=
	FOR /L %%i in (1, 1, %Max_Item%) DO (
		ECHO:db     Item i : %%i >> %log%
		IF %%i LSS %currStep% SET "vDone= -DONE-"
		IF %%i==%currStep% SET "vDone="
		CALL :Columns_Display "%Tab1S%" %Tab1W% "!%~1-N[%%i]!" %Tab2W% "%Tab3S%" %Tab3W% "!vDone!" %Tab4W% "!%~1-Display[%%i]!" %Tab5W% "%TabFC%" %TabFW% "%TabFS%" %TabFW%
	)
	:: Display Menu Footer
	ECHO:%Tab1S%%smdSpacer%%TabFC%
	:: Display Current step
	IF %Menu-Type%==Step (
		CALL :Columns_Display "%Tab1S%" %Tab1W% "Current Step : !currStep!" 100 "%TabFC%" %TabFW% "%TabFS%" %TabFW%
	) ELSE (
		ECHO:%Tab1S%%smdSpacer%%TabFC%
	)
	IF NOT DEFINED smdFooter CALL :Columns_Center "PRESS 'Q' TO QUIT" %Menu_Center% "=" smdFooter
	ECHO:%Tab1S%%smdFooter%%TabFC%
	ECHO:	
	choice /C:%choices% /M "%space%==============%~2=============="
	SET "vSelect=%errorlevel%"
	IF %Menu-Type%==Step (
		IF %vSelect% GTR %currStep% (
			IF %vSelect% LSS %ItemCount% (
				ECHO: Step %currStep% not completed, press any key to choose again.
				PAUSE > NUL
				GOTO Menu_Display_Internal
				)
			)
		)
	(
		ECHO: -- Menu Display Local: Stop >>%log%
		ENDLOCAL
		set %~3=!%~1-N[%vSelect%]!
		exit /b 0
	)

	
::-----------------------------------------------------------
:: Menu definitions
::-----------------------------------------------------------

:Menu-Main
:: Initialize Menu options and displays
SET Menu-Title=PokeBorg Advanced Automation Installater
SET Menu-Type=Step
SET Menu-Description=PokeBorg Installer
SET Menu-Prompt="Select an installation option:"
GOTO :EOF

::menu_activity_A "Description Here"

:Step_Main_1 Download Pokeborg from GITHUB
	ECHO Download_Pokeborg
	goto :eof
	
:Step_Main_2 Extract Pokeborg ZIP and install Pokeborg
	ECHO Install_Borg
	goto :eof

:Step_Main_3 Download Ninja-Bot from GITHUB
	ECHO Download_Ninja
	goto :eof

:Step_Main_4 Extract Ninja-Bot ZIP and install Ninja-Bot
	ECHO Install_Ninja
	goto :eof
	
:Step_Main_5 Configure Pokeborg installation  
	ECHO Config_Pokeborg
	goto :eof
	
:Step_Main_Q Quit
	ECHO: && ECHO:    Terminating script operations. 
	ECHO: ===========================THANKYOU=========================== && ECHO:
GOTO :EOF

:Menu-PBCC
:: Initialize Menu options and displays
SET Menu-Title=PokeBorg Advanced Automation NinjaBotter
SET Menu-Type=Option
SET Menu-Description=PokeBorg Command Console
SET Menu-Prompt="Select a command option:"
GOTO :EOF

:Option_PBCC_R Initiate %myMatrix% %trdOrder% in Regular Farm Mode %TAB%%COL%

::-----------------------------------------------------------
:: helper functions follow below here
::-----------------------------------------------------------
:Columns_Display
::Determine Center/Left/Right
SET "line="

:Columns_Display_Line
SET column=%2
IF NOT DEFINED column ECHO(%line:~0,-1%&GOTO :EOF
SET column=%~1
IF %2 gtr 1000 (
	CALL :Columns_Center %1 %2 " " sCenter
	CALL SET "line=%%line%%%%sCenter%%"
	GOTO Column_Display_Shift
	)
IF %2 gtr 0 (SET "column=%column%%spaces%") ^
	ELSE (SET "column=%spaces%%column%")
IF %2 gtr 0 (CALL SET "line=%%line%%%%column:~0,%2%%") ^
	ELSE (CALL SET "line=%%line%%%%column:~%2%%")
:Column_Display_Shift
shift&SHIFT
GOTO :Columns_Display_Line
GOTO :EOF


:Column_Tab_Pad <1=vStrPadded-IN> <2=Width-IN> <3=Delimeter-IN> <4=PadString-Out>
setlocal enabledelayedexpansion
	SET "line="
	SET "vStrPadded=%1"
	SET "vStrPadded=%vStrPadded:"=%"
	SET "vCntrWidth=%2"
	SET "vPad=%3"
	IF NOT DEFINED vPad SET "vPad= ""
	SET "vPad=%vPad:"=%"
	
	IF %2 gtr 0 (SET "vStrPadded=%vStrPadded%%spaces%") ^
	ELSE (SET "vStrPadded=%spaces%%vStrPadded%")
	IF %2 gtr 0 (CALL SET "line=%%vStrPadded:~0,%2%%") ^
	ELSE (CALL SET "line=%%vStrPadded:~%2%%")
	:Column_Pad_End
	    ( 
        endlocal
		SET "%~4=%line%"
        EXIT /b
    )
GOTO :EOF


:Columns_Center <1=vStrPadded-IN> <2=Width-IN> <3=Delimeter-IN> <4=PadString-Out>
setlocal enabledelayedexpansion
	SET "vStrPadded=%1"
	SET "vStrPadded=%vStrPadded:"=%"
	SET "vCntrWidth=%2"
	SET "vPad=%3"
	IF NOT DEFINED vPad SET "vPad= ""
	SET "vPad=%vPad:"=%"
	SET /A "vCntrWidth=!vCntrWidth!-1001"
	:CenterLoopStart
	IF "!vStrPadded:~%vCntrWidth%,1!" NEQ "" GOTO CenterLoopEnd
	SET "vStrPadded=%vStrPadded%%vPad%"
	IF "!vStrPadded:~%vCntrWidth%,1!" NEQ "" GOTO CenterLoopEnd
	SET "vStrPadded=%vPad%%vStrPadded%"
	GOTO CenterLoopStart
	:CenterLoopEnd
	    ( 
        endlocal
		SET "%~4=%vStrPadded%"
        EXIT /b
    )
GOTO :EOF

:Calculate_Display
SET "Console_Width="
SET /A LINECOUNT=0
FOR /F "tokens=1,2,*" %%A IN ('MODE CON') DO (SET /A LINECOUNT=!LINECOUNT!+1&IF !LINECOUNT! EQU 4 SET Console_Width=%%B)
SET "LINECOUNT="
SET "LINECOUNT="
GOTO :EOF

:Calculate_Dividers
REM Calculate Dividers
IF Console_Width GTR 89 (
	SET MAX_Display=Console_Width
	SET MAX_Menu_Width=90
	SET MenuTabs3=30
	SET MenuTabs10=9
	SET MenuTabs=8)
IF Console_Width GTR 120 (
	SET MAX_Display=120
	SET MAX_Menu_Width=120
	SET MenuTabs3=40
	SET MenuTabs10=12
	SET MenuTabs=10)
IF Console_Width LSS 90 (
	SET MAX_Display=Console_Width
	SET MAX_Menu_Width=60
	SET MenuTabs3=20
	SET MenuTabs10=6
	SET MenuTabs=6)
GOTO :EOF

:Calculate_Tabs
:: Dynamic Menu Display Settings
::Tab 1 Starting Column - Initial border - tabs
SET "Tab1S=%space%%colon%"
SET /A Tab1W=%MenuTabs%
::Tab 2 Options Column - space Option - 2
SET "Tab2S= "
SET /A Tab2W=2
:: Tab 3 Options Column - dash - tabs-2
SET "Tab3S=%eSign%"
SET /A Tab3W=%MenuTabs%-%Tab2W%
:: Tab 4 Done step indicator
SET "Tab4S=%space%"
SET /A Tab4W=%MenuTabs%
:: Tab 4 Choice Display Text  Menu width-Tab1W-Tab3W- TabFW
SET "Tab5S="  
SET /A Tab5W=%Max_Menu_Width%-%Tab1W%-%Tab3W%-12-%Tab4W%
:: Tab Final - closing column - 2
SET "TabFC=%colon%"
SET /A TabFW=1
SET "TabFS=%space%"
SET /A TabFW=1

SET /A Menu_Center=1000+MAX_Menu_Width-%Tab1W%-2

IF %_debug% EQU 1 (
ECHO:db Tab1S : %Tab1S%
ECHO:db Tab1W : %Tab1W%
ECHO:db Tab2S : %Tab2S%
ECHO:db Tab2W : %Tab2W%
ECHO:db Tab3S : %Tab3S%
ECHO:db Tab4S : %Tab4S%
ECHO:db Tab4W : %Tab4W%
ECHO:db Tab5S : %Tab5S%
ECHO:db Tab5W : %Tab5W%
) 

GOTO :EOF


:: -------------------------------
:: Graceful end of program
:: -------------------------------

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
ENDLOCAL
GOTO :EOF