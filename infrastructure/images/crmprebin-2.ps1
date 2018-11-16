$configName = "CRMPreBin"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xPSDesiredStateConfiguration -Name xRemoteFile -ModuleVersion 8.4.0.0

        Node $AllNodes.NodeName
        {

            xRemoteFile CRMPrerequesite01
            {
                Uri             = "http://go.microsoft.com/fwlink/?LinkID=188401&clcid=0x409"
                DestinationPath = "C:\Install\CRMPrerequisites\sqlncli.msi"
                MatchSource     = $false
            }

            xRemoteFile CRMPrerequesite02
            {
                Uri             = "http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409"
                DestinationPath = "C:\Install\CRMPrerequisites\SQLSysClrTypes.msi"
                MatchSource     = $false
            }

            xRemoteFile CRMPrerequesite03
            {
                Uri             = "http://go.microsoft.com/fwlink/?LinkID=239659&clcid=0x409"
                DestinationPath = "C:\Install\CRMPrerequisites\SharedManagementObjects.msi"
                MatchSource     = $false
            }

            xRemoteFile CRMPrerequesite04
            {
                Uri             = "https://download.microsoft.com/download/F/B/7/FB728406-A1EE-4AB5-9C56-74EB8BDDF2FF/ReportViewer.msi"
                DestinationPath = "C:\Install\CRMPrerequisites\ReportViewer.msi"
                MatchSource     = $false
            }

        }
    }
}
catch
{
    Write-Host "$(Get-Date) Exception in defining DCS:"
    $_.Exception.Message
    Exit 1;
}
$configurationData = @{ AllNodes = @(
    @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
) }
Write-Host "$(Get-Date) Compiling DSC"
try
{
    &$configName `
        -ConfigurationData $configurationData;
}
catch
{
    Write-Host "$(Get-Date) Exception in compiling DCS:";
    $_.Exception.Message
    Exit 1;
}
Write-Host "$(Get-Date) Starting DSC"
try
{
    Start-DscConfiguration $configName -Verbose -Wait -Force;
}
catch
{
    Write-Host "$(Get-Date) Exception in starting DCS:"
    $_.Exception.Message
    Exit 1;
}
if ( $env:SPDEVOPSSTARTER_NODSCTEST -ne "TRUE" )
{
    Write-Host "$(Get-Date) Testing DSC"
    try {
        $result = Test-DscConfiguration $configName -Verbose;
        $inDesiredState = $result.InDesiredState;
        $failed = $false;
        $inDesiredState | % {
            if ( !$_ ) {
                Write-Host "$(Get-Date) Test failed"
                Exit 1;
            }
        }
    }
    catch {
        Write-Host "$(Get-Date) Exception in testing DCS:"
        $_.Exception.Message
        Exit 1;
    }
} else {
    Write-Host "$(Get-Date) Skipping tests"
}
Exit 0;
