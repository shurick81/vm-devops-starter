$configName = "RSConfig"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $ShortDomainAdminCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $DomainSafeModeAdministratorPasswordCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
#        Import-DscResource -ModuleName CertificateDsc -ModuleVersion 4.7.0.0
        Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 11.1.0.0
        Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.4.0.0

        $domainName = "contos00.local";

        Node $AllNodes.NodeName
        {
#            $pfxPassword = "576eeec5667";
#            $securedPassword = ConvertTo-SecureString $pfxPassword -AsPlainText -Force
#            $pfxCredential = New-Object System.Management.Automation.PSCredential( "fake", $securedPassword )
#
#            $hostName = "db01.contos00.local"
#            $pfxPath = "c:\certs\$hostName.pfx";
#            $cerPath = "c:\certs\$hostName.cer";
#            $pfx = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2";
#            $pfx.Import($pfxPath,$pfxPassword,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet);
#
#            PfxImport rshost
#            {
#                Thumbprint  = $pfx.thumbprint
#                Path        = $pfxPath
#                Location    = 'LocalMachine'
#                Store       = 'My'
#                Credential  = $pfxCredential
#            }
#
#            CertificateExport rshost
#            {
#                Type        = 'CERT'
#                Thumbprint  = $pfx.thumbprint
#                Path        = $cerPath
#                DependsOn   = "[PfxImport]rshost"
#            }
#
#            CertificateImport rshost
#            {
#                Thumbprint  = $pfx.thumbprint
#                Location    = 'LocalMachine'
#                Store       = 'Root'
#                Path        = $cerPath
#                DependsOn   = "[CertificateExport]rshost"
#            }

            SqlRS ReportingServicesConfig
            {
                InstanceName                 = 'SQLInstance01'
                DatabaseServerName           = 'localhost'
                DatabaseInstanceName         = 'SQLInstance01'
                #ReportServerVirtualDirectory = 'MyReportServer'
                ReportServerReservedUrl      = @( 'http://+:80' )
                #ReportsVirtualDirectory      = 'MyReports'
                #ReportsReservedUrl           = @( 'http://+:80', 'https://+:443' )
                #UseSsl                       = $true
            }

            FireWall AllowHTTP
            {
                Name        = "HTTP"
                DisplayName = "HTTP"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                LocalPort   = 80
                Protocol    = "TCP"
                Description = "Firewall rule to allow web sites publishing"
            }
            
            FireWall WMI-WINMGMT-In-TCP
            {
                Name        = "WMI-WINMGMT-In-TCP"
                Enabled     = "True"
            }
            
            FireWall WMI-RPCSS-In-TCP
            {
                Name        = "WMI-RPCSS-In-TCP"
                Enabled     = "True"
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

$securedPassword = ConvertTo-SecureString "Fractalsol365" -AsPlainText -Force
$ShortDomainAdminCredential = New-Object System.Management.Automation.PSCredential( "vagrant", $securedPassword )
$securedPassword = ConvertTo-SecureString "sUp3rcomp1eX" -AsPlainText -Force
$DomainSafeModeAdministratorPasswordCredential = New-Object System.Management.Automation.PSCredential( "fakeaccount", $securedPassword )
Write-Host "$(Get-Date) Compiling DSC"
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -ShortDomainAdminCredential $ShortDomainAdminCredential `
        -DomainSafeModeAdministratorPasswordCredential $DomainSafeModeAdministratorPasswordCredential;
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
