Write-Host "$(Get-Date) Starting C:\Install\CRM\CRM2016-Server-ENU-amd64\SetupServer.exe"
$timeStamp = ( Get-Date -Format u ).Replace(" ","-").Replace(":","-");
Start-Process "C:\Install\CRM\CRM2016-Server-ENU-amd64\SetupServer.exe" -ArgumentList "/Q /config C:\projects\vm-devops-starter\src\crmsetup\crm_config.xml /L C:\Install\CRM\CRMInstallationLog_$timeStamp.txt" -Wait;
Write-Host "$(Get-Date) C:\Install\CRM\CRM2016-Server-ENU-amd64\SetupServer.exe complete"
