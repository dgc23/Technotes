$Servers = Import-Csv "C:\Software\Script\Servers.csv"

foreach ($Server in $Servers) {
    $HostDNS = $Server.HostDNS
    $HostIP_M = $Server.HostIP_M
    $HostIP_NFS = $Server.HostIP_NFS
    $VLAN_M = $Server.VLAN_M
    $Snet_M = $Server.Snet_M
    $Snet_NFS = $Server.Snet_NFS
    #$MTU_M = $Server.MTU_M


#Configure vSwtich0
Get-VirtualSwitch -VMHost $HostDNS -Name vSwitch0 | Set-VirtualSwitch -Mtu 9000 -Confirm:$false
#

#Create vMotion vmkernal
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name vMotion -ErrorAction SilentlyContinue) -eq $null) {
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup vMotion -IP $HostIP_M -SubnetMask $Snet_M -Mtu 9000 -VMotionEnabled:$true

Get-VirtualPortGroup -VMHost $HostDNS -Name vMotion |Set-VirtualPortGroup -VLanId 1100
#Get-VMHostNetworkAdapter -VMHost $HostDNS -PortGroupName 'Management Network' |Set-VMHostNetworkAdapter -VMotionEnabled:false
Set-VMHostNetworkAdapter -VMotionEnabled:$false -ManagementTrafficEnabled:$true -VirtualNic 'Management Network' -WhatIf

}else {
Write-Host "vMotion VMK already exist"
}



#Create NFS vmkernal
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name NFS -ErrorAction SilentlyContinue) -eq $null) {
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup NFS -IP $HostIP_NFS -SubnetMask $Snet_NFS -Mtu 9000

Get-VirtualPortGroup -VMHost $HostDNS -Name NFS |Set-VirtualPortGroup -VLanId 1400
}else {
Write-Host "NFS VMK already exist"
}
