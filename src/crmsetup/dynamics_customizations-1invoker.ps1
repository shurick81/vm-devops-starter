$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmadmin", $securedPassword );
Invoke-Command "$env:COMPUTERNAME.contos00.local" -Credential $CRMInstallAccountCredential -Authentication CredSSP {
    c:\projects\vm-devops-starter\src\crmsetup\dynamics_customizations-1.ps1
}
