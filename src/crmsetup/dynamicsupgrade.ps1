$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
if ( -not ( Get-PSSnapin -Name Microsoft.Crm.PowerShell -ErrorAction SilentlyContinue ) )
{
    Add-PSSnapin Microsoft.Crm.PowerShell
    $RemoveSnapInWhenDone = $True
}
Write-Host "$(Get-Date) Starting Import-CrmOrganization";
$importJobId = Import-CrmOrganization -DatabaseName Contoso_MSCRM_Old -SqlServerName $env:COMPUTERNAME\SPIntra01 -SrsUrl http://$env:COMPUTERNAME/ReportServer_SPIntra01 -UserMappingMethod ByAccount -DisplayName "Contoso LTD imported" -Name "ContosoImported" -Credential $CRMInstallAccountCredential -DwsServerUrl "http://$env:COMPUTERNAME`:5555/XrmDeployment/2011/deployment.svc";
$operationStatus = Get-CrmOperationStatus -OperationId $importJobId
do {
    Write-Host "$(Get-Date) Waiting until CRM installation job is done";
    Sleep 60;
    $operationStatus = Get-CrmOperationStatus -OperationId $importJobId;
} while ( ( $operationStatus.State -ne "Completed" ) -and ( $operationStatus.State -ne "Failed" ) )
Write-Host "$(Get-Date) Job is complete, State: $( $operationStatus.State )";
Write-Host $operationStatus.ProcessingError.Message;
if( $RemoveSnapInWhenDone )
{
    Remove-PSSnapin Microsoft.Crm.PowerShell
}
