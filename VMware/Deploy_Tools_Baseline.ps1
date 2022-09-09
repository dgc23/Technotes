
$clustername = Read-Host "Please type in name of VMhost Cluster"
$h = Get-Cluster $clustername |Get-VMHost

foreach($i in $h) {
    if((Get-Compliance -Entity $i -Baseline "VMware_Tools" -ComplianceStatus Compliant) -eq $false){
Write-Host "Updating tools on host " $i
#Get-Baseline -Id 11 |Remediate-Inventory -Entity $i.name -Confirm:$false
}else{
Write-Host "Tools already up to date on host " $i
}
}
