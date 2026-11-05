@echo off
rem Starts MiiNSCC: quietly gets the latest version first, then opens it in your browser
rem at http://localhost:8765 (a tiny web server on this computer only: see serve.ps1).
rem (Double-click this instead of index.html. If there's no internet, it just opens the copy you have.)
rem (remember this folder first: Windows can lose track of it after changing folders)
set "HERE=%~dp0"
cd /d "%HERE%"
rem find Git (by name, or in its usual install folders: Windows doesn't always know it by name)
set "GIT=git"
where git >nul 2>nul || set "GIT="
if not defined GIT if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not defined GIT if exist "%ProgramFiles(x86)%\Git\cmd\git.exe" set "GIT=%ProgramFiles(x86)%\Git\cmd\git.exe"
if not defined GIT if exist "%LocalAppData%\Programs\Git\cmd\git.exe" set "GIT=%LocalAppData%\Programs\Git\cmd\git.exe"
if not defined GIT goto open
rem MiiNSCC moved to its own repository (github.com/sneekyedd/miinscc): switch this copy over
rem once, by itself. It's the same history, so nothing is lost.
"%GIT%" remote get-url origin 2>nul | findstr /i /c:"sneekyedd/mii-hub" >nul
if errorlevel 1 goto pull
"%GIT%" remote set-url origin https://github.com/sneekyedd/miinscc.git
"%GIT%" fetch --quiet origin main >nul 2>nul
"%GIT%" checkout --quiet -B main origin/main >nul 2>nul
:pull
"%GIT%" pull --ff-only --quiet >nul 2>nul
:open
rem the little web server (a minimized window: close it to stop MiiNSCC), then the browser
start "MiiNSCC server" /min powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%serve.ps1"
timeout /t 2 /nobreak >nul
start "" http://localhost:8765/
