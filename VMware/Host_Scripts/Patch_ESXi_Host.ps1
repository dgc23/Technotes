# This script will patch ESXi Host based on cluster.

#This loads .NET framework classes
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

[void] $listBox.Name = $vmCluster
#[void] $listBox.Items.Add('atl-dc-001')
#[void] $listBox.Items.Add('atl-dc-002')
#[void] $listBox.Items.Add('atl-dc-003')
#[void] $listBox.Items.Add('atl-dc-004')
#[void] $listBox.Items.Add('atl-dc-005')
#[void] $listBox.Items.Add('atl-dc-006')
#[void] $listBox.Items.Add('atl-dc-007')

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItem
    $x
}

























#Not needed if dropdown menu works.
#Write-Host "Please Provide cluster name"
#$c = Read-Host
#$i = Get-Cluster -Name $c |Get-VMHost


Get-Cluster -Name $c |get-vm |where {$_.ExtensionData.Runtime.ToolsInstallerMounted -eq $true} |Dismount-Tools


foreach ($j in $i){

if ((Get-Compliance -Entity $j.name -ComplianceStatus NotCompliant).Baseline.Name -eq $null){
Write-Host "No patchse needed for" $j -ForegroundColor Cyan
}else{
Write-Host "Starting to patch"$j.Name -ForegroundColor Green

#Checking current host connection status.
$vmh = Get-VMHost -Name $j.Name |select ConnectionState
Write-Host "Current Host State:" $j.ConnectionState

#Place Host into Maintence Mode if needed.
if ((Get-VMHost -Name $j.Name |select ConnectionState) -eq 'Connected'){
Write-Host "Placing Host" $ESXiHost "into Maintence Mode." -ForegroundColor Green
Get-VMHost -Name $j.Name |Set-VMHost -State Maintenance
}

if((Get-VMHost -Name $j.Name |select ConnectionState) -ne 'Maintenance'){
#Deploy Patches to the host.
Write-Host "Deploying Patches to host" $j "."
$B = Get-Compliance -Entity $j.Name -ComplianceStatus NotCompliant
Remediate-Inventory -Entity $j.Name -Baseline $B.Baseline -ClusterDisableHighAvailability:$true -ErrorAction SilentlyContinue -Confirm: $false
}else{
Write-Host "Could not Remediate Host:" $j.Name "Current Connection State:" $j.ConnectionState
}

#Return host to other mode.
if ($vmh.ConnectionState -eq 'Connected'){
Write-Host "Removing host " $j "from Maintence Mode."
Get-VMHost -Name $j.Name |Set-VMHost -State $vmh.ConnectionState
}

}}
