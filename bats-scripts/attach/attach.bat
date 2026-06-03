@echo off & setlocal enabledelayedexpansion
:: --- paths --------------------------------------------------------
set "JDK=%~dp0gizmo-jdk"
set "JPS=%JDK%\bin\jps.exe"
set "JCMD=%JDK%\bin\jcmd.exe"
set "AGENT=%~dp0Gizmo.jar"

:: --- sanity check -------------------------------------------------
for %%T in ("%JPS%" "%JCMD%" "%AGENT%") do if not exist "%%~T" (
  echo Missing: %%~T
  pause & exit /b 1
)

:: --- find THE client ---------------------------------------------
echo Looking for Puzzle Pirates client...
for /f "tokens=1" %%P in (
  '"%JPS%" -l ^| findstr /i yohoho'
) do set PID=%%P

if "%PID%"=="" (
  echo No Puzzle Pirates client found.
  echo Please start the game and log in first.
  pause & exit /b 1
)

echo Found client with PID: %PID%

:: --- attach ------------------------------------------------------
echo Attaching Gizmo to PID %PID% ...
"%JCMD%" %PID% JVMTI.agent_load "%AGENT%" 2>&1
if %errorlevel%==0 (
  echo SUCCESS - Gizmo window will appear if already logged in.
) else (
  echo Attach failed - ensure game was started with -XX:+EnableDynamicAgentLoading
)
pause