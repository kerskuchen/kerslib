@echo off

REM ////////////////////////////////////////////////////////////////////////////////////////////////
REM // WARNING: This file was copied from `./kerslib/project/` directory and should not be edited
REM ////////////////////////////////////////////////////////////////////////////////////////////////

if not defined DevEnvDir (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
)

start code .
exit