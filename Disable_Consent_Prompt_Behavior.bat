@echo off
set "regfile=%temp%\settings.reg"
(
  echo Windows Registry Editor Version 5.00
  echo.
  echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
  echo "ConsentPromptBehaviorAdmin"=dword:00000000
  echo "ConsentPromptBehaviorUser"=dword:00000003
  echo "EnableInstallerDetection"=dword:00000001
  echo "EnableLUA"=dword:00000001
  echo "EnableVirtualization"=dword:00000001
  echo "PromptOnSecureDesktop"=dword:00000001
  echo "ValidateAdminCodeSignatures"=dword:00000000
  echo "FilterAdministratorToken"=dword:00000000
) > "%regfile%"

echo Importing registry settings...
reg import "%regfile%"

echo Registry settings imported successfully.
del "%regfile%"
