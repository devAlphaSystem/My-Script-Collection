# Set script to stop on errors
$ErrorActionPreference = 'Stop'

try {
  # Get the IP address of the WSL 2 instance
  $remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
  $found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

  if (-not $found) {
    Write-Host 'The Script Exited, the IP address of WSL 2 cannot be found'
    exit
  }

  $remoteport = $matches[0]

  # Ports to forward
  $ports = @(80, 443, 10000, 3000, 5000)
  $addr = '0.0.0.0'
  $ports_a = $ports -join ','

  # Remove existing firewall rule
  Invoke-Expression "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock'"

  # Add new firewall rules
  Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $ports_a -Action Allow -Protocol TCP"
  Invoke-Expression "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $ports_a -Action Allow -Protocol TCP"

  # Configure port forwarding
  foreach ($port in $ports) {
    Invoke-Expression "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr"
    Invoke-Expression "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$remoteport"
  }

  Write-Host 'WSL 2 Ethernet has been fixed.'
}
catch {
  Write-Host "An error occurred: $_"
  exit 1
}
