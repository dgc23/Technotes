# This script will patch ESXi Host based on cluster based in the specified vCenter.

Write-Host "Please Provide vCenter Server:"
$v = Read-Host
Disconnect-VIServer -Server * -Confirm:$false
Connect-VIServer -Server $v -InformationAction:SilentlyContinue

Write-Host "Please Provide cluster name"
$c = Read-Host
$i = Get-Cluster -Name $c |Get-VMHost


Get-Cluster -Name $c |get-vm |where {$_.ExtensionData.Runtime.ToolsInstallerMounted -eq $true} |Dismount-Tools


foreach ($j in $i){

if ((Get-Compliance -Entity $j.name -Server $v -ComplianceStatus NotCompliant).Baseline.Name -eq $null){
Write-Host "No patchse needed for" $j -ForegroundColor Cyan
}else{
Write-Host "Starting to patch"$j.Name -ForegroundColor Green

Write-Host "Placing Host" $ESXiHost "into Maintence Mode." -ForegroundColor Green
Get-VMHost -Name $j.Name |Set-VMHost -State Maintenance
Write-Host "Deploying Patches to host" $j "."
$B = Get-Compliance -Entity $j.name -ComplianceStatus NotCompliant
Remediate-Inventory -Entity $j.Name -Baseline $B.Baseline -ClusterDisableHighAvailability:$true -Server $v -ErrorAction SilentlyContinue -Confirm: $false
Write-Host "Removing host " $j "from Maintence Mode."
Get-VMHost -Name $j.Name |Set-VMHost -State Connected

}}

Disconnect-VIServer -Server * -Confirm:$false
