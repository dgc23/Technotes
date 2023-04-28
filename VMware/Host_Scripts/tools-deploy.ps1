Write-Host "This script should be used to deolpy new version of VMtools to the ESXi host using the baseline VMware Tools 12.2 - Host Deploy.  This script will not place host in maintance mode or trigger a reboot of the host."
$VC = read-host "Please input vCenter FQDN"   

if($VC -ne $null -and $VC -ne ""){
    Disconnect-VIServer -Server *
    Connect-VIServer -Server $VC
}

function Show-Menu { 

    Write-Host "================ MENU ================"
    Write-Host "1: Update vmware tools on a Cluster"
    Write-Host "2: Update VMware tools on all host on attached vCenter(s)"
    #Write-Host "3: Check Queue depth"
    Write-Host "Q: Quit"
    Write-Host "======================================"
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" {
        $clustername = Read-Host "Please type in name of VMhost Cluster"
        $h = Get-Cluster $clustername |Get-VMHost
        $b = Get-Baseline |where name -like 'VMware Tools 12.2 - Host Deploy'
            foreach($i in $h) {
	        if(($i.ConnectionState -eq 'Connected') -or ($i.ConnectionState -eq 'Maintenance')){
            if($(Get-Baseline -Id $b.Id |Get-Compliance -Entity $i).status -like 'NotCompliant'){
            Write-Host "Updating tools on host " $i
            Get-Baseline -Id $b.Id |Remediate-Inventory -Entity $i.name -Confirm:$false
        }else{
Write-Host "Tools already up to date on host " $i -ForegroundColor Green
}}else{
Write-Host "Could not update tools on host " $i.Name "with status of " $i.ConnectionState -ForegroundColor Red
}}}


"2" {
    # Code to run for Option 2
    Write-Host "Upgrading VM tools on all hosts attached to the connected vCenter"
    $h = Get-VMHost -Name *
    $b = Get-Baseline |where name -like 'VMware Tools 12.2 - Host Deploy'
    foreach($i in $h) {
        if(($i.ConnectionState -eq 'Connected') -or ($i.ConnectionState -eq 'Maintenance')){
        if($(Get-Baseline -Id $b.Id |Get-Compliance -Entity $i).status -like 'NotCompliant'){
    Write-Host "Updating tools on host " $i -ForegroundColor Yellow
    Get-Baseline -Id $b.Id |Remediate-Inventory -Entity $i.name -Confirm:$false
    }else{
    Write-Host "Tools already up to date on host " $i -ForegroundColor Green
    }}else{
    Write-Host "Could not update tools on host " $i.Name "with status of " $i.ConnectionState -ForegroundColor Red
    }}}


"3" {
    # Code to run for Option 3
    Write-Host "You chose Option 3"
}
"q" {
    # Code to run for quitting the script
    Write-Host "Exiting script..."
    return
}
default {
    # Code to run if an invalid choice is made
    Write-Host "Invalid choice, please try again"
}
}
} while ($true)

