@echo off
set PATH=C:\Qt\6.10.2\msvc2022_64\bin;C:\VulkanSDK\latest\Bin;%PATH%
echo [RUN] Launching beeCopter GCS...
start "" "%~dp0build\Debug\beeCopter.exe"
