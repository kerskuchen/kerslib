@echo off

if not defined DevEnvDir (
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
)

REM Load build flags
pushd "%~dp0"
call build_flags.cmd
popd

if not exist build mkdir build

clang main_sdl.cc -o build/launcher.exe %COMMON_DEBUG% %COMMON_WARNINGS% %LAUNCHER_EXTRA% %LAUNCHER_LINKER%  

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

exit

REM ================================================================================================
REM ================================================================================================
REM Old stuff for later reference

REM /wd4201: Nonstandard extension - namless struct/union
REM /wd4100: Unreferenced formal parameters
REM /wd4189: Unused local variable
REM /wd4390: Empty control statement
REM /wd4456: Shadowing of local variable
REM /wd4459: Hiding global declaration
REM /wd4505: Unreferenced local function
REM /wd4127: Conditional expression is constant
SET IGNORED_WARNINGS=/wd4201 /wd4100 /wd4189 /wd4390 /wd4456 /wd4459 /wd4505 /wd4127

REM /GR-: Disable RTTI
REM /EHa-: Disable exception handling overhead
REM /TP: Treat all files as CPP files
REM /Z7: Better (uncomplicated) debug symbols
REM /FC: Shows full file path for source files
REM /JMC: Just my code debugging - Don't step into non-user code
REM /diagnostics:caret: Shows prettier error messages with position information
REM /W4: Warning level 4
REM /WX: Treat warnings as errors
REM /Od: Disable optimizations
REM /Oi: Always use intrinsics (sin, cos, tan, etc.)
REM /O2: Optimized build
REM /fp:fast: Enables additional floating point optimizations
REM /sdl: Enables or disables additional compiletime and runtime security checks
REM /nologo: Disable CL startup message
REM /MD:  Dynamically link to CRT library
REM /MT:  Statically link to CRT library
REM /MTd: Dynamically link to CRT debug library
REM /MDd: Statically link to CRT debug library
REM /Gm-: Turn off incremental builds
REM /Fm: Create symbol map file
REM /LD: Create DLL
REM /Oy-: Keep frame pointer - Slightly slower but better for debugging
REM /Oy: Omit frame pointer - Slightly more performant but worse for debugging
REM /GS: Enable/Disable security checks for buffer overruns
REM /permissive-: Generate warnings when non-standard constructs are used
REM /Bt: Shows compile informations such as time to build
REM /RTC1: Runtime error checking (i.e. uninitialized variables)
REM /Fo object file path
REM /Fd platform pdb file path
SET GAME_RANDOM_ID=%random%

SET COMPILER_FLAGS_COMMON=/Zi /FC /JMC /W4 /WX /external:W4 /Oi /fp:fast /nologo /Gm- /permissive- /diagnostics:caret /GR- /EHa- /TP
SET COMPILER_FLAGS_DEBUG=%COMPILER_FLAGS_COMMON% /Od /Oy- /MDd /sdl /GS /RTC1 
SET COMPILER_FLAGS_OPTIMIZED=%COMPILER_FLAGS_COMMON% /O2 /Oy /MT /sdl- /GS- 

SET COMPILER_FLAGS_CURRENT=%COMPILER_FLAGS_DEBUG% %IGNORED_WARNINGS%
SET COMPILER_FLAGS_GAME=/Fo"trash\gamelib-%GAME_RANDOM_ID%.obj" /Fd"trash\gamelib-%GAME_RANDOM_ID%_vc.pdb"
SET COMPILER_FLAGS_LAUNCHER=/Fo"trash\launcher.obj" /Fd"trash\launcher-vc.pdb" /ID:\Creating\SDL2\include\ 



REM /subsystem:windows,5.2: Downward compatible version of subsystem:windows
REM /subsystem:console,5.2: Downward compatible version of subsystem:console
REM /opt:ref: Remove unneeded symbols from executable
REM /EXPORT Exports a function
REM /incremental:no: Disables incremental linking
REM /PDB pdb filepath
REM /MANIFEST /MANIFESTUAC:"..." /manifest:embed : Creates manifest in file
SET LINKER_FLAGS_COMMON=/link /opt:ref /incremental:no /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed 
SET LINKER_FLAGS_LAUNCHER=%LINKER_FLAGS_COMMON% shell32.lib /PDB:"trash\launcher.pdb" /LIBPATH:D:\Creating\SDL2\lib\x64\ /subsystem:console,5.2 
SET LINKER_FLAGS_GAME=/LDd %LINKER_FLAGS_COMMON% /PDB:"trash\gamelib-%GAME_RANDOM_ID%.pdb" /EXPORT:game_library_reloaded /EXPORT:game_get_memory_requirements /EXPORT:game_update_and_render

SET DEFINES_DEBUG=-DKERS_PLATFORM_WINDOWS=1 -DKERS_INTERNAL=1
SET DEFINES_OPTIMIZED=-DKERS_PLATFORM_WINDOWS=1 -DKERS_INTERNAL=1 
SET DEFINES_SHIPPING=-DKERS_PLATFORM_WINDOWS=1 -DKERS_INTERNAL=0

SET DEFINES_CURRENT=%DEFINES_DEBUG%

REM ================================================================================================


if not exist build mkdir build
pushd build
if exist trash del /S /Q trash > NUL 2> NUL
if not exist trash mkdir trash

REM hotreload_lock.tmp is used to make sure the gamelib.dll AND its corresponding .pdb file is created 
REM before we actually hotreload the game
echo WAITING FOR PDB > hotreload_lock.tmp

cl %COMPILER_FLAGS_CURRENT% %COMPILER_FLAGS_GAME% %DEFINES_CURRENT% ../code/gamelib.cc /Fegamelib %LINKER_FLAGS_GAME%

if %errorlevel% neq 0 (
    del hotreload_lock.tmp
    popd
    goto :error
)
echo SUCCESS: Compiled GameLib

del hotreload_lock.tmp

cl %COMPILER_FLAGS_CURRENT% %COMPILER_FLAGS_LAUNCHER% %DEFINES_CURRENT% ..\code\launcher.cc /Felauncher %LINKER_FLAGS_LAUNCHER% 
if %errorlevel% neq 0 (
    del hotreload_lock.tmp
    popd
    goto :error
)
echo SUCCESS: Compiled Launcher

popd

exit




REM ================================================================================================

goto :success

REM ------------------------------------------------------------------------------------------------
:error

echo Failed with error #%errorlevel%.
exit /b %errorlevel%

REM ------------------------------------------------------------------------------------------------
:success