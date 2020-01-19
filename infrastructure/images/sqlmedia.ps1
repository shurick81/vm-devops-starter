$configName = "SQLMedia"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xPSDesiredStateConfiguration -Name xRemoteFile -ModuleVersion 8.4.0.0
        Import-DscResource -ModuleName StorageDsc -ModuleVersion 4.9.0.0

        Node $AllNodes.NodeName
        {

            if ( $env:SPDEVOPSSTARTER_LOCALSQL -eq 1 )
            {

                xRemoteFile SQLMediaArchive
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/SQLServer2014SP1.zip"
                    DestinationPath = "C:\Install\SQLServer2014SP1.zip"
                    MatchSource     = $false
                }

                Archive SQLMediaArchiveUnpacked
                {
                    Ensure      = "Present"
                    Path        = "C:\Install\SQLServer2014SP1.zip"
                    Destination = "C:\Install\SQLInstall"
                    DependsOn   = "[xRemoteFile]SQLMediaArchive"
                }
            
            } else {

                $SQLImageUrl = "https://download.microsoft.com/download/2/F/8/2F8F7165-BB21-4D1E-B5D8-3BD3CE73C77D/SQLServer2014SP1-FullSlipstream-x64-ENU.iso";
                $SQLImageUrl -match '[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))' | Out-Null
                $SQLImageFileName = $matches[0]
                $SQLImageDestinationPath = "C:\Install\SQL2014SP1Image\$SQLImageFileName"

                xRemoteFile SQLServerImageFilePresent
                {
                    Uri             = $SQLImageUrl
                    DestinationPath = $SQLImageDestinationPath
                    MatchSource     = $false
                }

                MountImage SQLServerImageMounted
                {
                    ImagePath   = $SQLImageDestinationPath
                    DriveLetter = 'F'
                    DependsOn   = "[xRemoteFile]SQLServerImageFilePresent"
                }
        
                WaitForVolume SQLServerImageMounted
                {
                    DriveLetter         = 'F'
                    RetryIntervalSec    = 5
                    RetryCount          = 10
                    DependsOn           = "[MountImage]SQLServerImageMounted"
                }

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
if ( $env:VMDEVOPSSTARTER_NODSCTEST -ne "TRUE" )
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
