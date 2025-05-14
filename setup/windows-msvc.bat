@echo off
color 0a
cd ..

echo ========================================
echo Installing Microsoft Visual Studio Community (Dependency)
echo ========================================

REM -- Download Visual Studio Installer --
goto RetryDownload

:RetryDownload
curl -# -L -o vs_Community.exe https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe

IF NOT EXIST vs_Community.exe (
    echo Failed to download Visual Studio Installer.
    echo Retrying...
    timeout /t 5 >nul
    goto RetryDownload
)

REM -- Install Required Components Only --
vs_Community.exe --quiet --wait --norestart --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041

REM -- Cleanup --
del vs_Community.exe

echo.
echo ========================================
echo Visual Studio components installed.
echo ========================================