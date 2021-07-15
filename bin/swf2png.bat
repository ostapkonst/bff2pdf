@setlocal EnableExtensions EnableDelayedExpansion
@echo off

:: Convert single *.swf file to many *.png files
:: Need to be located next to the bin folder

set swfdump="bin\swfdump.exe"
set swfrender="bin\swfrender.exe"
set swf_file=
set png_dir=

:cmd_params
if not %1/==/ (
	if not "%__var%"=="" (
		if not "%__var:~0,2%"=="--" (
			endlocal
			goto cmd_params
		)
		endlocal & set %__var:~2%=%~1
	) else (
		setlocal & set __var=%~1
	)
	shift
	goto cmd_params
)

set errors=1

echo START CONVERTING SWF-^>PNGs

if "%swf_file%"=="" (
	echo Param --swf_file must not be empty
	goto finish
)

if "%png_dir%"=="" (
	echo Param --png_dir must not be empty
	goto finish
)

if not exist %swfdump% (
	echo swfdump not found in path: %swfdump%
	goto finish
)

if not exist %swfrender% (
	echo swfrender not found in path: %swfrender%
	goto finish
)

if not exist "%swf_file%" (
	echo File "%swf_file%" does not exist
	goto finish
)

set errors=0
set cnt=0

mkdir "%png_dir%" >nul 2>&1

for /f "tokens=2" %%g in ('%swfdump% -f %swf_file%') do set cnt=%%g
if %cnt%==0 (
	echo NO FRAMES TO CONVERT
	goto finish
)

set curr=0
for /l %%g in (1, 1, %cnt%) do (
	set /a curr+=1
	echo | set /p=!curr!/%cnt%^) FRAME: %%g
	if exist "%png_dir%\%%g.png" (
		echo. [SKIPED]
	) else (
		%swfrender% -r 240 -p %%g "%swf_file%" -o "%png_dir%\%%g.png" >nul 2>&1
		if !errorlevel!==0 (
			echo. [OK]
		) else (
			set /a errors+=1
			echo. [FAIL]
		)
	)
)

:finish
echo STOP CONVERTING [%errors%]
exit /b %errors%
