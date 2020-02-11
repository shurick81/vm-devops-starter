$configName = "CRMCertRoot"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName CertificateDsc -ModuleVersion 4.7.0.0

        Node $AllNodes.NodeName
        {
            $pfxPassword = "576eeec5667";
            $securedPassword = ConvertTo-SecureString $pfxPassword -AsPlainText -Force
            $pfxCredential = New-Object System.Management.Automation.PSCredential( "fake", $securedPassword )

            $hostName = "crm.contos00.local";
            $pfxPath = "c:\certs\$hostName.pfx";
            $cerPath = "c:\certs\$hostName.cer";
            $pfx = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2";
            $pfx.Import($pfxPath,$pfxPassword,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet);

            PfxImport CRMCert
            {
                Thumbprint  = $pfx.thumbprint
                Path        = $pfxPath
                Location    = 'LocalMachine'
                Store       = 'My'
                Credential  = $pfxCredential
            }

            CertificateExport CRMCert
            {
                Type        = 'CERT'
                Thumbprint  = $pfx.thumbprint
                Path        = $cerPath
                DependsOn   = "[PfxImport]CRMCert"
            }

            CertificateImport CRMCert
            {
                Thumbprint  = $pfx.thumbprint
                Location    = 'LocalMachine'
                Store       = 'Root'
                Path        = $cerPath
                DependsOn   = "[CertificateExport]CRMCert"
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