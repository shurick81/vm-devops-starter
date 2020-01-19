$configName = "DevBin"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName cChoco -ModuleVersion 2.3.1.0

        Node $AllNodes.NodeName
        {

            cChocoInstaller ChocoInstalled
            {
                InstallDir              = "c:\choco"
            }

            cChocoPackageInstaller VSCodeInstalled
            {
                Name                    = "visualstudiocode"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller ChromeInstalled
            {
                Name                    = "googlechrome"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller NotepadplusplusInstalled
            {
                Name                    = "notepadplusplus"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller SiddlerInstalled
            {
                Name                    = "fiddler"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
            
            cChocoPackageInstaller GitInstalled
            {
                Name                    = "git"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
            
            cChocoPackageInstaller SoapuiInstalled
            {
                Name                    = "soapui"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller NodejsInstalled
            {
                Name                    = "nodejs"
                Version                 = "10.16.3"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller Office365businessInstalled
            {
                Name                    = "office365business"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            WindowsFeatureSet DomainFeatures
            {
                Name                    = @( "RSAT-DNS-Server", "RSAT-ADDS", "RSAT-ADCS" )
                Ensure                  = 'Present'
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
