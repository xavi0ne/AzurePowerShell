#Pre-requisites:
    #Ensure Azure PowerShell Version 11.3.0 is installed on the host that runs the script. 
    #Ensure the VMs are Azure Gen2 Vms. 

$subscriptionName = "<subscriptionName>"

$resourceGroup = "<resourceGroupName>"

$vmNames = @("<vmName>", "<vmName>")

#Login to Azure US Government 
Connect-AzAccount -Environment AzureUSGovernment

#Select the target subscription
Set-AzContext -Subscription $subscriptionName

#Verify each VM exists and its current Security Type is not Trusted Launch
ForEach ($vmName in $vmNames) {
    
    $NoTrustedLaunch = get-azVM -resourceGroupName $resourceGroup -name $vmName | where-object {$_.SecurityProfile.SecurityType -ne "TrustedLaunch"}

    #For the VMs currently not TrustedLaunch, perform a shutdown
    ForEach ($vm in $NoTrustedLaunch) {

        if ($vm) {
            try {

                write-output "Performing vm shutdown to convert VM to TrustedLaunch"
                Stop-azVM -name $vm.Name -resourceGroupName $resourceGroup -force
                write-output "The VM $($vm.Name) has been deallocated and ready for TrustedLaunchConversion"
            }
            catch {
                Write-Output "The VM $($vm.Name) shutdown: unsuccesful; please reattempt shutdown before TrustedLaunch Conversion."
            }
        }
        try {
            write-output "Perform TrustedLaunch Conversion on the VM $($vm.Name)."
            Get-AzVM -ResourceGroupName $resourceGroup -Name $vm.Name | Update-AzVM -SecurityType TrustedLaunch -EnableSecureBoot $true -EnableVtpm $true
        }
        catch {
            write-output "The VM $($vm.Name) did not succeed in TrustedLaunch conversion. Please ensure pre-requisites have been met for the VM."
        }
    }
}

