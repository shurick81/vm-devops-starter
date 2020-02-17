$configName = "SP2019PreBin"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName SharePointDSC -ModuleVersion 3.7.0.0

        SPInstallPrereqs SPPrereqsInstalled
        {
            IsSingleInstance    = "Yes"
            InstallerPath       = "G:\Prerequisiteinstaller.exe"
            OnlineMode          = $true
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
    ) 
}
Write-Host "$(Get-Date) Compiling DSC"
try {
    &$configName `
        -ConfigurationData $configurationData;
}
catch {
    Write-Host "$(Get-Date) Exception in compiling DCS:";
    $_.Exception.Message
    Exit 1;
}
Write-Host "$(Get-Date) Starting DSC"
try {
    Start-DscConfiguration $configName -Verbose -Wait -Force;
}
catch {
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