##This script will configure vmkernel port on all host in source file.
#It will Check and if needed make changes listed bellow
    #1. Set vSwitch0 MTU to 9000
    #2 Create and configure vMotion vmk
    #3 Create and configure NFS and NFS2 vmk
    #4 Configure DVS on Host
    #5 Create and configure Backup vmk
    #6 Configure vmk0 MTU to 9000
#
#This script requires a source file located in the same as the script.
#

#vCenter Config - Optional
$v = Read-Host "Please Provide vCenter Name"
Connect-VIServer -Server $v -InformationAction SilentlyContinue -WarningAction SilentlyContinue

$Servers = Import-Csv ".\Servers.csv"

foreach ($Server in $Servers) {
    $HostDNS = $Server.HostDNS
    $vMot_IP = $Server.vMot_IP
    $vMot_VLAN = $Server.vMot_VLAN
    $vMot_Mask = $Server.vMot_Mask
    $NFS_IP = $Server.NFS_IP
    $NFS_Mask = $Server.NFS_Mask
    $NFS_VLAN = $Server.NFS_VLAN
    $Bkup_IP = $Server.Bkup_IP
    $Bkup_Mask = $Server.Bkup_Mask
    $Bkup_PortGroup = $Server.Bkup_PortGroup
    $DVS = $Server.DVS
    $NFS2_IP = $Server.NFS2_IP
    $NFS2_Mask = $Server.NFS2_Mask
    $NFS2_VLAN = $Server.NFS2_VLAN
   

Write-Host "----------------------------------------------------------" -ForegroundColor Cyan -BackgroundColor Blue
Write-Host "Starting the configuration of host"$HostDNS

#Configure vSwtich0 MTU to 9000
if  ((Get-VirtualSwitch -VMHost $HostDNS -Name vSwitch0 |where {$_.MTU  -eq 9000}) -eq $null){
Write-Host "Setting vSwitch MTU equal to 9000 on"$HostDNS
Get-VirtualSwitch -VMHost $HostDNS -Name vSwitch0 | Set-VirtualSwitch -Mtu 9000 -Confirm:$false
}else{
Write-Host "vSwitch0 MTU already set to 9000 on"$HostDNS
}
#

#Create vMotion vmkernel
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name vMotion -ErrorAction SilentlyContinue) -eq $null) {
Write-Host "Creating vMotion vmkernel port on"$HostDNS
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup vMotion -IP $vMot_IP -SubnetMask $vMot_Mask -Mtu 9000 -VMotionEnabled:$true
Get-VirtualPortGroup -VMHost $HostDNS -Name vMotion |Set-VirtualPortGroup -VLanId $vMot_VLAN
Get-VMHost $HostDNS |Get-VMHostNetworkAdapter -Name vmk0 |Set-VMHostNetworkAdapter -VMotionEnabled:$false -Confirm:$false
Write-Host 'Enabling Provisioning on vMotion vmkernel'
$Host1 = Get-VMHost -Name $HostDNS
$vmkP = Get-VMHost -Name $Host1 |Get-VMHostNetworkAdapter |select VMHost, Name, PortGroupName |where PortGroupName -EQ vMotion
Write-Host $vmkP
$vnicMGR = Get-View -Id $Host1.ExtensionData.ConfigManager.VirtualNicManager
$vnicMGR.selectVnicForNicType('vSphereProvisioning' ,$vmkP.Name)
$vnicMGR.selectVnicForNicType('vSphereReplication' ,$vmkP.Name)
$vnicMGR.selectVnicForNicType('vSphereReplicationNFC' ,$vmkP.Name)


}else {
Write-Host "vMotion VMK already exist on"$HostDNS
}
###

#Create NFS vmkernel -OLD vmk will be removed.
if (!$NFS_IP) {
Write-Host "No NFS vmk IP Address listed in Server.csv for host"$HostDNS
}else {
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name NFS -ErrorAction SilentlyContinue) -eq $null) {
Write-Host "Creating NFS VMK Port on"$HostDNS
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup NFS -IP $NFS_IP -SubnetMask $NFS_Mask -Mtu 9000 -InformationAction SilentlyContinue
Get-VirtualPortGroup -VMHost $HostDNS -Name NFS |Set-VirtualPortGroup -VLanId $NFS_VLAN -InformationAction SilentlyContinue
}else {
Write-Host "NFS VMK already exist on"$HostDNS
}}
#

