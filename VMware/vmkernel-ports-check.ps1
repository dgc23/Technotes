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
   

Write-Host "----------------------------------------------------------"
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
$int_ipaddr1 = $int_ipaddr -replace '@{IP=' -replace '}'

if ($int_ipaddr1 -eq ($vmk0_IP)){
Write-Host "vmk0 IP address correct on Host"$HostDNS -ForegroundColor Green
Write-Host "Host IP ddress"$int_ipaddr1
Write-Host "Value in source file"$vmk0_IP
}else{
Write-Host "vMotion IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr1
Write-Host 'Value in source file'$vmk0_IP
#echo $int_ipaddr
}

}
## End of vMotion Check

##Check for vMotion
if ((get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName |where {$_.PortGroupName -eq 'vMotion'}) -eq $null){
Write-Host "ERROR - No vMotion vmkernel configured on Host"$HostDNS -ForegroundColor Red
}else {
Write-Host "vMotion vmkernel present on Host"$HostDNS -ForegroundColor Green
$int_ipaddr = $null
$int_ipaddr = get-vmhost -Name $HostDNS |Get-VMHostNetworkAdapter -VMKernel|select PortGroupName, IP| where {$_.PortGroupName -eq 'vMotion'}|select IP
$int_ipaddr1 = $int_ipaddr -replace '@{IP=' -replace '}'

if ($int_ipaddr1 -eq ($vMot_IP)){
Write-Host "vMotion IP address correct on Host"$HostDNS -ForegroundColor Green
Write-Host "Host IP ddress"$int_ipaddr1
Write-Host "Value in source file"$vMot_IP
}else{
Write-Host "vMotion IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr1
Write-Host 'Value in source file'$vMot_IP
#echo $int_ipaddr
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
$int_ipaddr1 = $int_ipaddr -replace '@{IP=' -replace '}'

if ($int_ipaddr1 -eq ($NFS_IP)){
Write-Host "NFS IP address correct on Host"$HostDNS -ForegroundColor Green
Write-Host "Host IP ddress"$int_ipaddr1
Write-Host "Value in source file"$NFS_IP
}else{
Write-Host "NFS IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr1
Write-Host 'Value in source file'$NFS_IP
#echo $int_ipaddr
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
$int_ipaddr1 = $int_ipaddr -replace '@{IP=' -replace '}'

if ($int_ipaddr1 -eq ($Bkup_IP)){
Write-Host "vMotion IP address correct on Host"$HostDNS -ForegroundColor Green
Write-Host "Host IP ddress"$int_ipaddr1
Write-Host "Value in source file"$Bkup_IP
}else{
Write-Host "vMotion IP Address is not correct on Host"$HostDNS -ForegroundColor Red
Write-Host "Host IP Address"$int_ipaddr1
Write-Host 'Value in source file'$Bkup_IP
#echo $int_ipaddr
}

}
##End of backup portgroup check


}
