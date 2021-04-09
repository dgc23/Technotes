# This script will patch ESXi Host based on cluster.

#This loads .NET framework classes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#vCenter Config - Optional
Write-Host "Please Provide vCenter Name"
$v = Read-Host
Connect-VIServer -Server $v -InformationAction SilentlyContinue -WarningAction SilentlyContinue

$vmCluster = get-cluster

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select a Cluster Name'
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



$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 80


$listBox.Items.AddRange($vmCluster.Name)

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $c = $listBox.SelectedItem
    $c
}

#Not needed if dropdown menu works.
#Write-Host "Please Provide cluster name"
#$c = Read-Host
$i = Get-Cluster -Name $c |Get-VMHost


Get-Cluster -Name $c |get-vm |where {$_.ExtensionData.Runtime.ToolsInstallerMounted -eq $true} |Dismount-Tools


foreach ($j in $i){

if (((Get-VMHost -Name $j.Name).ConnectionState -eq 'Connected') -or ((Get-VMHost -Name $j.Name).ConnectionState -eq 'Maintenance')){

if ((Get-Compliance -Entity $j.name -ComplianceStatus NotCompliant).Baseline.Name -eq $null){
Write-Host "No patchse needed for" $j.Name -ForegroundColor Cyan
}else{
Write-Host "Starting to patch"$j.Name -ForegroundColor Green

#Checking current host connection status.
$vmh = Get-VMHost -Name $j.Name -InformationAction SilentlyContinue -WarningAction SilentlyContinue
Write-Host "Current Host State:" $j.ConnectionState

#Place Host into Maintence Mode if needed.
if ((Get-VMHost -Name $j.Name).ConnectionState -eq 'Connected'){
Write-Host "Placing Host" $j.Name "into Maintence Mode." -ForegroundColor Green
Get-VMHost -Name $j.Name |Set-VMHost -State Maintenance -InformationAction SilentlyContinue -WarningAction SilentlyContinue
}

#Deploy Patches to the host.
if((Get-VMHost -Name $j.Name).ConnectionState -eq "Maintenance"){
Write-Host "Deploying Patches to host" $j.Name "." -ForegroundColor Green
$B = Get-Compliance -Entity $j.Name -ComplianceStatus NotCompliant
Remediate-Inventory -Entity $j.Name -Baseline $B.Baseline -ClusterDisableHighAvailability:$true -ErrorAction SilentlyContinue -Confirm: $false
}else{
Write-Host "Could not Remediate Host:" $j.Name "Current Connection State:" $j.ConnectionState -ForegroundColor Red
}

#Set connection state to Connected.
if ($vmh.ConnectionState -eq 'Connected'){
Write-Host "Removing host " $j.Name "from Maintence Mode." -ForegroundColor Green
Get-VMHost -Name $j.Name |Set-VMHost -State $vmh.ConnectionState
}
}
}else{
Write-Host "Could not Patch" $j.Name "current connection state:" $j.ConnectionState -ForegroundColor Red
}

}

#Disconnect-VIServer -Server $v -Confirm:$false -InformationAction SilentlyContinue
Pause
