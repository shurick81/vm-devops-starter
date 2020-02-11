$domainName = (Get-WmiObject Win32_ComputerSystem).Domain;
$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmadmin", $securedPassword );
Invoke-Command "$env:COMPUTERNAME.$domainName" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    $dbHostName = $env:COMPUTERNAME
    $securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
    $CRMServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmsrv", $securedPassword );
    $DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmdplsrv", $securedPassword );
    $SandboxServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmsandbox", $securedPassword );
    $VSSWriterServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmvsswrit", $securedPassword );
    $AsyncServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmasync", $securedPassword );
    $MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmmon", $securedPassword );
    Install-Dynamics365Server `
        -MediaDir c:\Install\Dynamics\CRM2016RTMSve `
        -LicenseKey WCPQN-33442-VH2RQ-M4RKF-GXYH4 `
        -CreateDatabase `
        -SqlServer $dbHostName\SQLInstance01 `
        -PrivUserGroup "CN=CRM01PrivUserGroup,OU=CRM groups,DC=contos00,DC=local" `
        -SQLAccessGroup "CN=CRM01SQLAccessGroup,OU=CRM groups,DC=contos00,DC=local" `
        -UserGroup "CN=CRM01UserGroup,OU=CRM groups,DC=contos00,DC=local" `
        -ReportingGroup "CN=CRM01ReportingGroup,OU=CRM groups,DC=contos00,DC=local" `
        -PrivReportingGroup "CN=CRM01PrivReportingGroup,OU=CRM groups,DC=contos00,DC=local" `
        -CrmServiceAccount $CRMServiceAccountCredential `
        -DeploymentServiceAccount $DeploymentServiceAccountCredential `
        -SandboxServiceAccount $SandboxServiceAccountCredential `
        -VSSWriterServiceAccount $VSSWriterServiceAccountCredential `
        -AsyncServiceAccount $AsyncServiceAccountCredential `
        -MonitoringServiceAccount $MonitoringServiceAccountCredential `
        -CreateWebSite `
        -WebSitePort 5555 `
        -WebSiteUrl https://crm.contos00.local `
        -Organization "Contos00 Ltd." `
        -OrganizationUniqueName Contos00 `
        -BaseISOCurrencyCode SEK `
        -BaseCurrencyName "Svensk krona" `
        -BaseCurrencySymbol kr `
        -ReportingUrl http://$dbHostName/ReportServer_SQLInstance01
}
Invoke-Command "$env:COMPUTERNAME.$domainName" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    Install-Dynamics365Update -MediaDir C:\Install\Dynamics\CRM2016ServicePack2Update13Enu
}
