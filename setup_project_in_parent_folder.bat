@echo off

REM NOTE: make sure our current working directory is the same as our batchfile directory
cd /D "%~dp0"

robocopy .\project\ ..\ "launch_vscode.bat"
robocopy .\project\ ..\ ".clang-format"
robocopy .\project\ ..\ ".gitignore"
robocopy .\project\.vscode ..\.vscode /s /e
echo DO NOT EDIT > ..\.vscode\GENERATED_FILES_DO_NOT_EDIT

pause