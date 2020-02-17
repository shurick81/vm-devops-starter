$configName = "SPMediaClean"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node $AllNodes.NodeName
        {

            File SPNoLocalMediaEnsure {
                DestinationPath = "C:\Install\SPInstall"
                Recurse = $true
                Type = "Directory"
                Ensure = "Absent"
                Force = $true
            }

            File SPNoLocalMediaArchiveEnsure {
                DestinationPath = "C:\Install\SPServer2013SP1.zip"
                Ensure = "Absent"
            }

            File NoSPMediaArchiveExe {
                DestinationPath = "C:\Install\SPServer2013SwSP11808.exe"
                Ensure = "Absent"
            }

            File NoSPMediaArchive001 {
                DestinationPath = "C:\Install\SPServer2013SwSP11808.7z.001"
                Ensure = "Absent"
            }

            File NoSPMediaArchive002 {
                DestinationPath = "C:\Install\SPServer2013SwSP11808.7z.002"
                Ensure = "Absent"
            }

            File NoSPMediaArchive003 {
                DestinationPath = "C:\Install\SPServer2013SwSP11808.7z.003"
                Ensure = "Absent"
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