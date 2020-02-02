$configName = "SPMedia"
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

            xRemoteFile SPMediaArchiveExe
            {
                Uri             = "https://aleksstore.blob.core.windows.net/common-assets/SPServer2013SwSP11808.exe?sp=r&st=2019-09-25T19:07:35Z&se=2021-06-09T03:07:35Z&spr=https&sv=2018-03-28&sig=F2WyouE%2BttkiFrxczD7fix%2BOFYFT1O8tSNjmJymBNCc%3D&sr=b"
                DestinationPath = "C:\Install\SPServer2013SwSP11808.exe"
                MatchSource     = $false
            }

            xRemoteFile SPMediaArchive001
            {
                Uri             = "https://aleksstore.blob.core.windows.net/common-assets/SPServer2013SwSP11808.7z.001?sp=r&st=2019-09-25T19:09:58Z&se=2029-09-26T03:09:58Z&spr=https&sv=2018-03-28&sig=8YfmBHbEVqTsb15DuLB3b8SpOxTg4Bx1eUeZ%2Fx%2F0Fvw%3D&sr=b"
                DestinationPath = "C:\Install\SPServer2013SwSP11808.7z.001"
                MatchSource     = $false
            }

            xRemoteFile SPMediaArchive002
            {
                Uri             = "https://aleksstore.blob.core.windows.net/common-assets/SPServer2013SwSP11808.7z.002?sp=r&st=2019-09-25T19:10:31Z&se=2029-09-26T03:10:31Z&spr=https&sv=2018-03-28&sig=nJjk4jqaIuz9QK214gzKFzV1G6mHbxDuJkRMrBBrZIs%3D&sr=b"
                DestinationPath = "C:\Install\SPServer2013SwSP11808.7z.002"
                MatchSource     = $false
            }

            xRemoteFile SPMediaArchive003
            {
                Uri             = "https://aleksstore.blob.core.windows.net/common-assets/SPServer2013SwSP11808.7z.003?sp=r&st=2019-09-25T19:08:36Z&se=2029-09-26T03:08:36Z&spr=https&sv=2018-03-28&sig=pZ%2BOXP7PeD931Do7JWgCGLu4Qa57NEvzyDLD4D7t%2F7I%3D&sr=b"
                DestinationPath = "C:\Install\SPServer2013SwSP11808.7z.003"
                MatchSource     = $false
            }

            Script SPMediaArchiveUnpacked
            {
                SetScript   = {
                    Start-Process -FilePath "C:\Install\SPServer2013SwSP11808.exe" -ArgumentList '-oC:\Install\SPInstall' -Wait;
                }
                TestScript  = {
                    $files = Get-ChildItem C:\Install\SPInstall -ErrorAction Ignore;
                    if ( $files ) {
                        Write-Host "Files found";
                        return $true;
                    } else {
                        Write-Host "Files not found";
                        return $false;
                    }
                }
                GetScript   = {
                    $files = Get-ChildItem C:\Install\SPInstall -ErrorAction Ignore;
                    return $files
                }
                DependsOn   = "[xRemoteFile]SPMediaArchiveExe", "[xRemoteFile]SPMediaArchive001", "[xRemoteFile]SPMediaArchive002", "[xRemoteFile]SPMediaArchive003"
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
