$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
Invoke-Command -FilePath ".\crmservicepacksetup8.1.1.1005.ps1" "CRM01.contoso.local" -Credential $CRMInstallAccountCredential -Authentication CredSSP
