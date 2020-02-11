Add-PSSnapin Microsoft.SharePoint.PowerShell;
New-SPTrustedSecurityTokenIssuer -Name "crm" -IsTrustBroker:$false -MetadataEndpoint "https://crm.contos00.local/Contos00/XrmServices/2015/metadataendpoint.svc/json?orgName=Contos00";
$CrmRealmId = Get-Content "c:\Install\DynamicsCrmOrganizationId.txt";
$Identifier = "00000007-0000-0000-c000-000000000000@" + $CrmRealmId;
$site = Get-SPSite "https://intranet.contos00.local/sites/crmdocuments";
Set-SPSite "https://intranet.contos00.local/sites/crmdocuments" -SecondaryOwnerAlias ( whoami );
Register-SPAppPrincipal -site $site.RootWeb -NameIdentifier $Identifier -DisplayName "crm";
$app = Get-SPAppPrincipal -NameIdentifier $Identifier -Site $site.Rootweb;
$site = Get-SPSite "https://intranet.contos00.local/sites/crmdocuments";
Set-SPAppPrincipalPermission -AppPrincipal $app -Site $site.Rootweb -Scope SiteCollection -Right FullControl -EnableAppOnlyPolicy;
#New-SPClaimTypeMapping -IncomingClaimType "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" -IncomingClaimTypeDisplayName "EmailAddress" -SameAsIncoming

$url = "https://intranet.contos00.local/sites/crmdocuments";

$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force;
$SPInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_spadm", $securedPassword );
Connect-PnPOnline $url -Credential $SPInstallAccountCredential -NoTelemetry;
Apply-PnPProvisioningTemplate C:\projects\vm-devops-starter\src\spfarm\spdoccentertemplate.xml;

$userName = "contos00\_crmadmin";
$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force;
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contos00\_crmadmin", $securedPassword );
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll";
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll";
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll";
$attemptsLeft = $timesThreshold;
$ctx = New-Object Microsoft.SharePoint.Client.ClientContext( $url );
$ctx.Credentials = $CRMInstallAccountCredential.GetNetworkCredential();
$peopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager( $ctx );
$userProfile = $peopleManager.GetPropertiesFor( $userName );
$ctx.Load( $userProfile );
$ctx.ExecuteQuery();
