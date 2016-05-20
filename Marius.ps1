#$Cred = Get-Credential
 
#Add-AzureRMAccount -ServicePrincipal -Credential $Cred -SubscriptionId "4d164e27-0709-4a8f-8de3-2ade6c65330f " -tenant "626bf1c8-b42f-456f-8064-eb7c6ed1a8e7"
 
#Find-AzureRmResource -TagName NIGHT_OFF -TagValue $true  | ?{ $_.ResourceType -eq "Microsoft.Compute/virtualMachines" } | G 
 
#Code used for creating the Azure Application Account
Login-AzureRmAccount -SubscriptionId 4d164e27-0709-4a8f-8de3-2ade6c65330f -TenantId 626bf1c8-b42f-456f-8064-eb7c6ed1a8e7
 
$context = Get-AzureRmContext
 
if($context)
{
    # Generate application password
    Add-Type -AssemblyName System.Web
    $password = [System.Web.Security.Membership]::GeneratePassword(32, 5)
 
    Write-Verbose "Password: $password" -Verbose
 
    # Create application
    $azureAdApplication = New-AzureRmADApplication -DisplayName "STRUCTIS Automation" -HomePage "https://structisautomation.bouygues-construction.com" -IdentifierUris "https://structisautomation.bouygues-construction.com" -Password $password -ErrorAction Stop
 
    # Create service principal linked to the application
    New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId -ErrorAction Stop | Out-Null
    
    do
    {
        # Assign the contributor role to the service principal
        $assignment = New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $azureAdApplication.ApplicationId -ErrorAction SilentlyContinue
        
        if(!$assignment)
        {
            Start-Sleep -Seconds 1
        }
    } # Loop while the role assignement fails (must wait for service principal creation propagation)
    while(!$assignment)
 
    return [pscustomobject][ordered]@{ 
                UserName = $azureAdApplication.ApplicationId ;  
                Password = $password ; 
                SubscriptionId = $context.Subscription.SubscriptionId; 
                TenantId = $context.Tenant.TenantId;
    }
} 
