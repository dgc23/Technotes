##This script will check the network configuration of vmkernel ports on all host in source file.
#It will Check setting
    #1. Set vSwitch0 MTU to 9000
    #2 Check for vMotion vmk
    #3 Check for NFS vmk
    #4-------------------------
    #5 Check for Backup vmk
    #6 ------------------Check for vmk0 MTU to 9000
#
#This script requires a source file located in the same as the script.
#

$Servers = Import-Csv ".\Servers.csv"

foreach ($Server in $Servers) {
    $HostDNS = $Server.HostDNS
    $vmk0_IP = $Server.vmk0_IP
    $vmk0_Mask = $Server.vmk0_Mask
    $vmk0_VLAN = $Server.vmk0_VLAN
    $vMot_IP = $Server.vMot_IP
    $vMot_Mask = $Server.vMot_Mask
    $vMot_VLAN = $Server.vMot_VLAN
    $NFS_IP = $Server.NFS_IP
    $NFS_Mask = $Server.NFS_Mask
    $NFS_VLAN = $Server.NFS_VLAN
    $Bkup_IP = $Server.Bkup_IP
    $Bkup_Mask = $Server.Bkup_Mask
    $Bkup_PortGroup = $Server.Bkup_PortGroup
    $DVS = $Server.DVS
   

Write-Host "----------------------------------------------------------" -ForegroundColor Cyan -BackgroundColor Blue
Write-Host "Checking the configuration of host"$HostDNS

#Check vSwtich0 MTU to 9000
if  ((Get-VirtualSwitch -VMHost $HostDNS -Name vSwitch0 |where {$_.MTU  -eq 9000}) -eq $null){
Write-Host "Error - vSwitch0 MTU not equal to 9000 on"$HostDNS -ForegroundColor Red
}else{
Write-Host "Pass - vSwitch0 MTU already set to 9000 on"$HostDNS -ForegroundColor Green
}
#


##Check for vmk0
if ((get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select Name |where {$_.Name -eq 'vmk0'}) -eq $null){
Write-Host "ERROR - No vmk0 vmkernel configured on Host"$HostDNS -ForegroundColor Red
}else {
Write-Host "vMotion vmkernel present on Host"$HostDNS -ForegroundColor Green
$int_ipaddr = $null
$int_ipaddr = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select Name, IP| where {$_.Name -eq 'vmk0'}|select IP
$int_ipaddr = $int_ipaddr -replace '@{IP=' -replace '}'
$int_Mask = $null
$int_Mask = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select Name, SubnetMask| where {$_.Name -eq 'vmk0'}|select SubnetMask
$int_Mask = $int_Mask -replace '@{SubnetMask=' -replace '}'
$int_vLAN = $null
$int_vLAN = Get-VMHost -Name $HostDNS | Get-VirtualPortGroup |where {$_.Name -eq 'Management Network'} |select VLanId
$int_vLAN = $int_vLAN -replace '@{VLanId=' -replace '}'

if ($int_ipaddr -eq ($vmk0_IP)){
Write-Host "vmk0 IP address correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host IP ddress"$int_ipaddr
#Write-Host "Value in source file"$vmk0_IP
}else{
Write-Host "vMotion IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr
Write-Host 'Value in source file'$vmk0_IP
}
if ($int_Mask -eq ($vmk0_Mask)){
Write-Host "vmk0 Subnet Mask is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host Subnet Mask"$int_Mask
#Write-Host "Value in source file"$vmk0_Mask
}else{
Write-Host "vmk0 Subnet Mask is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host Subnet Mask"$int_Mask
Write-Host 'Value in source file'$vmk0_Mask
}
if ($int_vLAN -eq ($vmk0_VLAN)){
Write-Host "vmk0 VLAN is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "vmk0 VLAN ID"$int_vLAN
#Write-Host "Value in source file"$vmk0_VLAN
}else{
Write-Host "vmk0 VLAN is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "vmk0 VLAN ID"$int_vLAN
Write-Host 'Value in source file'$vmk0_VLAN
}

}
## End of vMotion Check

##Check vMotion settings
if ((get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName |where {$_.PortGroupName -eq 'vMotion'}) -eq $null){
Write-Host "ERROR - No vMotion vmkernel configured on Host"$HostDNS -ForegroundColor Red
}else {
Write-Host "vMotion vmkernel present on Host"$HostDNS -ForegroundColor Green
$int_ipaddr = $null
$int_ipaddr = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, IP| where {$_.PortGroupName -eq 'vMotion'}|select IP
$int_ipaddr = $int_ipaddr -replace '@{IP=' -replace '}'
$int_Mask = $null
$int_Mask = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, SubnetMask| where {$_.PortGroupName -eq 'vMotion'}|select SubnetMask
$int_Mask = $int_Mask -replace '@{SubnetMask=' -replace '}'
$int_vLAN = $null
$int_vLAN = Get-VMHost -Name $HostDNS | Get-VirtualPortGroup |where {$_.Name -eq 'vMotion'} |select VLanId
$int_vLAN = $int_vLAN -replace '@{VLanId=' -replace '}'

if ($int_ipaddr -eq ($vMot_IP)){
Write-Host "vMotion IP address correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host IP ddress"$int_ipaddr
#Write-Host "Value in source file"$vMot_IP
}else{
Write-Host "vMotion IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr
Write-Host 'Value in source file'$vMot_IP
}
if ($int_Mask -eq ($vMot_Mask)){
Write-Host "vMotion Subnet Mask is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host Subnet Mask"$int_Mask
#Write-Host "Value in source file"$vMot_Mask
}else{
Write-Host "vMotion Subnet Mask is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host Subnet Mask"$int_Mask
Write-Host 'Value in source file'$vMot_Mask
}
if ($int_vLAN -eq ($vMot_VLAN)){
Write-Host "vMotion VLAN is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host VLAN ID"$int_vLAN
#Write-Host "Value in source file"$vMot_VLAN
}else{
Write-Host "vMotion VLAN is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host VLAN ID"$int_vLAN
Write-Host 'Value in source file'$vMot_VLAN
}
}
## End of vMotion Check


##Check for NFS
if ((get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName |where {$_.PortGroupName -eq 'NFS'}) -eq $null){
Write-Host "ERROR - No NFS vmkernel configured on Host"$HostDNS -ForegroundColor Red
}else {
Write-Host "NFS vmkernel present on Host"$HostDNS -ForegroundColor Green
$int_ipaddr = $null
$int_ipaddr = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, IP| where {$_.PortGroupName -eq 'NFS'}|select IP
$int_ipaddr = $int_ipaddr -replace '@{IP=' -replace '}'
$int_Mask = $null
$int_Mask = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, SubnetMask| where {$_.PortGroupName -eq 'NFS'}|select SubnetMask
$int_Mask = $int_Mask -replace '@{SubnetMask=' -replace '}'
$int_vLAN = $null
$int_vLAN = Get-VMHost -Name $HostDNS | Get-VirtualPortGroup |where {$_.Name -eq 'NFS'} |select VLanId
$int_vLAN = $int_vLAN -replace '@{VLanId=' -replace '}'


if ($int_ipaddr -eq ($NFS_IP)){
Write-Host "NFS IP address correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host IP ddress"$int_ipaddr
#Write-Host "Value in source file"$NFS_IP
}else{
Write-Host "NFS IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr
Write-Host 'Value in source file'$NFS_IP
}
if ($int_Mask -eq ($NFS_Mask)){
Write-Host "NFS Subnet Mask is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host Subnet Mask"$int_Mask
#Write-Host "Value in source file"$NFS_Mask
}else{
Write-Host "NFS Subnet Mask is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host Subnet Mask"$int_Mask
Write-Host 'Value in source file'$NFS_Mask
}
if ($int_vLAN -eq ($NFS_VLAN)){
Write-Host "NFS VLAN is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host VLAN ID"$int_vLAN
#Write-Host "Value in source file"$NFS_VLAN
}else{
Write-Host "NFS VLAN is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host VLAN ID"$int_vLAN
Write-Host 'Value in source file'$NFS_VLAN
}
}
##End of NFS Check


##Check backup portgroup

if ((get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName |where {$_.PortGroupName -eq $Bkup_PortGroup}) -eq $null){
Write-Host "ERROR - No Backup vmkernel configured on Host"$HostDNS -ForegroundColor Red
}else {
Write-Host "Backup vmkernel present on Host"$HostDNS -ForegroundColor Green
$int_ipaddr = $null
$int_ipaddr = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, IP| where {$_.PortGroupName -eq $Bkup_PortGroup}|select IP
$int_ipaddr = $int_ipaddr -replace '@{IP=' -replace '}'

$int_Mask = $null
$int_Mask = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, SubnetMask| where {$_.PortGroupName -eq $Bkup_PortGroup}|select SubnetMask
$int_Mask = $int_Mask -replace '@{SubnetMask=' -replace '}'

if ($int_ipaddr -eq ($Bkup_IP)){
Write-Host "Backup IP address correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host IP ddress"$int_ipaddr
#Write-Host "Value in source file"$Bkup_IP
}else{
Write-Host "Backup IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr
Write-Host 'Value in source file'$Bkup_IP
#echo $int_ipaddr
}

if ($int_Mask -eq ($Bkup_Mask)){
Write-Host "Backup Subnet Mask is correct on Host"$HostDNS -ForegroundColor Green
#Write-Host "Host Subnet Mask"$int_Mask
#Write-Host "Value in source file"$Bkup_Mask
}else{
Write-Host "Backup Subnet Mask is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host Subnet Mask"$int_Mask
Write-Host 'Value in source file'$Bkup_Mask
}

}
##End of backup portgroup check


}
