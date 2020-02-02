Add-PSSnapin Microsoft.SharePoint.PowerShell
$c = Get-SPServiceContext -Site "https://intranet.contoso.local/sites/crmdocuments"
Set-SPAuthenticationRealm -ServiceContext $c -Realm "42ba318d-3986-4afb-b13e-85cd3c038150"
