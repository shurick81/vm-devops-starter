Add-PSSnapin Microsoft.SharePoint.PowerShell;
New-SPTrustedSecurityTokenIssuer -Name "crm" -IsTrustBroker:$false -MetadataEndpoint "https://crm.contoso.local/Contoso/XrmServices/2015/metadataendpoint.svc/json?orgName=Contoso";
$CrmRealmId = Get-Content "c:\Install\DynamicsCrmOrganizationId.txt";
$Identifier = "00000007-0000-0000-c000-000000000000@" + $CrmRealmId;
$site = Get-SPSite "https://intranet.contoso.local/sites/crmdocuments";
Set-SPSite "https://intranet.contoso.local/sites/crmdocuments" -SecondaryOwnerAlias ( whoami );
Register-SPAppPrincipal -site $site.RootWeb -NameIdentifier $Identifier -DisplayName "crm";
$app = Get-SPAppPrincipal -NameIdentifier $Identifier -Site $site.Rootweb;
$site = Get-SPSite "https://intranet.contoso.local/sites/crmdocuments";
Set-SPAppPrincipalPermission -AppPrincipal $app -Site $site.Rootweb -Scope SiteCollection -Right FullControl -EnableAppOnlyPolicy;
#New-SPClaimTypeMapping -IncomingClaimType "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" -IncomingClaimTypeDisplayName "EmailAddress" -SameAsIncoming

$url = "https://intranet.contoso.local/sites/crmdocuments";

$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force;
$SPInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_spadm", $securedPassword );
Connect-PnPOnline $url -Credential $SPInstallAccountCredential -NoTelemetry;
Apply-PnPProvisioningTemplate C:\projects\vm-devops-starter\src\spfarm\spdoccentertemplate.xml;

$userName = "contoso\_crmadmin";
$securedPassword = ConvertTo-SecureString "c0mp1Expa~~" -AsPlainText -Force;
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "contoso\_crmadmin", $securedPassword );
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
