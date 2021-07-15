@setlocal EnableExtensions EnableDelayedExpansion
@echo off

:: Convert many *.png file to many *.pdf files
:: Need to be located next to the bin folder

set convert="bin\convert.exe"
set png_dir=
set pdf_dir=

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

echo START CONVERTING PNGs-^>PDFs

if "%png_dir%"=="" (
	echo Param --png_dir must not be empty
	goto finish
)

if "%pdf_dir%"=="" (
	echo Param --pdf_dir must not be empty
	goto finish
)

if not exist %convert% (
	echo convert not found in path: %convert%
	goto finish
)

set errors=0
set cnt=0

mkdir "%pdf_dir%" >nul 2>&1

for /r "%png_dir%" %%f in (*.png) do set /a cnt+=1
if !cnt!==0 (
	echo NO PNG FILES TO CONVERT
	goto finish
)

set curr=0
for /r "%png_dir%" %%f in (*.png) do (
	set /a curr+=1
	echo | set /p=!curr!/!cnt!^) FILE: %%~nxf
	if exist "%pdf_dir%\%%~nf.pdf" (
		echo. [SKIPED]
	) else (
		%convert% "%%f" "%pdf_dir%\%%~nf.pdf" >nul 2>&1
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
