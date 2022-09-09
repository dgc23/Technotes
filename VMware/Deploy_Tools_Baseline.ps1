$clustername = Read-Host "Please type in name of VMhost Cluster"
$h = Get-Cluster $clustername |Get-VMHost

foreach($i in $h) {
   
    if($(Get-Baseline -Id 11 |Get-Compliance -Entity $i).status -like 'NotCompliant'){
Write-Host "Updating tools on host " $i
#Get-Baseline -Id 11 |Remediate-Inventory -Entity $i.name -Confirm:$false
}else{
Write-Host "Tools already up to date on host " $i
}
}


#-----------------------------------------------------------------------------
##Junk 1

#$j = Read-Host
#$k = $j

#Host based on clusters
$c = Read-Host 'Input Cluster Name'
$j = Get-Cluster $c |Get-VMHost |select Name

#All Host
#$j = Get-VMHost |select Name

foreach($k in $j.Name){ 
#$B = Get-Compliance -Entity $k -ComplianceStatus NotCompliant 
#Write-Host $B.Baseline

#if ($B.Baseline -eq 'VMware-Tools'){

Write-Host 'Updating tools on host' $k
$B = Get-Compliance -Entity $k -ComplianceStatus NotCompliant 
$B.Baseline
#Remediate-Inventory -Entity $k -Baseline $B.Baseline -ClusterDisableHighAvailability:$true -ErrorAction SilentlyContinue -Confirm: $false -WhatIf
#}else{
#Write-Host "host alread done" $k
}
#}

Junk 2
 #$Baseline_Stat = (Get-Baseline -Id 11 |Get-Compliance -Entity $i)
    #if($Baseline.status -like 'NotCompliant'){
