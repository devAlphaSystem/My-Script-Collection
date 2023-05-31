@echo off

echo This script requires administrator privileges to fix Windows Update.
echo Make sure to run this script as an administrator.

echo Checking Administrator privileges...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Administrator privileges confirmed.
) else (
    echo This script must be run as an Administrator.
    echo Please rerun this script as an Administrator.
    pause
    exit /b
)

echo Setting TrustedInstaller to start automatically...

SC config trustedinstaller start=auto || (
    echo Failed to set TrustedInstaller to start automatically.
    pause
    exit /b
)

echo Done.

echo Stopping services...

for %%i in (bits wuauserv msiserver cryptsvc appidsvc) do (
    net stop %%i || (
        echo Failed to stop service %%i.
        pause
        exit /b
    )
)

echo Services stopped.

echo Renaming SoftwareDistribution and catroot2 folders...

for %%i in (SoftwareDistribution catroot2) do (
    if exist "%SystemRoot%\%%i" (
        ren "%SystemRoot%\%%i" %%i.old || (
            echo Failed to rename %%i folder.
            pause
            exit /b
        )
    )
)

echo Renaming done.

echo Registering DLLs...

for %%i in (atl.dll urlmon.dll mshtml.dll) do (
    regsvr32.exe /s %%i || (
        echo Failed to register DLL %%i.
        pause
        exit /b
    )
)

echo DLLs registered.

echo Resetting Winsock...

netsh winsock reset || (
    echo Failed to reset Winsock.
    pause
    exit /b
)
netsh winsock reset proxy || (
    echo Failed to reset Winsock proxy.
    pause
    exit /b
)

echo Winsock reset.

echo Running PnpClean...

rundll32.exe pnpclean.dll,RunDLL_PnpClean /DRIVERS /MAXCLEAN || (
    echo Failed to run PnpClean.
    pause
    exit /b
)

echo PnpClean completed.

echo Running DISM...

for %%i in (/ScanHealth /CheckHealth /RestoreHealth /StartComponentCleanup) do (
    dism /Online /Cleanup-image %%i || (
        echo Failed to run DISM command %%i.
        pause
        exit /b
    )
)

echo DISM finished.

echo Running System File Checker...

sfc /scannow || (
    echo Failed to run System File Checker.
    pause
    exit /b
)

echo System File Checker completed.

echo Starting services...

for %%i in (bits wuauserv msiserver cryptsvc appidsvc) do (
    net start %%i || (
        echo Failed to start service %%i.
        pause
        exit /b
    )
)

echo Services started.

echo Windows Update should now be fixed. Please restart your computer.
