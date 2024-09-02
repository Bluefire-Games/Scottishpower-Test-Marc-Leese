@echo off
setlocal

REM Get the directory of the current script
set SCRIPT_DIR=%~dp0

REM Set the path for the PostgreSQL executables
set PATH=%PATH%;C:\Program Files\PostgreSQL\16\bin

REM Ensure we have all the environment variables
if "%DB_USER%"=="" set DB_USER=postgres
if "%DB_NAME%"=="" set DB_NAME=TestDB
if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_PORT%"=="" set DB_PORT=5432
if "%DB_PASS%"=="" set DB_PASS=Scottishpower

REM Define the relative paths to your SQL files
set schema_file="%SCRIPT_DIR%Schema.sql"
set load_data_file="%SCRIPT_DIR%LoadData.sql"

REM Step 1: Run the Schema.sql script to set up the database schema
echo ==============================================
echo Running Schema.sql to set up the database schema...
echo ==============================================
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f %schema_file%
if %ERRORLEVEL% NEQ 0 (
    echo Failed to execute Schema.sql. Exiting...
    pause
    exit /b %ERRORLEVEL%
)
echo.
echo Schema.sql executed successfully.
echo.

REM Step 2: Run the LoadData.sql script to load the CSV data
echo ==============================================
echo Running LoadData.sql to load CSV data...
echo ==============================================
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f %load_data_file%
if %ERRORLEVEL% NEQ 0 (
    echo Failed to execute LoadData.sql. Exiting...
    pause
    exit /b %ERRORLEVEL%
)
echo.
echo LoadData.sql executed successfully.
echo.

REM Pause to prevent the window from closing
echo ==============================================
echo Script execution completed. Press any key to exit.
echo ==============================================
pause

endlocal
