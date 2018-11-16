$configName = "CRMPreBin"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {

        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node $AllNodes.NodeName
        {

            Script Install_Net_4.5.2
            {
                SetScript = {
                    $SourceURI = "https://download.microsoft.com/download/B/4/1/B4119C11-0423-477B-80EE-7A474314B347/NDP452-KB2901954-Web.exe"
                    $FileName = $SourceURI.Split('/')[-1]
                    $BinPath = Join-Path $env:SystemRoot -ChildPath "Temp\$FileName"
    
                    if (!(Test-Path $BinPath))
                    {
                        Invoke-Webrequest -Uri $SourceURI -OutFile $BinPath
                    }
    
                    write-verbose "Installing .Net 4.5.2 from $BinPath"
                    write-verbose "Executing $binpath /q /norestart"
                    Sleep 5
                    Start-Process -FilePath $BinPath -ArgumentList "/q /norestart" -Wait -NoNewWindow            
                    Sleep 5
                    Write-Verbose "Setting DSCMachineStatus to reboot server after DSC run is completed"
                    $global:DSCMachineStatus = 1
                }
    
                TestScript = {
                    [int]$NetBuildVersion = 379893
    
                    if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | %{$_ -match 'Release'})
                    {
                        [int]$CurrentRelease = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Release
                        if ($CurrentRelease -lt $NetBuildVersion)
                        {
                            Write-Verbose "Current .Net build version is less than 4.5.2 ($CurrentRelease)"
                            return $false
                        }
                        else
                        {
                            Write-Verbose "Current .Net build version is the same as or higher than 4.5.2 ($CurrentRelease)"
                            return $true
                        }
                    }
                    else
                    {
                        Write-Verbose ".Net build version not recognised"
                        return $false
                    }
                }
    
                GetScript = {
                    if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' | %{$_ -match 'Release'})
                    {
                        $NetBuildVersion =  (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').Release
                        return $NetBuildVersion
                    }
                    else
                    {
                        Write-Verbose ".Net build version not recognised"
                        return ".Net 4.5.2 not found"
                    }
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
