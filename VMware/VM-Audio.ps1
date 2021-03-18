$vmName = "MyVM"

$vm = Get-VM -Name $vmName
$audio = $vm.ExtensionData.Config.Hardware.Device | where {$_.GetType().Name -eq "VirtualHdAudioCard"} 

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$dev = New-Object VMware.Vim.VirtualDeviceConfigSpec
$dev.Device = $audio
$dev.Operation = "remove"
$spec.deviceChange += $dev

$vm.ExtensionData.ReconfigVM($spec)
