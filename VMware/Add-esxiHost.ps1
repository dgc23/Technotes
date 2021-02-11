# Source **https://virtuallythatguy.co.uk/how-to-add-esxi-hosts-to-vcenter-using-powercli-automation/
# Specify vCenter Server, vCenter Server username, vCenter Server user password, vCenter Server location which can be the Datacenter, a Folder or a Cluster (which I used).



$vCenter="sky-vcsa.cef.doj.gov"

#$vCenterUser="rboadi@lab.local"
#$vCenterUserPassword="xxxxxx"

$vcenterlocation="~Spare M5" #Cluster Name

#

# Specify the ESXi host you want to add to vCenter Server and the user name and password to be used.

#$esxihosts=("DTCP-ESXi01.lab.local","DTCP-ESXi02.lab.local","DTCP-ESXi03.lab.local")​​ #(Get-VMHost -Name "UK3P-*")
$Servers = Import-Csv ".\Servers.csv"

foreach ($Server in $Servers) {
    $HostDNS = $Server.HostDNS

$esxihostuser="root"

$esxihostpasswd="xxxxxxx"

#

# The variables specified above will be used to add hosts to vCenter

# ------------------------------------------------------------------

#

#Connect to vCenter Server

write-host​​ Connecting​​ to​​ vCenter​​ Server​​ $vcenter​​ -foreground​​ green

Connect-viserver​​ $vCenter​​ #-user $vCenterUser -password $vCenterUserPassword -WarningAction 0 | out-null

 

#

write-host​​ --------

write-host​​ Starting to​​ add​​ ESXi​​ hosts​​ to​​ the​​ vCenter​​ Server​​ $vCenter

write-host​​ --------

#

# Add ESXi hosts

foreach​​ ($esxihost​​ in​​ $esxihosts) {

Add-VMHost​​ $esxihost​​ -Location​​ $vcenterlocation​​ -User​​ $esxihostuser​​ -Password​​ $esxihostpasswd​​ -Force

}

#

# Disconnect from vCenter Server

write-host​​ "Disconnecting to vCenter Server​​ $vcenter"​​ -foreground​​ green

disconnect-viserver​​ *​​ -confirm:$false​​ |​​ out-null

 

​​ 
}
You can change​​ the​​ $esxihosts​​ to​​ a wildcard and save you some typing replace with something​​ like​​ #(Get-VMHost -Name "DTCP-*").​​
