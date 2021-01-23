$Servers = Import-Csv "C:\Software\Script\Servers1.csv"

foreach ($Server in $Servers) {
    $HostDNS = $Server.HostDNS
    $vMot_IP = $Server.vMot_IP
    $NFS_IP = $Server.NFS_IP
    $vMot_VLAN = $Server.vMot_VLAN
    $vMot_Mask = $Server.vMot_Mask
    $NFS_Mask = $Server.NFS_Mask
    $NFS_VLAN = $Server.NFS_VLAN
    $Bkup_IP = $Server.Bkup_IP
    $Bkup_Mask = $Server.Bkup_Mask
    $Bkup_PortGroup = $Server.Bkup_PortGroup
    $DVS = $Server.DVS

    #$MTU_M = $Server.MTU_M


#Configure vSwtich0 MTU to 9000
Get-VirtualSwitch -VMHost $HostDNS -Name vSwitch0 | Set-VirtualSwitch -Mtu 9000 -Confirm:$false
#

#Create vMotion vmkernal
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name vMotion -ErrorAction SilentlyContinue) -eq $null) {
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup vMotion -IP $vMot_IP -SubnetMask $vMot_Mask -Mtu 9000 -VMotionEnabled:$true
Get-VirtualPortGroup -VMHost $HostDNS -Name vMotion |Set-VirtualPortGroup -VLanId $vMot_VLAN
Get-VMHost $HostDNS |Get-VMHostNetworkAdapter -Name vmk0 |Set-VMHostNetworkAdapter -VMotionEnabled:$false -Confirm:$false
}else {
Write-Host "vMotion VMK already exist"
}



#Create NFS vmkernal
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name NFS -ErrorAction SilentlyContinue) -eq $null) {
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch "vSwitch0" -PortGroup NFS -IP $NFS_IP -SubnetMask $NFS_Mask -Mtu 9000
Get-VirtualPortGroup -VMHost $HostDNS -Name NFS |Set-VirtualPortGroup -VLanId $NFS_VLAN
}else {
Write-Host "NFS VMK already exist"
}

#Create Backup Portgroup on DVS - checking condition not working
if ((Get-VirtualPortGroup -VMHost $HostDNS -Name 'Cloud_infrastructure|CohesityBackupAP|BackupEPG' -ErrorAction SilentlyContinue) -eq $null) {
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch $DVS -PortGroup $Bkup_PortGroup -IP $Bkup_IP -SubnetMask $Bkup_Mask

}else {
Write-Host "Backup VMK already exist"
}
#Create portgroup working command
New-VMHostNetworkAdapter -VMHost $HostDNS -VirtualSwitch $DVS -PortGroup $Bkup_PortGroup -IP $Bkup_IP -SubnetMask $Bkup_Mask
#Set vmk0 MTU to 9000 -Place at End
#Get-VMHost $HostDNS |Get-VMHostNetworkAdapter -Name vmk0 |Set-VMHostNetworkAdapter -Mtu 9000 -Confirm:$false -ErrorAction SilentlyContinue

}
