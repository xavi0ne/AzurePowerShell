

#Login to Azure Government 
Connect-AzAccount -Environment AzureUSGovernment -ServicePrincipal -CertificateThumbprint "<thumbprint>"  `
-ApplicationId "<app/clientId>" `
-Tenant "<tenantId>" `
-subscription "<subscriptionId>"

# Perform Azure Policy Compliance Scan 
$scanPolicyJob = Start-AzPolicyComplianceScan -AsJob
$scanPolicyJob | Wait-Job
Write-Output "Azure Policy Scan has completed"

# Check if 'TAZ – Deploy Resource Lock on Resource Group' has non-compliant resource groups. 
$nonCompliantPolicies = Get-AzPolicyState | Where-Object { $_.ComplianceState -eq "NonCompliant" -and $_.PolicyDefinitionAction -eq "deployIfNotExists" -and $_.PolicyAssignmentID -eq "<policyAssignmentId>"}

# Initialize counts to track number of non-Compliant Policies to remediate
$Count = 0
$Totalcount = $nonCompliantPolicies.Count

    # loop through and start individual tasks per policy 
    foreach ($policy in $nonCompliantPolicies) 
    {  
        try {
            $Count++
            if ($policy)
            {
            write-output "Creating remediation for Policy $Count of $Totalcount - Remediation - $policy.PolicyDefinitionReferenceId"
            $remediationName = "rem." + $policy.PolicyDefinitionName
            $remediateJob = Start-AzPolicyRemediation -Name $remediationName -PolicyAssignmentId $policy.PolicyAssignmentId `
            -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -AsJob 
            $remediateJob | Wait-Job
            Write-Output "Remediation task for $($policy): success"
            }
        }
        catch
        {
            Write-Output "Something went wrong creating the policy remediation task" -ForegroundColor Red
        }
      
    }
