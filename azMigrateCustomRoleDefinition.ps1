$role = Get-AzRoleDefinition "Contributor"
$role.Id = $null
$role.IsCustom = $true
$role.Name = "AzMigrateContributor"
$role.Description = "Can perform full operations for Azure Migrate."
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Migrate/*")
$role.Actions.Add("Microsoft.Compute/disks/read")
$role.Actions.Add("Microsoft.Compute/disks/write")
$role.Actions.Add("Microsoft.Compute/operations/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/write")
$role.Actions.Add("Microsoft.RecoveryServices/vaults/replicationFabrics/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("<subscriptionid>")
New-AzRoleDefinition -Role $role
