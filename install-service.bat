@echo off
rem Copyright (C) 2019 Ping Identity Corporation
rem All rights reserved.

if not "%JAVA_HOME%" == "" goto TEST_VERSION
echo JAVA_HOME is not set.  Unexpected results may occur.
echo Set JAVA_HOME to the directory of your local Java installation to avoid this message.
goto :eof

:TEST_VERSION

set MINIMUM_JAVA_VERSION=1.8
set JAVA_11=11
set JAVA_10=10
set JAVA_9=9
set "PA_HOME=%~dp0..\.."

set JAVA_VERSION=
"%JAVA_HOME%/bin/java" -version 2>java_version.txt
for /f "tokens=3" %%g in (java_version.txt) do (
    del java_version.txt
    set JAVA_VERSION=%%g
    goto CHECK_JAVA_VERSION
)

rem grab first 3 characters of version number (ex: 1.6) and compare against required version
:CHECK_JAVA_VERSION
set JAVA_VERSION=%JAVA_VERSION:~1,3%

rem check the prefix to see if the version is in the JEP 322 format $FEATURE.$INTERIM.$UPDATE.$PATCH. General availability releases only contain $FEATURE so we should only grab it
rem check for GA of java 9 and 10 first to give helpful failure message
set JAVA_FIRST_CHAR=%JAVA_VERSION:~0,1%
set JAVA_VERSION_PREFIX=%JAVA_VERSION:~0,2%
if %JAVA_FIRST_CHAR% EQU %JAVA_9% goto WRONG_JAVA_VERSION
if %JAVA_VERSION_PREFIX% EQU %JAVA_10% goto WRONG_JAVA_VERSION

if %JAVA_VERSION_PREFIX% GEQ %JAVA_11% (
    set "JAVA=%JAVA_HOME%/bin/java"
    goto install
)

if %JAVA_VERSION% EQU %MINIMUM_JAVA_VERSION% (
    set "JAVA=%JAVA_HOME%/bin/java"
    goto install
)

:WRONG_JAVA_VERSION
echo Java %MINIMUM_JAVA_VERSION% or %JAVA_11% is required to run PingAccess but %JAVA_VERSION% was detected. Please set the JAVA_HOME environment variable to a Java %MINIMUM_JAVA_VERSION% or %JAVA_11% installation directory path.
exit /B 1

:install
call "%PA_HOME%\sbin\windows\wrapper-service.bat"
