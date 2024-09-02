@echo off
setlocal enabledelayedexpansion

REM Define log file
set LOGFILE=%~dp0run_log.txt
echo Log file created at: %LOGFILE%

REM Print a message to indicate the start of the services
echo Starting services... >> %LOGFILE%
echo Starting services...

REM Navigate to the script directory
cd /d "%~dp0"
echo Navigated to script directory: %cd% >> %LOGFILE%
echo Navigated to script directory: %cd%

REM Load environment variables from .env file
set ENV_FILE="%~dp0\..\.env"
if exist %ENV_FILE% (
    echo Loading environment variables from .env file... >> %LOGFILE%
    for /f "tokens=1,2 delims==" %%A in ('type %ENV_FILE%') do (
        set %%A=%%B
        echo Loaded %%A=%%B >> %LOGFILE%
    )
    echo All environment variables loaded. >> %LOGFILE%
    echo All environment variables loaded.
) else (
    echo Error: .env file not found at %ENV_FILE%. >> %LOGFILE%
    echo Error: .env file not found at %ENV_FILE%.
    pause
    exit /b 1
)

REM Stop any running Flask or Node.js processes
echo Stopping any running services... >> %LOGFILE%
taskkill /F /IM python.exe /T >> %LOGFILE% 2>&1
taskkill /F /IM node.exe /T >> %LOGFILE% 2>&1

REM Add a short delay to avoid potential conflicts
timeout /T 3 /NOBREAK >nul

REM 1. Activate Python virtual environment
echo Activating Python virtual environment... >> %LOGFILE%
call "%~dp0\..\Search_Env\Scripts\activate.bat" >> %LOGFILE% 2>&1

if %ERRORLEVEL% neq 0 (
    echo Error: Python virtual environment activation failed. >> %LOGFILE%
    echo Error: Python virtual environment activation failed.
    pause
    exit /b %ERRORLEVEL%
)
echo Python virtual environment activated. >> %LOGFILE%

REM 2. Start the Python Flask service in a new command window
echo Starting Python Flask service in a new window... >> %LOGFILE%
start cmd /k "cd /d %~dp0\.. & python semantic_search.py & echo Python Flask service running. & pause"

REM Add a delay to ensure Flask service starts
timeout /T 5 /NOBREAK >nul

REM 3. Start the Node.js API server in a new command window
echo Starting Node.js server in a new window... >> %LOGFILE%
start cmd /k "cd /d %~dp0\.. & npm start & echo Node.js server running. & pause"

REM Add a delay to ensure Node.js service starts
timeout /T 5 /NOBREAK >nul

REM Check if services started successfully
if %ERRORLEVEL% neq 0 (
    echo Services failed to start. >> %LOGFILE%
    echo Services failed to start.
    pause
    exit /b %ERRORLEVEL%
)
echo Services started successfully. Node.js running on port %NODE_PORT% and Flask running on port %FLASK_PORT%. >> %LOGFILE%
pause
