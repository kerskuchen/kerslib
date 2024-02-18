@echo off

if not defined DevEnvDir (
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
)

if not exist build mkdir build

clang -g main_sdl.cc -o build/launcher.exe -lSDL2main -lSDL2 -Xlinker /subsystem:console -MJ build/compile_commands.json

exit

pushd build
if exist trash del /S /Q trash > NUL 2> NUL
if not exist trash mkdir trash

REM hotreload_lock.tmp is used to make sure the gamelib.dll AND its corresponding .pdb file is created 
REM before we actually hotreload the game
echo WAITING FOR PDB > hotreload_lock.tmp
msbuild ../project_windows/launcher.vcxproj /nologo /p:configuration=InternalGameLib /p:platform=x64

if %errorlevel% neq 0 (
    del hotreload_lock.tmp
    popd
    goto :error
)
echo SUCCESS: Compiled GameLib

del hotreload_lock.tmp

msbuild ../project_windows/launcher.vcxproj /nologo /p:configuration=InternalLauncher /p:platform=x64 
if %errorlevel% neq 0 (
    popd
    goto :error
)
echo SUCCESS: Compiled Launcher

popd

REM ================================================================================================

goto :success

REM ------------------------------------------------------------------------------------------------
:error

echo Failed with error #%errorlevel%.
exit /b %errorlevel%

REM ------------------------------------------------------------------------------------------------
:success
