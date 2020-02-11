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
        -MediaDir c:\Install\Dynamics\Dynamics365Server90RTMEnu `
        -LicenseKey KKNV2-4YYK8-D8HWD-GDRMW-29YTW `
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
        -ReportingUrl http://$dbHostName/ReportServer_SQLInstance01
}
if ( $dbHostName -eq $env:COMPUTERNAME ) {
    Invoke-Command "$dbHostName.$domainName" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
        Install-Dynamics365ReportingExtensions `
            -MediaDir C:\Install\Dynamics\Dynamics365Server90RTMEnu\SrsDataConnector `
            -InstanceName SQLInstance01
    }
} else {
    Invoke-Command "$dbHostName.$domainName" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
        param( $fileShareHost )
        Install-Dynamics365ReportingExtensions `
            -MediaDir \\$fileShareHost\c$\Install\Dynamics\Dynamics365Server90RTMEnu\SrsDataConnector `
            -InstanceName SQLInstance01
    } -ArgumentList $env:COMPUTERNAME;
}
Install-Dynamics365Language -MediaDir C:\Install\Dynamics\Dynamics365Server90LanguagePackSve
Add-PSSnapin Microsoft.Crm.PowerShell -ErrorAction Ignore;
if ( Get-PSSnapin Microsoft.Crm.PowerShell -ErrorAction Ignore ) {
    $importJobId = New-CrmOrganization `
        -Name ORGLANG1053 `
        -BaseLanguageCode 1053 `
        -Credential $CRMInstallAccountCredential `
        -DwsServerUrl "http://$env:COMPUTERNAME`:5555/XrmDeployment/2011/deployment.svc" `
        -DisplayName "Organization for testing 1053 language" `
        -SqlServerName $env:COMPUTERNAME\SQLInstance01 `
        -BaseCurrencyCode SEK `
        -BaseCurrencyName "Svensk krona" `
        -BaseCurrencySymbol kr `
        -SrsUrl http://$env:COMPUTERNAME/ReportServer_SQLInstance01;
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
Invoke-Command "$env:COMPUTERNAME.$domainName" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    Install-Dynamics365Update -MediaDir C:\Install\Dynamics\Dynamics365Server90Update11Enu
}
if ( $dbHostName -eq $env:COMPUTERNAME ) {
    $mediaDir = "C:\Install\Dynamics\Dynamics365Server90ReportingExtensionsUpdate11Enu";
} else {
    $mediaDir = "\\$env:COMPUTERNAME\c$\Install\Dynamics\Dynamics365Server90ReportingExtensionsUpdate11Enu";
}
Write-Output "dbHostName is $dbHostName"
Invoke-Command "$dbHostName.$domainName" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    param( $mediaDir )
    Import-Module C:\test-projects\Dynamics365Configuration\src\Dynamics365Configuration\Dynamics365Configuration.psd1
    Write-Output "mediaDir is $mediaDir"
    Install-Dynamics365ReportingExtensionsUpdate -MediaDir $mediaDir `
        -LogFilePath c:\tmp\Dynamics365ServerInstallLog.txt `
        -LogFilePullIntervalInSeconds 15 `
        -LogFilePullToOutput
} -ArgumentList $mediaDir;
