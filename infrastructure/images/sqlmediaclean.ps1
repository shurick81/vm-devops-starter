$configName = "SQLMediaClean"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName StorageDsc -ModuleVersion 4.0.0.0

        Node $AllNodes.NodeName
        {

            if ( $env:SPDEVOPSSTARTER_LOCALSQL -eq 1 )
            {

                File SQLNoLocalMediaEnsure {
                    DestinationPath = "C:\Install\SQLInstall"
                    Recurse = $true
                    Type = "Directory"
                    Ensure = "Absent"
                    Force = $true
                }

                File SQLNoLocalMediaArchiveEnsure {
                    DestinationPath = "C:\Install\SQLServer2014SP1.zip"
                    Ensure = "Absent"
                }

            } else {

                $SQLImageUrl = "https://download.microsoft.com/download/2/F/8/2F8F7165-BB21-4D1E-B5D8-3BD3CE73C77D/SQLServer2014SP1-FullSlipstream-x64-ENU.iso";
                $SQLImageUrl -match '[^/\\&\?]+\.\w{3,4}(?=([\?&].*$|$))' | Out-Null
                $SQLImageFileName = $matches[0]
                $SQLImageDestinationPath = "C:\Install\SQL2014SP1Image\$SQLImageFileName"

                MountImage SQLServerImageNotMounted
                {
                    ImagePath   = $SQLImageDestinationPath
                    Ensure      = 'Absent'
                }

                File SQLServerImageAbsent {
                    Ensure          = "Absent"
                    DestinationPath = $SQLImageDestinationPath
                    Force           = $true
                    DependsOn       = "[MountImage]SQLServerImageNotMounted"
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
