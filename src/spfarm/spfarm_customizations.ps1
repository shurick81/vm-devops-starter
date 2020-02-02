$configName = "SPFarm"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SPInstallAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SPServicesAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SPWebAppPoolAccountCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName SharePointDSC -ModuleVersion 3.7.0.0
        Import-DscResource -ModuleName CertificateDsc -ModuleVersion 4.7.0.0
        Import-DscResource -ModuleName xWebAdministration -ModuleVersion 3.1.1

        Node $AllNodes.NodeName
        {
            $pfxPassword = "576eeec5667";
            $securedPassword = ConvertTo-SecureString $pfxPassword -AsPlainText -Force
            $pfxCredential = New-Object System.Management.Automation.PSCredential( "fake", $securedPassword )

            $hostName = "intranet.contoso.local";
            $pfxPath = "c:\certs\$hostName.pfx";
            $cerPath = "c:\certs\$hostName.cer";
            $pfx = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2";
            $pfx.Import($pfxPath,$pfxPassword,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet);

            SPManagedAccount SharePointServicesPoolAccount
            {
                AccountName             = $SPServicesAccountCredential.UserName
                Account                 = $SPServicesAccountCredential
                PsDscRunAsCredential    = $SPInstallAccountCredential
            }

            SPServiceAppPool SharePointServicesAppPool
            {
                Name                    = "SharePoint Services App Pool"
                ServiceAccount          = $SPServicesAccountCredential.UserName
                PsDscRunAsCredential    = $SPInstallAccountCredential
                DependsOn               = "[SPManagedAccount]SharePointServicesPoolAccount"
            }

            SPManagedMetaDataServiceApp ManagedMetadataServiceApp
            {
                DatabaseName            = "SP_Intra_Metadata";
                ApplicationPool         = "SharePoint Services App Pool";
                ProxyName               = "Managed Metadata Service Application";
                Name                    = "Managed Metadata Service Application";
                Ensure                  = "Present";
                TermStoreAdministrators = @( $SPInstallAccountCredential.UserName, "contoso\OG SharePoint2016 Server Admin Prod" );
                PsDscRunAsCredential    = $SPInstallAccountCredential
                DependsOn               = "[SPServiceAppPool]SharePointServicesAppPool"
            }

            SPManagedMetaDataServiceAppDefault ManagedMetadataServiceAppDefault
            {
                IsSingleInstance                = "Yes"
                DefaultSiteCollectionProxyName  = "Managed Metadata Service Application"
                DefaultKeywordProxyName         = "Managed Metadata Service Application"
                PsDscRunAsCredential            = $SPInstallAccountCredential
                DependsOn                       = "[SPManagedMetaDataServiceApp]ManagedMetadataServiceApp"
            }
            
            SPSubscriptionSettingsServiceApp SubscriptionSettingsServiceApp 
            { 
                Name                    = "Subscription Settings Service Application" 
                ApplicationPool         = "SharePoint Services App Pool" 
                DatabaseName            = "SP_Intra_SubscriptionSettings" 
                PsDscRunAsCredential    = $SPInstallAccountCredential 
                DependsOn               = "[SPServiceAppPool]SharePointServicesAppPool" 
            } 

            SPAppManagementServiceApp AppManagementServiceApp 
            { 
                Name                    = "App Management Service Application" 
                ApplicationPool         = "SharePoint Services App Pool" 
                DatabaseName            = "SP_Intra_AppManagement" 
                PsDscRunAsCredential    = $SPInstallAccountCredential 
                DependsOn               = "[SPSubscriptionSettingsServiceApp]SubscriptionSettingsServiceApp" 
            } 

            SPManagedAccount ApplicationWebPoolAccount
            {
                AccountName             = $SPWebAppPoolAccountCredential.UserName
                Account                 = $SPWebAppPoolAccountCredential
                PsDscRunAsCredential    = $SPInstallAccountCredential
            }

            SPWebApplication DefaultWebApp
            {
                Name                    = "WA00"
                ApplicationPool         = "All Web Applications"
                ApplicationPoolAccount  = $SPWebAppPoolAccountCredential.UserName
                WebAppUrl               = "http://$NodeName"
                Port                    = 80
                DatabaseName            = "SP_Intra_Content_WA00"
                PsDscRunAsCredential    = $SPInstallAccountCredential
                DependsOn               = "[SPManagedAccount]ApplicationWebPoolAccount"
            }
        
            SPSite DefaultPathSite
            {
                Url                     = "http://$NodeName"
                OwnerAlias              = $SPInstallAccountCredential.UserName
                Name                    = "Default Team Site"
                Template                = "STS#0"
                PsDscRunAsCredential    = $SPInstallAccountCredential
                DependsOn               = "[SPWebApplication]DefaultWebApp"
            }

            SPSite DefaultHostNamedSite
            {
                Url                         = "https://intranet.contoso.local"
                OwnerAlias                  = $SPInstallAccountCredential.UserName
                Name                        = "Default Team Site"
                Template                    = "BDR#0"
                HostHeaderWebApplication    = "http://$NodeName"
                PsDscRunAsCredential        = $SPInstallAccountCredential
                DependsOn                   = "[SPWebApplication]DefaultWebApp"
            }

            SPSite PersonDocumentsSite
            {
                Url                         = "https://intranet.contoso.local/sites/person"
                OwnerAlias                  = $SPInstallAccountCredential.UserName
                Name                        = "Default Team Site"
                Template                    = "SPSMSITEHOST#0"
                HostHeaderWebApplication    = "http://$NodeName"
                PsDscRunAsCredential        = $SPInstallAccountCredential
                DependsOn                   = "[SPSite]DefaultHostNamedSite"
            }

            SPSite CrmDocumentsSite
            {
                Url                         = "https://intranet.contoso.local/sites/crmdocuments"
                OwnerAlias                  = $SPInstallAccountCredential.UserName
                Name                        = "Default Team Site"
                Template                    = "BDR#0"
                HostHeaderWebApplication    = "http://$NodeName"
                PsDscRunAsCredential        = $SPInstallAccountCredential
                DependsOn                   = "[SPSite]DefaultHostNamedSite"
            }

            SPUserProfileServiceApp UserProfileServiceApp
            {
                Name                    = "User Profile Service Application"
                ApplicationPool         = "SharePoint Services App Pool"
                ProfileDBName           = "SP_Intra_Profile"
                SocialDBName            = "SP_Intra_Profile_Social"
                SyncDBName              = "SP_Intra_Profile_Sync"
                EnableNetBIOS           = $false
                MySiteHostLocation      = "https://intranet.contoso.local/sites/person"
                PsDscRunAsCredential    = $SPInstallAccountCredential
                DependsOn               = "[SPSite]PersonDocumentsSite"
            }

            PfxImport WebHost
            {
                Thumbprint  = $pfx.thumbprint
                Path        = $pfxPath
                Location    = 'LocalMachine'
                Store       = 'My'
                Credential  = $pfxCredential
            }

            CertificateExport WebHost
            {
                Type        = 'CERT'
                Thumbprint  = $pfx.thumbprint
                Path        = $cerPath
                DependsOn   = "[PfxImport]WebHost"
            }

            CertificateImport WebHost
            {
                Thumbprint  = $pfx.thumbprint
                Location    = 'LocalMachine'
                Store       = 'Root'
                Path        = $cerPath
                DependsOn   = "[CertificateExport]WebHost"
            }

            xWebsite WA01Site
            {
                Name        = "WA00"
                State       = "Started"
                BindingInfo = @(
                    MSFT_xWebBindingInformation {
                        Protocol = "HTTP"
                        Port = 80
                    }
                    MSFT_xWebBindingInformation {
                        Protocol = "HTTPS"
                        Port = 443
                        CertificateThumbprint = $pfx.thumbprint
                        CertificateStoreName = "My"
                        HostName = "intranet.contoso.local"
                        SslFlags = 1
                    }
                )
                DependsOn   = "[SPWebApplication]DefaultWebApp", "[PfxImport]WebHost"
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
$SPInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_spadm", $securedPassword );
$SPServicesAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_spsrv", $securedPassword );
$SPWebAppPoolAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_spwebapppool", $securedPassword );

$configurationData = @{ AllNodes = @(
    @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
) }
Write-Host "$(Get-Date) Compiling DSC"
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -SPInstallAccountCredential $SPInstallAccountCredential `
        -SPServicesAccountCredential $SPServicesAccountCredential `
        -SPWebAppPoolAccountCredential $SPWebAppPoolAccountCredential;
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
