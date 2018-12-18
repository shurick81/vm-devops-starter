$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
Invoke-Command "$env:COMPUTERNAME.contoso.local" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    c:\projects\vm-devops-starter\src\crmsetup\dynamics_customizations-1.ps1
}
