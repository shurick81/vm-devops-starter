iisreset
$RemoveSnapInWhenDone = $False

if (-not (Get-PSSnapin -Name Microsoft.Crm.PowerShell -ErrorAction SilentlyContinue))
{
    Add-PSSnapin Microsoft.Crm.PowerShell
    $RemoveSnapInWhenDone = $True
}

$WebAddressSettings = Get-CrmSetting -SettingType WebAddressSettings

$WebAddressSettings.RootDomainScheme = "https"
$WebAddressSettings.WebAppRootDomain = "CRM01.contoso.local:443"
$WebAddressSettings.SdkRootDomain = "CRM01.contoso.local:443"
$WebAddressSettings.DiscoveryRootDomain = "CRM01.contoso.local:443"
$WebAddressSettings.DeploymentSdkRootDomain = "CRM01.contoso.local:443"

Set-CrmSetting -Setting $WebAddressSettings
Write-Host "Effective WebAddressSettings:"
$WebAddressSettings
$CrmOrganization = Get-CrmOrganization
Write-Host "Effective CrmOrganization:"
$CrmOrganization
Set-Content -Path "C:\Install\CRM\OrganizationId.txt" $CrmOrganization.Id

if($RemoveSnapInWhenDone)
{
    Remove-PSSnapin Microsoft.Crm.PowerShell
}