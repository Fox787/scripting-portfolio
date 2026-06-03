@echo off
setlocal
:: --- our private mini-JDK -----------------------------------------
set "JDK=%~dp0gizmo-jdk"
set "JPS=%JDK%\bin\jps.exe"
set "JCMD=%JDK%\bin\jcmd.exe"

:: --- find THE client ---------------------------------------------
echo Looking for Puzzle Pirates client...
for /f "tokens=1" %%P in (
  '"%JPS%" -l ^| findstr /c:com.threerings.yohoho.client.YoApp'
) do set PID=%%P

if "%PID%"=="" (
  echo No Puzzle Pirates client found.
  echo Please start the game and log in first.
  pause
  exit /b 1
)

echo Found client with PID: %PID%
echo.
echo ===== GAME JAVA VERSION =====
"%JCMD%" %PID% VM.version
echo.
echo ===== JVM FLAGS (checking for EnableDynamicAgentLoading) =====
"%JCMD%" %PID% VM.flags | findstr /i "DynamicAgent"
echo.
echo ===== ALL JVM FLAGS =====
"%JCMD%" %PID% VM.flags
echo.
echo ===== SYSTEM PROPERTIES =====
"%JCMD%" %PID% VM.system_properties | findstr /i "java.version java.home"
echo.
echo ===== YOUR GIZMO-JDK JAVA VERSION =====
"%JDK%\bin\java.exe" -version
echo.
echo.
echo CRITICAL: Look above for "EnableDynamicAgentLoading"
echo If it's missing or "false", the game client didn't get the flag!
echo.
pause
