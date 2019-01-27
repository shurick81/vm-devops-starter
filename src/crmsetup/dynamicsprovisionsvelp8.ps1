$dbHostName = $env:COMPUTERNAME
$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
$CRMServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmsrv", $securedPassword );
$DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmdplsrv", $securedPassword );
$SandboxServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmsandbox", $securedPassword );
$VSSWriterServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmvsswrit", $securedPassword );
$AsyncServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmasync", $securedPassword );
$MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmmon", $securedPassword );
Install-Dynamics365Server `
    -MediaDir c:\Install\Dynamics\CRM2016RTMEnu `
    -LicenseKey KKNV2-4YYK8-D8HWD-GDRMW-29YTW `
    -InstallDir "c:\Program Files\Microsoft Dynamics CRM" `
    -CreateDatabase `
    -SqlServer $dbHostName\SPIntra01 `
    -PrivUserGroup "CN=CRM01PrivUserGroup,OU=CRM groups,DC=contoso,DC=local" `
    -SQLAccessGroup "CN=CRM01SQLAccessGroup,OU=CRM groups,DC=contoso,DC=local" `
    -UserGroup "CN=CRM01UserGroup,OU=CRM groups,DC=contoso,DC=local" `
    -ReportingGroup "CN=CRM01ReportingGroup,OU=CRM groups,DC=contoso,DC=local" `
    -PrivReportingGroup "CN=CRM01PrivReportingGroup,OU=CRM groups,DC=contoso,DC=local" `
    -CrmServiceAccount $CRMServiceAccountCredential `
    -DeploymentServiceAccount $DeploymentServiceAccountCredential `
    -SandboxServiceAccount $SandboxServiceAccountCredential `
    -VSSWriterServiceAccount $VSSWriterServiceAccountCredential `
    -AsyncServiceAccount $AsyncServiceAccountCredential `
    -MonitoringServiceAccount $MonitoringServiceAccountCredential `
    -CreateWebSite `
    -WebSitePort 5555 `
    -WebSiteUrl https://$env:COMPUTERNAME.contoso.local `
    -Organization "Contoso Ltd." `
    -OrganizationUniqueName Contoso `
    -BaseISOCurrencyCode USD `
    -BaseCurrencyName "US Dollar" `
    -BaseCurrencySymbol  `$ `
    -BaseCurrencyPrecision 2 `
    -OrganizationCollation Latin1_General_CI_AI `
    -ReportingUrl http://$dbHostName/ReportServer_SPIntra01 `
    -InstallAccount $CRMInstallAccountCredential
Invoke-Command "$dbHostName.contoso.local" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    param( $dynHostName )
    if ( $dynHostName -eq $env:COMPUTERNAME )
    {
        Install-Dynamics365ReportingExtensions `
            -MediaDir c:\Install\Dynamics\CRM2016RTMEnu\SrsDataConnector `
            -InstanceName SPIntra01
    }
} -ArgumentList $env:COMPUTERNAME
Install-Dynamics365Language -MediaDir C:\Install\Dynamics\CRM2016LanguagePackSve
Add-PSSnapin Microsoft.Crm.PowerShell -ErrorAction Ignore;
if ( Get-PSSnapin Microsoft.Crm.PowerShell -ErrorAction Ignore ) {
    $importJobId = New-CrmOrganization `
        -Name ORGLANG1053 `
        -BaseLanguageCode 1053 `
        -Credential $CRMInstallAccountCredential `
        -DwsServerUrl "http://$env:COMPUTERNAME`:5555/XrmDeployment/2011/deployment.svc" `
        -DisplayName "Organization for testing 1053 language" `
        -SqlServerName $env:COMPUTERNAME\SPIntra01 `
        -BaseCurrencyCode SEK `
        -BaseCurrencyName "Svensk krona" `
        -BaseCurrencySymbol kr `
        -BaseCurrencyPrecision 2 `
        -SrsUrl http://$env:COMPUTERNAME/ReportServer_SPIntra01;
    do {
        Sleep 60;
        $operationStatus = Get-CrmOperationStatus -OperationId $importJobId -Credential $CRMInstallAccountCredential -DwsServerUrl "http://$env:COMPUTERNAME`:5555/XrmDeployment/2011/deployment.svc";
        Write-Host "$(Get-Date) operationStatus.State is $($operationStatus.State)";
    } while ( ( $operationStatus.State -ne "Completed" ) -and ( $operationStatus.State -ne "Failed" ) )
    if ( $operationStatus.State -eq "Completed" ) {
        Write-Host "Test OK";
    } else {
        Write-Host "Organization was not created properly";
        Exit 1;
    }
} else {
    "Could not load Microsoft.Crm.PowerShell PSSnapin";
    Exit 1;
}
