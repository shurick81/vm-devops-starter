# Following https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/deploy/microsoft-dynamics-365-server-roles#group-membership-requirements ?
$configName = "CRMDomainCustomizations"
Write-Host "$(Get-Date) Defining DSC"
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SqlRSAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $CRMInstallAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $CRMServiceAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $DeploymentServiceAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SandboxServiceAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $VSSWriterServiceAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $AsyncServiceAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $MonitoringServiceAccountCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 5.0.0

        $domainName = "contoso.local";

        Node $AllNodes.NodeName
        {

            ADUser SqlRSAccountCredentialUser
            {
                DomainName              = $domainName
                UserName                = $SqlRSAccountCredential.GetNetworkCredential().UserName
                Password                = $SqlRSAccountCredential
                PasswordNeverExpires    = $true
            }
            
            ADUser CRMInstallAccountUser
            {
                DomainName              = $domainName
                UserName                = $CRMInstallAccountCredential.GetNetworkCredential().UserName
                Password                = $CRMInstallAccountCredential
                PasswordNeverExpires    = $true
            }
            
            ADUser CRMServiceAccountUser
            {
                DomainName              = $domainName
                UserName                = $CRMServiceAccountCredential.GetNetworkCredential().UserName
                Password                = $CRMServiceAccountCredential
                PasswordNeverExpires    = $true
            }
            
            ADUser DeploymentServiceAccountUser
            {
                DomainName              = $domainName
                UserName                = $DeploymentServiceAccountCredential.GetNetworkCredential().UserName
                Password                = $DeploymentServiceAccountCredential
                PasswordNeverExpires    = $true
            }

            ADUser SandboxServiceAccountUser
            {
                DomainName              = $domainName
                UserName                = $SandboxServiceAccountCredential.GetNetworkCredential().UserName
                Password                = $SandboxServiceAccountCredential
                PasswordNeverExpires    = $true
            }

            ADUser VSSWriterServiceAccountUser
            {
                DomainName              = $domainName
                UserName                = $VSSWriterServiceAccountCredential.GetNetworkCredential().UserName
                Password                = $VSSWriterServiceAccountCredential
                PasswordNeverExpires    = $true
            }

            ADUser AsyncServiceAccountUser
            {
                DomainName              = $domainName
                UserName                = $AsyncServiceAccountCredential.GetNetworkCredential().UserName
                Password                = $AsyncServiceAccountCredential
                PasswordNeverExpires    = $true
            }

            ADUser MonitoringServiceAccountUser
            {
                DomainName              = $domainName
                UserName                = $MonitoringServiceAccountCredential.GetNetworkCredential().UserName
                Password                = $MonitoringServiceAccountCredential
                PasswordNeverExpires    = $true
            }

            ADOrganizationalUnit CRMGroupsOU
            {
               Name = "CRM groups"
               Path = "DC=contoso,DC=local"
            }

            ADGroup CRMPrivUserGroup
            {
                GroupName           = "CRM01PrivUserGroup"
                MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
                GroupScope          = "Universal"
                Path                = 'OU=CRM groups,DC=contoso,DC=local'
                DependsOn           = "[ADOrganizationalUnit]CRMGroupsOU", "[ADUser]CRMInstallAccountUser"
            }
            
            ADObjectPermissionEntry OUPermissions
            {
                Ensure                              = 'Present'
                Path                                = 'OU=CRM groups,DC=contoso,DC=local'
                IdentityReference                   = 'contoso\CRM01PrivUserGroup'
                ActiveDirectoryRights               = 'GenericAll'
                AccessControlType                   = 'Allow'
                ObjectType                          = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance  = 'All'
                InheritedObjectType                 = '00000000-0000-0000-0000-000000000000'
                DependsOn                           = "[ADGroup]CRMPrivUserGroup"
            }
        
            ADGroup CRMSQLAccessGroup
            {
                GroupName   = "CRM01SQLAccessGroup"
                GroupScope  = "Universal"
                Path        = 'OU=CRM groups,DC=contoso,DC=local'
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU"
            }

            ADGroup CRMUserGroup
            {
                GroupName   = "CRM01UserGroup"
                Path        = 'OU=CRM groups,DC=contoso,DC=local'
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU"
            }

            ADGroup CRMReportingGroup
            {
                GroupName   = "CRM01ReportingGroup"
                GroupScope  = "Universal"
                Path        = 'OU=CRM groups,DC=contoso,DC=local'
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU"
            }

            ADGroup CRMPrivReportingGroup
            {
                GroupName           = "CRM01PrivReportingGroup"
                MembersToInclude    = $SqlRSAccountCredential.GetNetworkCredential().UserName
                GroupScope          = "Universal"
                Path                = 'OU=CRM groups,DC=contoso,DC=local'
                DependsOn           = "[ADOrganizationalUnit]CRMGroupsOU"
            }
            
            ADGroup EnterpriseAdminGroup
            {
                GroupName   = "Enterprise Admins"
                MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
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

$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force
$SqlRSAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_ssrs", $securedPassword );
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
$CRMServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmsrv", $securedPassword );
$DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmdplsrv", $securedPassword );
$SandboxServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmsandbox", $securedPassword );
$VSSWriterServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmvsswrit", $securedPassword );
$AsyncServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmasync", $securedPassword );
$MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmmon", $securedPassword );
Write-Host "$(Get-Date) Compiling DSC"
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -SqlRSAccountCredential $SqlRSAccountCredential `
        -CRMInstallAccountCredential $CRMInstallAccountCredential `
        -CRMServiceAccountCredential $CRMServiceAccountCredential `
        -DeploymentServiceAccountCredential $DeploymentServiceAccountCredential `
        -SandboxServiceAccountCredential $SandboxServiceAccountCredential `
        -VSSWriterServiceAccountCredential $VSSWriterServiceAccountCredential `
        -AsyncServiceAccountCredential $AsyncServiceAccountCredential `
        -MonitoringServiceAccountCredential $MonitoringServiceAccountCredential;
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