#Create NFS2 vmkernel
if (!$NFS2_IP) {
Write-Host "No NFS2 vmk IP Address listed in Server.csv for host"$HostDNS
}else {
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name NFS2 -ErrorAction SilentlyContinue) -eq $null) {
Write-Host "Creating NFS2 VMK Port on"$HostDNS
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup NFS2 -IP $NFS2_IP -SubnetMask $NFS2_Mask -Mtu 9000 -InformationAction SilentlyContinue
Get-VirtualPortGroup -VMHost $HostDNS -Name NFS2 |Set-VirtualPortGroup -VLanId $NFS2_VLAN -InformationAction SilentlyContinue
}else {
Write-Host "NFS2 VMK already exist on"$HostDNS
}}
#

#Check and Configure DVS on Host
if((Get-VMHost $HostDNS | Get-VDSwitch) -eq $null){
Write-Host "Adding DVS to Host "$HostDNS
$vmhostNetworkAdapter1 = $null
$vmhostNetworkAdapter2 = $null
Add-VDSwitchVMHost -VDSwitch $DVS -VMHost $HostDNS
$vmhostNetworkAdapter1 = Get-VMHost $HostDNS | Get-VMHostNetworkAdapter -Physical -Name vmnic2
Get-VDSwitch $DVS | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmhostNetworkAdapter1 -Confirm:$false
$vmhostNetworkAdapter2 = Get-VMHost $HostDNS | Get-VMHostNetworkAdapter -Physical -Name vmnic3
Get-VDSwitch $DVS | Add-VDSwitchPhysicalNetworkAdapter -VMHostPhysicalNic $vmhostNetworkAdapter2 -Confirm:$false
}else{
Write-Host "A DVS is already configured"
}

#Create Backup Portgroup on DVS
if (!$Bkup_IP){
Write-Host "No Backup vmk IP address listed in Server.csv for host"$HostDNS
}elseif (((Get-VDPortGroup -Name $Bkup_PortGroup | Get-VMHostNetworkAdapter |where {$_.VMHost -like $HostDNS} -ErrorAction SilentlyContinue) -eq $null)) {
Write-Host "Creating Backup VMKernel Port on"$HostDNS
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch $DVS -PortGroup $Bkup_PortGroup -IP $Bkup_IP -SubnetMask $Bkup_Mask -InformationAction SilentlyContinue
}else{
Write-Host "Backup VMK already exist on"$HostDNS
}

#Set vMotion - Can be used if vMotion need to be changed. -Depricated
#Get-VMHost $HostDNS |Get-VMHostNetworkAdapter -Name vmk0 |Set-VMHostNetworkAdapter -VMotionEnabled:$false -Confirm:$false -InformationAction SilentlyContinue
#Get-VMHost $HostDNS |Get-VMHostNetworkAdapter |where {$_.PortGroupName -eq 'NFS'} |Set-VMHostNetworkAdapter -VMotionEnabled:$false -Confirm:$false -InformationAction SilentlyContinue
#Get-VMHost $HostDNS |Get-VMHostNetworkAdapter |where {$_.PortGroupName -eq $Bkup_PortGroup} |Set-VMHostNetworkAdapter -VMotionEnabled:$false -Confirm:$false -InformationAction SilentlyContinue
#Get-VMHost $HostDNS |Get-VMHostNetworkAdapter |where {$_.PortGroupName -eq 'vMotion'} |Set-VMHostNetworkAdapter -VMotionEnabled:$true -Confirm:$false -InformationAction SilentlyContinue

#Set vmk0 MTU to 9000 -Place at End as it will intrupt comunnication with host for up to 1 min.
if ((Get-VMHostNetworkAdapter -vmhost $HostDNS -Name vmk0| where {$_.MTU -eq 9000}) -eq $null){
Write-Host "Setting MTU of vmk0 on host"$HostDNS "to 9000"
Get-VMHost $HostDNS |Get-VMHostNetworkAdapter -Name vmk0 |Set-VMHostNetworkAdapter -Mtu 9000 -Confirm:$false -ErrorAction SilentlyContinue
}else{
Write-Host "MTU on vmk0 already set to 9000 on host"$HostDNS
}

}

Disconnect-VIServer -Server $v -Confirm:$false -InformationAction SilentlyContinue
Write-Host "Disconnected from vCenter Server" $v
Pause