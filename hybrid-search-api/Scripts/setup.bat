@echo off
setlocal enabledelayedexpansion

REM Define log file
set LOGFILE=setup_log.txt

REM Print a message to indicate the start of the setup process
echo Starting setup process... > %LOGFILE%
echo Starting setup process...

REM Navigate to the project root directory
cd /d "%~dp0\.."
echo Navigated to project root: %cd% >> %LOGFILE%
echo Navigated to project root: %cd%

REM Ensure we're in the project root directory
if not exist ".env" (
    echo Error: .env file not found in the project root directory. >> %LOGFILE%
    echo Error: .env file not found in the project root directory.
    pause
    exit /b 1
)

REM Load environment variables
for /f "tokens=1,2 delims==" %%A in ('type ".env"') do (
    set %%A=%%B
    echo Loaded %%A=%%B >> %LOGFILE%
)

echo All environment variables loaded. >> %LOGFILE%
echo All environment variables loaded.

REM Install Node.js dependencies using CALL
echo Installing Node.js dependencies... >> %LOGFILE%
call npm install >> %LOGFILE% 2>&1

REM Simple echo after npm install to ensure it continues
echo npm install completed, checking script continuation... >> %LOGFILE%
echo npm install completed, checking script continuation...

if %ERRORLEVEL% neq 0 (
    echo npm install failed. >> %LOGFILE%
    echo npm install failed.
    pause
    exit /b %ERRORLEVEL%
)

echo npm install completed successfully. >> %LOGFILE%
echo npm install completed successfully.

REM Setup Python environment and install dependencies
echo Setting up Python virtual environment... >> %LOGFILE%
call python -m venv Search_Env >> %LOGFILE% 2>&1

if %ERRORLEVEL% neq 0 (
    echo python -m venv failed. >> %LOGFILE%
    echo python -m venv failed.
    pause
    exit /b %ERRORLEVEL%
)

echo Python virtual environment created. >> %LOGFILE%
echo Python virtual environment created.

REM Activate Python virtual environment
call Search_Env\Scripts\activate.bat >> %LOGFILE% 2>&1
echo Python virtual environment activated. >> %LOGFILE%
echo Python virtual environment activated.

REM Install Python dependencies
pip install -r requirements.txt >> %LOGFILE% 2>&1

if %ERRORLEVEL% neq 0 (
    echo pip install failed. >> %LOGFILE%
    echo pip install failed.
    pause
    exit /b %ERRORLEVEL%
)

echo pip install completed successfully. >> %LOGFILE%
echo pip install completed successfully.

REM Final pause to keep the command window open after completion
echo Setup completed successfully. >> %LOGFILE%
echo Setup completed successfully.
pause
