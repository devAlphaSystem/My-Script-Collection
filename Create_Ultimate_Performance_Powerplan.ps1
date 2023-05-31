Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

Clear-Host

# Set Ultimate Performance Power Plan
Write-Host 'Setting Ultimate Performance Power Plan...'

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  # Relaunch as an elevated process:
  Start-Process powershell.exe '-File', ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

# Define the Ultimate Performance Power Scheme GUID
$ultimatePerformanceSchemeGuid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'

# Check if the Ultimate Performance Power Scheme already exists
try {
  $schemeExists = $null -ne (powercfg /list | Select-String -Pattern $ultimatePerformanceSchemeGuid)
}
catch {
  Write-Error "Failed to check the existence of the Ultimate Performance Power Scheme: $_"
  Exit
}

if (-not $schemeExists) {
  # Create the Ultimate Performance Power Scheme
  try {
    powercfg.exe -duplicatescheme $ultimatePerformanceSchemeGuid | Out-Null
  }
  catch {
    Write-Error "Failed to create the Ultimate Performance Power Scheme: $_"
    Exit
  }
}

# Set the active power scheme to Ultimate Performance
try {
  powercfg -setactive $ultimatePerformanceSchemeGuid
}
catch {
  Write-Error "Failed to set the active power scheme to Ultimate Performance: $_"
  Exit
}

# Update settings
$monitorTimeout = 0
$standbyTimeout = 0
$hibernateTimeout = 0

# Validate inputs
if ($monitorTimeout -lt 0 -or $standbyTimeout -lt 0 -or $hibernateTimeout -lt 0) {
  Write-Error 'Timeout values must be non-negative integers'
  Exit
}

# Apply settings
try {
    (powercfg /x monitor-timeout-ac $monitorTimeout) -replace '.*:(.+)', '$1' | Write-Host
}
catch {
  Write-Error "Failed to set monitor timeout: $_"
}

try {
    (powercfg /x standby-timeout-ac $standbyTimeout) -replace '.*:(.+)', '$1' | Write-Host
}
catch {
  Write-Error "Failed to set standby timeout: $_"
}

try {
    (powercfg /x hibernate-timeout-ac $hibernateTimeout) -replace '.*:(.+)', '$1' | Write-Host
}
catch {
  Write-Error "Failed to set hibernate timeout: $_"
}

Write-Host 'Ultimate Performance Power Plan settings added. Please enable it on power settings.' -ForegroundColor Green
