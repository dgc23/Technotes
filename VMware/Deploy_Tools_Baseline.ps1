 $h = Get-Cluster $clustername |Get-VMHost

foreach($i in $h) {
Get-Baseline -Id 11 |Remediate-Inventory -Entity $i.name -Confirm:$false

}
