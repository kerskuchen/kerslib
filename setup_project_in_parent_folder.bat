@echo off

robocopy .\project\ ..\ "launch_vscode.bat"
robocopy .\project\ ..\ ".clang-format"
robocopy .\project\.vscode ..\.vscode /s /e
echo DO NOT EDIT > ..\.vscode\GENERATED_FILES_DO_NOT_EDIT.tmp

pause