Write-Host "$(Get-Date) Starting C:\Install\CRM\CRM2016-Server-KB3203310-ENU-Amd64\crmupdatewrapper.exe"
$timeStamp = ( Get-Date -Format u ).Replace(" ","-").Replace(":","-");
Start-Process "C:\Install\CRM\CRM2016-Server-KB3203310-ENU-Amd64\crmupdatewrapper.exe" -ArgumentList "/q /log  C:\Install\CRM\CRMServicePackInstallationLog_$timeStamp.txt /norestart" -Wait
Write-Host "$(Get-Date) C:\Install\CRM\CRM2016-Server-KB3203310-ENU-Amd64\crmupdatewrapper.exe complete"
