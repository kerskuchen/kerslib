@echo off

if not exist build mkdir build

robocopy .\kerslib .\build "index.html"
robocopy .\kerslib .\build "index.js"

REM Load build flags
pushd "%~dp0"
call build_flags.cmd
popd

clang -c kerslib/thirdparty/walloc.c -o build/walloc.obj %COMMON_DEBUG% %GAMELIB_WEB%
clang game.cc build/walloc.obj -o build/game.wasm %COMMON_WARNINGS% %COMMON_DEBUG% %GAMELIB_WEB% %GAMELIB_LINKER% %GAMELIB_EXPORTS%


if %errorlevel% neq 0 (
    popd
    goto :error
)

echo SUCCESS: Compiled Web
popd


REM ================================================================================================

goto :success

REM ------------------------------------------------------------------------------------------------
:error

echo Failed with error #%errorlevel%.
exit /b %errorlevel%

REM ------------------------------------------------------------------------------------------------
:success
