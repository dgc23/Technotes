
########################################
#                                      #
#   Lab Cluster VSS Switch Config      #
#     ESXi VSS Switch creation         #
#                                      # 
########################################

$Servers = Import-CSV "C:\<path to your CSV file>\hostnet.csv"

ForEach ($Server in $Servers) {

	$VMhost = $Server.HostIP
	$VMSwitch1 = $Server.vSwitch1
    $VMSwitch2 = $Server.vSwitch2
    $iscsinic1 = $Server.iscsinic1
    $iscsinic2 = $Server.iscsinic2
    $vmotionnic1 = $Server.vmonic1
    $vmotionnic2 = $Server.vmonic2
    $iscsi1 = $Server.iscsia
    $iscsi2 = $Server.iscsib
    $vmotion1 = $Server.vmotiona
    $vmotion2 = $Server.vmotionb
    $iscsiIP1 = $Server.iscsiIP1
    $iscsiIP2 = $Server.iscsiIP2
    $iscsisubnet = $Server.iscsisubnet
    $vmotionIP1 = $Server.vmotionip1
    $vmotionIP2 = $Server.vmotionip2
    $vmosubnet = $Server.vmosubnet
	

    get-virtualswitch -VMHost $VMhost -name vswitch0 | set-virtualswitch -nic vmnic0,vmnic1 -MTU 9000 -confirm:$false

    #Creating vSwitch1 for iSCSI

    if ((get-virtualswitch -VMHost $VMhost -name $VMSwitch1 -ErrorAction SilentlyContinue) -eq $null) {

        Write-host "Creating VSS Switch $VMSwitch1"
        new-virtualswitch -host $VMhost -name $VMSwitch1 | set-virtualswitch -nic $iscsinic1,$iscsinic2 -MTU 9000 -confirm:$false

    } else {

        Write-host "VSS Switch $VMSwitch1 already exists"

    }

    #Creating vSwitch2 for vMotion

    if ((get-virtualswitch -VMHost $VMhost -name $VMSwitch2 -ErrorAction SilentlyContinue) -eq $null) {

        Write-host "Creating $vSwitch1"
        new-virtualswitch -host $VMhost -name $VMSwitch2 | set-virtualswitch -nic $vmotionnic1,$vmotionnic2 -MTU 9000 -confirm:$false

    } else {

        Write-host "VSS Switch $vSwitch1 already exists"
    }


    #Creating iSCSI1 VMkernel Ports

    if ((Get-VirtualPortGroup -VMHost $vmhost -Name $iscsi1 -ErrorAction SilentlyContinue) -eq $null) {

        Write-host "Creating VMkernel port $iscsi1"    
        new-vmhostnetworkadapter -vmhost $VMhost -PortGroup $iscsi1 -VirtualSwitch $VMSwitch1 -IP $iscsiIP1 -SubnetMask $iscsisubnet -MTU 9000
        Get-VirtualPortGroup -VMHost $vmhost -Name $iscsi1 | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $iscsinic1 -MakeNicUnused $iscsinic2 -FailbackEnabled:$false

    } else {

        Write-host "VMkernel port $iscsi1 already exists"

    }


    #Creating iSCSI2 VMkernel Ports

    if ((Get-VirtualPortGroup -VMHost $vmhost -Name $iscsi2 -ErrorAction SilentlyContinue) -eq $null) {

        Write-host "Creating VMkernel port $iscsi2"
        new-vmhostnetworkadapter -vmhost $VMhost -PortGroup $iscsi2 -VirtualSwitch $VMSwitch1 -IP $iscsiIP2 -SubnetMask $iscsisubnet -MTU 9000
        Get-VirtualPortGroup -VMHost $vmhost -Name $iscsi2 | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $iscsinic2 -MakeNicUnused $iscsinic1 -FailbackEnabled:$false

    } else {

        Write-host "VMkernel port $iscsi2 already exists"

    }


    #Creating vMotion1 VMkernel Ports

    if ((Get-VirtualPortGroup -VMHost $vmhost -Name $vmotion1 -ErrorAction SilentlyContinue) -eq $null) {

        Write-host "Creating VMkernel port $vmotion1"
        new-vmhostnetworkadapter -vmhost $VMhost -PortGroup $vmotion1 -VirtualSwitch $VMSwitch2 -IP $vmotionip1 -SubnetMask $vmosubnet -MTU 9000 -VMotionEnabled:$true
        Get-VirtualPortGroup -VMHost $vmhost -Name $vmotion1 | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $vmotionnic1 -MakeNicStandby $vmotionnic2

    } else {

        Write-host "VMkernel port $vmotion1 already exists"

    }


    #Creating vMotion2 VMkernel Ports

    if ((Get-VirtualPortGroup -VMHost $vmhost -Name $vmotion2 -ErrorAction SilentlyContinue) -eq $null) {
    
        Write-host "Creating VMkernel port $vmotion2"
        new-vmhostnetworkadapter -vmhost $VMhost -PortGroup $vmotion2 -VirtualSwitch $VMSwitch2 -IP $vmotionip2 -SubnetMask $vmosubnet -MTU 9000 -VMotionEnabled:$true
        Get-VirtualPortGroup -VMHost $vmhost -Name $vmotion2 | Get-NicTeamingPolicy | Set-NicTeamingPolicy -MakeNicActive $vmotionnic2 -MakeNicStandby $vmotionnic1
  
	} else {
        
        Write-host "VMkernel port $vmotion2 already exists"

    }

}
