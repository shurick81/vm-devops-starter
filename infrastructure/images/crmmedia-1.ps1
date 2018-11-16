$configName = "CRMMedia"
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

            if ( $env:SPDEVOPSSTARTER_LOCALCRM -eq 1 )
            {

            } else {

                xRemoteFile CRMEnglishMediaDownloaded
                {
                    Uri             = "https://download.microsoft.com/download/3/4/F/34FB8C80-F245-41E7-AFE2-6388005A702B/CRM2016-Server-ENU-amd64.exe"
                    DestinationPath = "C:\Install\CRM\CRM2016-Server-ENU-amd64.exe"
                    MatchSource     = $false
                }

                xRemoteFile CRMSwedishLPDownloaded
                {
                    Uri             = "https://download.microsoft.com/download/1/F/7/1F7CBA49-5C7B-492A-982A-8D26B9608399/CRM2016-Mui-SVE-amd64.exe"
                    DestinationPath = "C:\Install\CRM\CRM2016-Mui-SVE-amd64.exe"
                    MatchSource     = $false
                }

                xRemoteFile CRMSP11Downloaded
                {
                    Uri             = "https://download.microsoft.com/download/C/C/9/CC9ADCB0-7D96-489F-8B1E-8468DF3CF0D1/CRM2016-Server-KB3203310-ENU-Amd64.exe"
                    DestinationPath = "C:\Install\CRM\CRM2016-Server-KB3203310-ENU-Amd64.exe"
                    MatchSource     = $false
                }
                
                xRemoteFile CRMSP2U02Downloaded
                {
                    Uri             = "https://download.microsoft.com/download/1/0/8/108ABED3-3EF6-4569-A096-DEAEC5C3450C/CRM2016-Server-KB4046795-ENU-Amd64.exe"
                    DestinationPath = "C:\Install\CRM\CRM2016-Server-KB4046795-ENU-Amd64.exe"
                    MatchSource     = $false
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
