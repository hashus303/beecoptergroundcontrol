@echo off
echo [BUILD] Initializing Visual Studio 2022 Environment...
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" x64
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to initialize VS environment.
    exit /b %ERRORLEVEL%
)

echo [BUILD] Setting up Python Scripts Path...
set PATH=C:\Users\hasan\AppData\Roaming\Python\Python314\Scripts;%PATH%

echo [BUILD] Running CMake Configuration (Disabling WERROR and Tests)...
call "C:\Qt\6.10.2\msvc2022_64\bin\qt-cmake.bat" -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DbeeCopter_ENABLE_WERROR=OFF -DbeeCopter_BUILD_TESTING=OFF
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] CMake configuration failed.
    exit /b %ERRORLEVEL%
)

echo [BUILD] Starting Build with Ninja...
cmake --build build --parallel
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed.
    exit /b %ERRORLEVEL%
)

echo [SUCCESS] Build completed successfully.
