@echo off
setlocal enabledelayedexpansion
echo ============================================
echo Creating custom JRE with java.instrument
echo ============================================
echo.

set "SOURCE_JDK=C:\Users\Admin\.jdks\openjdk-25.0.1"
set "JLINK=%SOURCE_JDK%\bin\jlink.exe"
set "OUTPUT=%~dp0custom-runtime"

if not exist "%JLINK%" (
    echo ERROR: jlink not found at: %JLINK%
    echo Make sure gizmo-jdk is a full JDK, not just a JRE
    pause
    exit /b 1
)

echo Reading modules from game-jre-modules.txt...
echo.

if not exist game-jre-modules.txt (
    echo ERROR: game-jre-modules.txt not found!
    echo Run list-modules.bat first!
    pause
    exit /b 1
)

:: Build module list from file
set "MODULES="
for /f "tokens=1 delims=@" %%m in (game-jre-modules.txt) do (
    if not "%%m"=="" (
        if "!MODULES!"=="" (
            set "MODULES=%%m"
        ) else (
            set "MODULES=!MODULES!,%%m"
        )
    )
)

:: Add java.instrument
set "MODULES=!MODULES!,java.instrument"

echo Modules to include:
echo !MODULES!
echo.

:: Remove old output if exists
if exist "%OUTPUT%" (
    echo Removing old custom-runtime...
    rd /s /q "%OUTPUT%"
)

echo.
echo Creating custom JRE with jlink...
echo This may take a minute...
echo.

"%JLINK%" --module-path "%SOURCE_JDK%\jmods" --add-modules !MODULES! --output "%OUTPUT%" --compress=2 --strip-debug

if errorlevel 1 (
    echo.
    echo ERROR: jlink failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo SUCCESS!
echo.
echo Custom JRE created at: %OUTPUT%
echo.
echo This JRE includes all game modules PLUS java.instrument
echo.
echo Next steps:
echo 1. Test it by replacing game's runtime folder
echo 2. Or send to devs to integrate
echo ============================================
pause