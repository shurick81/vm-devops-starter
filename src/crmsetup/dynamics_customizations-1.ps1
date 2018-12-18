Write-Host $env:COMPUTERNAME;
$configName = "CRMCustomizations"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $CRMInstallAccountCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName CertificateDsc -ModuleVersion 4.1.0.0
        Import-DscResource -ModuleName xWebAdministration -ModuleVersion 1.19.0.0
        Import-DSCResource -Module xSystemSecurity -Name xIEEsc -ModuleVersion 1.4.0.0

        Node $AllNodes.NodeName
        {
            $pfxPassword = "asd94y3475n";
            $securedPassword = ConvertTo-SecureString $pfxPassword -AsPlainText -Force
            $pfxCredential = New-Object System.Management.Automation.PSCredential( "fake", $securedPassword )

            $hostName = "$env:COMPUTERNAME.contoso.local";
            $pfxPath = "c:\certs\$hostName.pfx";
            $cerPath = "c:\certs\$hostName.cer";
            $pfx = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2";
            $pfx.Import($pfxPath,$pfxPassword,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet);

            PfxImport crmhost
            {
                Thumbprint  = $pfx.thumbprint
                Path        = $pfxPath
                Location    = 'LocalMachine'
                Store       = 'My'
                Credential  = $pfxCredential
            }

            CertificateExport crmhost
            {
                Type        = 'CERT'
                Thumbprint  = $pfx.thumbprint
                Path        = $cerPath
                DependsOn   = "[PfxImport]crmhost"
            }

            CertificateImport crmhost
            {
                Thumbprint  = $pfx.thumbprint
                Location    = 'LocalMachine'
                Store       = 'Root'
                Path        = $cerPath
                DependsOn   = "[CertificateExport]crmhost"
            }

            xWebsite WA01Site
            {
                Name        = "Microsoft Dynamics CRM"
                State       = "Started"
                BindingInfo = @(
                    MSFT_xWebBindingInformation {
                        Protocol = "HTTP"
                        Port = 5555
                    }
                    MSFT_xWebBindingInformation {
                        Protocol = "HTTPS"
                        Port = 443
                        CertificateThumbprint = $pfx.thumbprint
                        CertificateStoreName = "My"
                        HostName = "$env:COMPUTERNAME.contoso.local"
                        SslFlags = 1
                    }
                )
            }

            Registry CrmLocalZone
            {
                Ensure                  = "Present"
                Key                     = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$env:COMPUTERNAME.contoso.local"
                ValueName               = "https"
                ValueType               = "DWord"
                ValueData               = "1"
                PsDscRunAsCredential    = $CRMInstallAccountCredential
            }

            xIEEsc DisableIEEsc
            {
                IsEnabled   = $false;
                UserRole    = "Administrators"
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
$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );

$configurationData = @{ AllNodes = @(
    @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
) }
Write-Host "$(Get-Date) Compiling DSC"
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -CRMInstallAccountCredential $CRMInstallAccountCredential;
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