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
    -LicenseKey WCPQN-33442-VH2RQ-M4RKF-GXYH4 `
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
    -BaseCurrencySymbol `$ `
    -BaseCurrencyPrecision 2 `
    -OrganizationCollation Latin1_General_CI_AI `
    -ReportingUrl http://$dbHostName/ReportServer_SPIntra01 `
    -InstallAccount $CRMInstallAccountCredential
Install-Dynamics365Update -MediaDir C:\Install\Dynamics\CRM2016ServicePack2Update03Enu -InstallAccount $CRMInstallAccountCredential
