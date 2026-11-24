@echo off
chcp 65001 >nul
title Games Crusher 97 - Upload website
echo.
echo  ===============================================
echo    Games Crusher 97 - website upload (GitHub)
echo  ===============================================
echo.

set "SRC=%~dp0"
set "REPO=D:\Backup\Website-upload-repo"
set "URL=https://github.com/gamescrusher97/GamesCrusher97.git"

where git >nul 2>nul
if errorlevel 1 (
  echo  [X] Git is not installed on this computer.
  goto :end
)

rem ---- 1. get the latest copy of the website from GitHub ----
if not exist "%REPO%\.git" (
  echo  Downloading the website from GitHub the first time...
  git clone -q "%URL%" "%REPO%"
  if errorlevel 1 ( echo  [X] Could not download from GitHub. Check the internet. & goto :end )
) else (
  echo  Getting the latest copy from GitHub...
  git -C "%REPO%" fetch -q origin
  if errorlevel 1 ( echo  [X] Could not reach GitHub. Check the internet. & goto :end )
  git -C "%REPO%" reset -q --hard origin/main
)

rem ---- 2. copy ONLY the website files (never gmb-admin-server or firebase) ----
echo  Copying the website files...
rem everything in this folder EXCEPT the private server code, Firebase settings and this .bat file
robocopy "%SRC%." "%REPO%" /E /XD gmb-admin-server firebase .git .claude node_modules/XF *.bat *.zip *.py *.log /NFL /NDL /NJH /NJS /NP >nul

rem ---- 3. send the changes ----
git -C "%REPO%" add -A 2>nul
git -C "%REPO%" diff --cached --quiet
if not errorlevel 1 (
  echo.
  echo  [OK] Nothing new - the website is already up to date.
  goto :end
)
echo.
echo  These files changed:
git --no-pager -C "%REPO%" diff --cached --stat
echo.
git -C "%REPO%" -c user.name=gamescrusher97 -c user.email=gamescrusher97@gmail.com commit -q -m "Website update %date% %time%"
echo  Uploading...
git -C "%REPO%" push -q origin HEAD:main
if errorlevel 1 ( echo  [X] Upload failed. If a GitHub login window opened, log in and run this file again. & goto :end )
echo.
echo  [OK] Uploaded! The website updates in about 1-2 minutes:
echo       https://gamescrusher97.com

:end
echo.
pause
