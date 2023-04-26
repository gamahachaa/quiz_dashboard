%1

@echo off

set DEV=1
rem goto :completed

rem PREPARE DATESTAMP ------------------------------------------------------------------------------------------------------------------------------
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

rem ------------------ DEFINE FILE NAMES ------------------------------------------------------------------------
:: COPY TO SUB
set serverFolderName=quiz_dashboard
set mainScript=quiz_dashboard
rem -------------------------------------------------------------------------------------------------------------
set oldScriptName=%mainScript%
set newScriptName=%mainScript%_%fullstamp%
set newScriptNameMin=%mainScript%_%fullstamp%.min

set newMapName=%mainScript%_%fullstamp%.js.map

rem set oldmeta=^<meta name^=\"description\" content=\"\" \/^>
set oldmeta="`<meta name="description" content="" /`>"
set newmeta="`<meta name="description" content="" /`>`<link rel="icon" type="image/png" href="favicon.png"`>"

echo %oldmeta%
echo %newmeta%

rem PREPARE and CLEAR OLD FILE removal  -------------------------------------------------------------------------
:: COPY TO SUB
rem set BINDIR=%cd%\bin\
set BINDIR=bin
rem set ASSETSDIR=%BINDIR%\assets\
set FILESDELETE=%BINDIR%\%mainScript%_20*

rem --------- ^ is the escape char for batch !!! --------------
rem set "HOWL_TARGET=^<link rel="shortcut icon" type="image/png" href="./favicon.png"^>"
rem set "HOWL=^<script type="text/javascript" src="./howl.js"^>^</script^>
rem DELETE  ------------------------------------------------------------------------------------------------------------------------------
rem if "%1"=="debug" goto :next
del /F %FILESDELETE%

rem powershell -Command "(gc %BINDIR%/index.html) -replace '%oldmeta%', '%newmeta%' | Out-File -encoding UTF8 %BINDIR%/index.html"

echo "START"
if %DEV%==2 (
   goto :publication
)
if %DEV%==1 (
	if "%1"=="" goto :dead
	if "%1"=="debug" goto :dead
	if "%1"=="release" goto :publication
) ELSE ( 
	if "%1"=="" goto :dead
	if "%1"=="debug" goto :publication
	if "%1"=="release" goto :publication
)


:publication



:next

rem REPLACE META LINK TO JS FILES  ------------------------------------------------------------------------------------------------------------------------------
rem powershell -Command "Rename-Item -Path "%BINDIR%/index.html" -NewName tmp.html"
rem powershell -Command "Rename-Item -Path "%BINDIR%/index_howl.html" -NewName index.html"
rem powershell -Command "Rename-Item -Path "%BINDIR%/tmp.html" -NewName index_howl.html"


rem powershell -Command "(gc %BINDIR%/index.html) -replace '%HOWL_TARGET%', '%HOWL_TARGET%\n%HOWL%' | Out-File -encoding UTF8 %BINDIR%/index.html"


echo "DEV=%DEV%"



if "%1"=="release" goto :minify
	rem powershell -Command "(gc %BINDIR%/index.html) -replace '%oldScriptName%[0-9a-z_.]*\.js', '%newScriptName%.js' | Out-File -encoding UTF8 %BINDIR%/index.html"
if "%1"=="debug" goto :NOTMINIFY




:minify
echo MINIFY
powershell -Command "(gc %BINDIR%/index.html) -replace '%oldScriptName%[0-9a-z_.]*\.js', '%newScriptNameMin%.js' | Out-File -encoding UTF8 %BINDIR%/index.html"
powershell -Command "Rename-Item -Path "%BINDIR%/%mainScript%.min.js" -NewName %newScriptNameMin%.js"
goto :EXPORT

:NOTMINIFY
echo MINIFY_NOT
powershell -Command "(gc %BINDIR%/index.html) -replace '%oldScriptName%[0-9a-z_.]*\.js', '%newScriptName%.js' | Out-File -encoding UTF8 %BINDIR%/index.html"
powershell -Command "Rename-Item -Path "%BINDIR%/%mainScript%.js" -NewName %newScriptName%.js"
rem powershell -Command "Rename-Item -Path "%BINDIR%/%mainScript%.js.map" -NewName %newMapName%"

:EXPORT


if %DEV%==2 (
   goto :testprod
)
if %DEV%==1 (
	if "%1"=="" goto :dead
	if "%1"=="debug" goto :dead
	if "%1"=="release" goto :test
) ELSE ( 
	if "%1"=="" goto :dead
	if "%1"=="debug" goto :test
	if "%1"=="release" goto :release
)

rem echo %1

:testprod
call send_prod_test.bat "%1 %DEV% %BINDIR% %serverFolderName%"

goto :completed

:test
call send_test.bat "%1 %DEV% %BINDIR% %serverFolderName%"

goto :completed

:release
rem PUSH to PROD SERVER 
call send_prod.bat "%1 %DEV% %BINDIR% %serverFolderName%"

rem robocopy export\html5\bin "C:\xampp\htdocs\localhost" * /E

goto :completed

:end

rem echo "JUST DEBUGGING"

:dead

powershell -Command "(gc %BINDIR%/index.html) -replace '%oldScriptName%[0-9a-z_.]*\.js', '%newScriptName%.js' | Out-File -encoding UTF8 %BINDIR%/index.html"
powershell -Command "Rename-Item -Path "%BINDIR%/%mainScript%.js" -NewName %newScriptName%.js"
rem powershell -Command "Rename-Item -Path "%BINDIR%/%mainScript%.js.map" -NewName %newMapName%

rem echo "NO DIRECTIVES"

:completed

echo "completed %1"