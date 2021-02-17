# Source **https://virtuallythatguy.co.uk/how-to-add-esxi-hosts-to-vcenter-using-powercli-automation/
# Specify vCenter Server, vCenter Server username, vCenter Server user password, vCenter Server location which can be the Datacenter, a Folder or a Cluster (which I used).
Import-Module -Name VMware.VimAutomation.Cis.Core
#
$vCenterURL = 'vCenter.localv'
#$vCenterUser="rboadi@lab.local"
#$vCenterUserPassword="xxxxxx" #Do not store password in scripts.
$vcenterlocation = "~Spare Hosts" #Target Cluster Name
$esxihostuser = "root"
#$esxihostpasswd="xxxxxxx"
#
#Connect to vCenter Server
Write-Host "Connecting to vCenter Server" $vCenterURL -ForegroundColor Green
Connect-VIServer -Server $vCenterURL |Out-Null

#
#

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,120)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter the root password in the space bellow:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $esxihostpasswd = $textBox.Text
    #$clustername
}

#Specify the ESXi host you want to add to vCenter Server and the user name and password to be used.
#$esxihosts=("DTCP-ESXi01.lab.local","DTCP-ESXi02.lab.local","DTCP-ESXi03.lab.local")​​ #(Get-VMHost -Name "UK3P-*")
$Servers = Import-Csv ".\Servers.csv"

foreach ($Server in $Servers) {
    $HostDNS = $Server.HostDNS
#
# The variables specified above will be used to add hosts to vCenter
# ------------------------------------------------------------------
Write-Host '--------'
write-host "Starting to add" $HostDNS "to the vCenter Server" $vCenter
write-host '--------'
#
# Add ESXi hosts
#
if ((Get-VMHost -Name $HostDNS) -eq $null){
Write-Host "Adding" $HostDNS "to vCenter" $vCenter
#Add-VMHost $esxihost -Location $vcenterlocation -User $esxihostuser -Password $esxihostpasswd -Force
}else{
Write-Host $HostDNS "is already in vCenter"
}
}
#
# Disconnect from vCenter Server
$esxihostpasswd = $null


Write-Host "Disconnecting from vCenter Server"$vCenterURL -ForegroundColor Green
Disconnect-VIServer -Server $vCenterURL -Confirm:$false |Out-Null

#You can change the $esxihosts to a wildcard and save you some typing replace with something like #(Get-VMHost -Name "DTCP-*").
