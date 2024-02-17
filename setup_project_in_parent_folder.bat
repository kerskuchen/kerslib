@echo off

robocopy .\project\ ..\ "launch_vscode.bat"
robocopy .\project\.vscode ..\.vscode /s /e

pause