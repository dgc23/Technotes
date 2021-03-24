# This script will patch ESXi Host based on cluster.

Write-Host "Please Provide cluster name"
$c = Read-Host
$i = Get-Cluster -Name $c |Get-VMHost


Get-Cluster -Name $c |get-vm |where {$_.ExtensionData.Runtime.ToolsInstallerMounted -eq $true} |Dismount-Tools


foreach ($j in $i){

if ((Get-Compliance -Entity $j.name -ComplianceStatus NotCompliant).Baseline.Name -eq $null){
Write-Host "No patchse needed for" $j -ForegroundColor Cyan
}else{
Write-Host "Starting to patch"$j.Name -ForegroundColor Green

#Checking current host connection status.
$vmh = Get-VMHost -Name $j.Name |select ConnectionState
Write-Host "Current Host State:" $j.ConnectionState

#Place Host into Maintence Mode if needed.
if ((Get-VMHost -Name $j.Name |select ConnectionState) -eq 'Connected'){
Write-Host "Placing Host" $ESXiHost "into Maintence Mode." -ForegroundColor Green
Get-VMHost -Name $j.Name |Set-VMHost -State Maintenance
}

if((Get-VMHost -Name $j.Name |select ConnectionState) -ne 'Maintenance'){
#Deploy Patches to the host.
Write-Host "Deploying Patches to host" $j "."
$B = Get-Compliance -Entity $j.Name -ComplianceStatus NotCompliant
Remediate-Inventory -Entity $j.Name -Baseline $B.Baseline -ClusterDisableHighAvailability:$true -ErrorAction SilentlyContinue -Confirm: $false
}else{
Write-Host "Could not Remediate Host:" $j.Name "Current Connection State:" $j.ConnectionState
}

#Return host to other mode.
if ($vmh.ConnectionState -eq 'Connected'){
Write-Host "Removing host " $j "from Maintence Mode."
Get-VMHost -Name $j.Name |Set-VMHost -State $vmh.ConnectionState
}

}}

