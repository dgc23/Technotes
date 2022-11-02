# This will display the Syslog server on host.  Connect to vCenter before running.
$esx = Get-VMHost

foreach ($h in $esx){
  if (($h.connectionstate -eq "Connected") -or ($h.connectionstate -eq "Maintenance")){
    Get-VMHostSysLogServer -vmhost $h.Name |select @{N='Host Name'; E={$h.Name}},Host,Port
}else {
    Write-Host "Host " $h.name "current Connection State:" $h.connectionstate -ForegroundColor Red
}}
