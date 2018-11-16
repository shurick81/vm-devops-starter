$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
Invoke-Command "CRM01.contoso.local" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    c:\projects\vm-devops-starter\src\crmsetup\crm_customizations-2.ps1
}
