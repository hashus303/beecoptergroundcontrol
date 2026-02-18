@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" x64
set PATH=C:\Users\hasan\AppData\Roaming\Python\Python314\Scripts;%PATH%
ninja -C build > build_error.log 2>&1
