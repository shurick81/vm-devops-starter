$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
Invoke-Command -FilePath ".\crm90setup.ps1" "CRM01.contoso.local" -Credential $CRMInstallAccountCredential -Authentication CredSSP
