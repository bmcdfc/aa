workflow Invoke-RunbookUsingAlerts
{
    param (     
        [object]$WebhookData 
    ) 
 
    # If runbook was called from Webhook, WebhookData will not be null.
    if ($WebhookData -ne $null) {   
        # Collect properties of WebhookData. 
        $WebhookName    =   $WebhookData.WebhookName 
        $WebhookBody    =   $WebhookData.RequestBody 
        $WebhookHeaders =   $WebhookData.RequestHeader 
 
        # Outputs information on the webhook name that called This 
        Write-Output "This runbook was started from webhook $WebhookName." 
 
 
        # Obtain the WebhookBody containing the AlertContext 
        $WebhookBody = (ConvertFrom-Json -InputObject $WebhookBody) 
        Write-Output "`nWEBHOOK BODY" 
        Write-Output "=============" 
        Write-Output $WebhookBody 
 
        # Obtain the AlertContext     
        $AlertContext = [object]$WebhookBody.context
 
        # Some selected AlertContext information 
        Write-Output "`nALERT CONTEXT DATA" 
        Write-Output "===================" 
        Write-Output $AlertContext.name 
        Write-Output $AlertContext.subscriptionId 
        Write-Output $AlertContext.resourceGroupName 
        Write-Output $AlertContext.resourceName 
        Write-Output $AlertContext.resourceType 
        Write-Output $AlertContext.resourceId 
        Write-Output $AlertContext.timestamp 
 
        # Act on the AlertContext data, in our case restarting the VM. 
        # Authenticate to your Azure subscription using Organization ID to be able to restart that Virtual Machine. 
        $cred = Get-AutomationPSCredential -Name "ContosoAccount" 
        Add-AzureAccount -Credential $cred 
        Select-AzureSubscription -subscriptionName "Windows Azure MSDN - Visual Studio Ultimate" 
 
        #Check the status property of the VM
        Write-Output "Status of VM before taking action"
        Get-AzureVM -Name $AlertContext.resourceName -ServiceName $AlertContext.resourceName
        Write-Output "Restarting VM"
 
        # Restart the VM by passing VM name and Service name which are same in this case
        Restart-AzureVM -ServiceName $AlertContext.resourceName -Name $AlertContext.resourceName 
        Write-Output "Status of VM after alert is active and takes action"
        Get-AzureVM -Name $AlertContext.resourceName -ServiceName $AlertContext.resourceName
    } 
    else  
    { 
        Write-Error "This runbook is meant to only be started from a webhook."  
    }  

}