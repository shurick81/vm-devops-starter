Get-WSManCredSSP
$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$SPInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_spadm", $securedPassword );
$result = Invoke-Command "OPS01.contos00.local" -Credential $SPInstallAccountCredential -Authentication CredSSP {
    Get-ChildItem c:\
}
if ( !$result )
{
    Write-Host "Test failed"
    Exit 1;
}
Write-Host "Test succeeded"
Exit 1;
