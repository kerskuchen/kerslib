@echo off

if not exist build mkdir build
pushd build

REM -sASSERTIONS=2 -sSAFE_HEAP=1 
REM emcc -g -gsource-map -DKERS_PLATFORM_WEB=1 -DKERS_INTERNAL=1 ..\src\main.cc -o index.html -sSTACK_SIZE=1048576 -sUSE_SDL=2 -sFULL_ES2=1 -sALLOW_MEMORY_GROWTH -DMA_ENABLE_AUDIO_WORKLETS -sAUDIO_WORKLET=1 -sWASM_WORKERS=1 -sASYNCIFY -sUSE_PTHREADS --preload-file data
emcc -g -gsource-map -I..\kerslib\ -DKERS_PLATFORM_WEB=1 -DKERS_INTERNAL=1 ..\src\main.cc -o index.html -sSTACK_SIZE=1048576 -sUSE_SDL=2 -sFULL_ES2=1 -sALLOW_MEMORY_GROWTH --preload-file data

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
