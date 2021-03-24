# https://blogs.vmware.com/PowerCLI/2014/06/working-customization-specifications-powercli-part-3.html
# https://www.vmware.com/support/developer/PowerCLI/PowerCLI41U1/html/New-VM.html
# VM deployment script.

#Menu Options
$opt_menu = Read-Host -Prompt "Would you like to Deploy New VMs or Customize Existing VMs`n1. Deploy New VM`n2. Customize VM`nEnter Number"

#VM inport from file.
$New_VMs = Import-Csv ".\New_VMlist.csv"
Write-Host 'Starting'

foreach ($New_VM in $New_VMs) {
    $VM_Name = $New_VM.VM_Name                  #New VM Name.
    $Cluster = $New_VM.Cluster                  #Cluster Name
    $Template = $New_VM.Template_Name           #Template used for new VM.
    $Cust_Name = $New_VM.Customization_Name     #OS Customizaton Name.
    $FolderName = $New_VM.Folder_Name           #Folder location for new VM.
    $Datastore = $New_VM.Datastore              #Datastore for New VM.

if ($opt_menu -eq 1){

if ((Get-VM -Name $VM_Name -ErrorAction SilentlyContinue) -eq $null){
Write-Host 'Creating VM' $VM_Name -ForegroundColor Green
New-VM -Name $VM_Name -ResourcePool $Cluster -Template $Template -Location $FolderName -Datastore $Datastore -OSCustomizationSpec $Cust_Name -WhatIf
Start-VM -VM $VM_Name
}else {
Write-Host 'VM with name' $VM_Name 'already exist in vCenter' -ForegroundColor Yellow
}

}elseif($opt_menu -eq 2){
if ((Get-VM -Name $VM_Name -ErrorAction SilentlyContinue) -eq $null){
Write-Host "No VM found with Name"$VM_Name -ForegroundColor Red
}else{
Write-Host "Starting Customization of VMs" -ForegroundColor Green
Set-VM -VM $VM_Name -OSCustomizationSpec $Cust_Name -WhatIf
}}else{
Write-Host "Input not valid`nEnding Execution" -ForegroundColor Yellow
exit
}}
