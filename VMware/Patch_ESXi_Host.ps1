
# This script will patch ESXi Host based on cluster.

Write-Host "Provide cluster name"
$c = Read-Host
$i = Get-Cluster -Name $c |Get-VMHost



foreach ($j in $i){


Write-Host $j.Name

Write-Host "Placing Host" $ESXiHost "into Maintence Mode." -ForegroundColor Green
Get-VMHost -Name $j.Name |Set-VMHost -State Maintenance -WhatIf

Write-Host "Deploying Patches to host" $j "."
$BL = (Get-Compliance -Entity $j.name -ComplianceStatus NotCompliant).Baseline.Name
#Get-Compliance -Entity $j.name -ComplianceStatus NotCompliant -OutVariable

#Get-Baseline -Name $BL.Baseline |
Write-Host 'baseline' $BL
Remediate-Inventory -Entity $j.Name -Baseline $BL -ErrorAction SilentlyContinue -Confirm: $false -WhatIf

#Get-Inventory -Name $j.Name |Test-Compliance -UpdateType HostPatch
#Get-Inventory $j.Name |Test-Compliance -UpdateType HostPatch

Get-VMHost -Name $j.Name |Set-VMHost -State Connected -WhatIf
#$PatchStat = Get-Inventory $j.Name |Get-Compliance -ComplianceStatus NotCompliant |select baseline
#Write-Host $PatchStat
}
