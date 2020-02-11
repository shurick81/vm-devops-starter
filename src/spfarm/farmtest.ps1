Try
{
    $securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
    $SPInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_spadm", $securedPassword );
    $farm = Invoke-Command DBSP01.contos00.local -Credential $SPInstallAccountCredential -Authentication CredSSP { Invoke-SPDSCCommand -ScriptBlock {
        Get-SPFarm;
    }}
    if ( $db ) {
        Write-Host "Found a farm";
    } else {
        Write-Host "Did not find a farm";
        Exit 1
    }
}
Catch
{
    Write-Host "Failed to get a farm";
    Exit 1;
}
Exit 0;