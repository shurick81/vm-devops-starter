Write-Host "$(Get-Date) Starting C:\Install\CRM\CRM2016-Mui-SVE-amd64\MuiSetup_1053_amd64.msi"

$logFile = '{0}-{1}.log' -f "MuiSetup_1053_amd64.msi",$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f "C:\Install\CRM\CRM2016-Mui-SVE-amd64\MuiSetup_1053_amd64.msi")
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
Write-Host "$(Get-Date) Finished C:\Install\CRM\CRM2016-Mui-SVE-amd64\MuiSetup_1053_amd64.msi"
Sleep 10;
