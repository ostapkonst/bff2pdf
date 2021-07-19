@setlocal EnableExtensions
@echo off

set paused=true
set bff_file=

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

if "%*" == "" (
	echo Usage: run_all --bff_file [--pdf_file] [--paused]
	echo.
	echo Default: run_all --pdf_file=^<bff_file^>.pdf --paused=true
	echo.
	echo Options:
	echo     --bff_file=^<string^>
	echo     --pdf_file=^<string^>
	echo     --paused=[true^|false]

	if /i not "%paused%"=="false" pause > nul
	exit /b 0
)

set tmp_dir=tmp
set errors=1

echo START ALL

if "%bff_file%"=="" (
	echo.
	echo Param --bff_file must not be empty
	goto finish
)

if not exist %bff_file% (
	echo.
	echo Book file is not found. Enter correct --bff_file param
	goto finish
)

if "%pdf_file%"=="" (
	for %%f in (%bff_file%) do (
		set pdf_file=%%~dpnf.pdf
	)
)

for /f "tokens=1* delims=: " %%f in ('bin\bff2swf.py "%bff_file%" -t="%tmp_dir%" 2^>nul') do (
	if "%%f"=="Id" (
		set book_id=%%g
	)
)

if "%book_id%"=="" (
	echo.
	echo Failed to get book id. Apparently the format is not supported
	goto finish
)

set errors=0
set swf_file="%tmp_dir%\%book_id%.swf"
set png_dir="%tmp_dir%\%book_id%_png"
set pdf_dir="%tmp_dir%\%book_id%_pdf"

:start
@echo on

bin\bff2swf.py "%bff_file%" -o=%swf_file% -t="%tmp_dir%"
@set /a errors+=%errorlevel%
cmd /c bin\swf2png.bat --swf_file=%swf_file% --png_dir=%png_dir%
@set /a errors+=%errorlevel%
cmd /c bin\png2pdf.bat --png_dir=%png_dir% --pdf_dir=%pdf_dir%
@set /a errors+=%errorlevel%
bin\join_pdf.py --pdf_dir=%pdf_dir% --pdf_file="%pdf_file%"
@set /a errors+=%errorlevel%

:finish
@echo off
echo.
if %errors%==0 (
	echo FINISHED [OK]
) else (
	echo FINISHED [FAIL]
)
if /i not "%paused%"=="false" pause
exit /b %errors%
