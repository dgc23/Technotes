
Write-Host "This script is used to change the queue depth for attached netapp storage devices.  It should be run in two steps.  First step is to update the nfnic queuedepth. after which the hsot will need to be rebooted."

$vmcl = Read-Host "Please input cluster name"

$EsxHosts = Get-Cluster -Name $vmcl |Get-VMHost
$result = @{}
$fcInfo = @{}
$r2 = @{}


function Show-Menu { 
    Write-Host "================ MENU ================"
    Write-Host "1: Change the queue depth of cisco nfnic to 256"
    Write-Host "2: Change the queue depth of each netapp device to 256"
    Write-Host "3: Display current queue depth setting"
    Write-Host "Q: Quit"
    Write-Host "======================================"
}

do {
    Show-Menu
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" {
            # Change Queue Depth for HBA card
            foreach ($EsxHost in $EsxHosts) {
$Esxcli = Get-EsxCli -VMHost $EsxHost.Name -V2 
$pSet = $RBlist =@{}
$pset = $esxcli.system.module.parameters.list.CreateArgs() 
$pset['module'] = 'nfnic'
$pSet['parameterstring'] = 'lun_queue_depth_per_path=256'
$fcInfo = $esxcli.system.module.parameters.list.Invoke($pSet) #store information related to FC card.

Write-Host "Queue depth for nfnic and device list on host " $EsxHost.Name -ForegroundColor Green
#$pSet['module'] = 'nfnic'
#$fcInfo = $esxcli.system.module.parameters.list.Invoke($pSet) #store information related to FC card.
if (($pSet.lun_queue_depth_per_path -lt 256) -or (!$pSet.lun_queue_depth_per_path)){

    write-host 'Changing HBA queue depth. Please reboot host and run this script again'
    #$esxcli.system.module.parameters.set.Invoke($pSet) #remove # after testing #Change 
    write-host 'Finished please reboot host ' $r3.'ESXi Host' "and run command again"  -ForegroundColor Blue
    $RBlist = r3.'ESXi Host' + $RBlist
    
    

}}
if(!$RBlist){
Write-Host "Step 1 is finished Please Reboot the following host and run the script again." -ForegroundColor Yellow
$RBlist
}
# Return #
            
        }
        "2" {
            # Code to run for Option 2
            foreach ($EsxHost in $EsxHosts) {
            $Esxcli = Get-EsxCli -VMHost $EsxHost.Name -V2 
            $ldList = $Esxcli.storage.core.device.list.Invoke() |select  @{Name = "ESXi Host"; Expression = {$EsxHost.Name}}, Device, DeviceMaxQueueDepth, NoofoutstandingIOswithcompetingworlds

foreach ($lsItem in $ldList){
    if (($ldItem.Device -like '*naa.600*') -and ($ldItem.DeviceMaxQueueDepth -lt '256') -and ($fcinfo.lun_queue_depth_per_path -eq '256')){
        
        write-host 'Changing Lun queue depth' $ldItem.Device ',' $ldItem.DeviceMaxQueueDepth ',' $ldItem.NoofoutstandingIOswithcompetingworlds
        $lSet['device'] = $r3
        #$lSet['NoofoutstandingIOswithcompetingworlds'] = 256
        $lSet['maxqueuedepth'] = 256
        #$Esxcli.storage.core.device.setconfig.Invoke($lSet) # Change lun setting, remove # after testing
        $ldItem


    }
}

        }
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
