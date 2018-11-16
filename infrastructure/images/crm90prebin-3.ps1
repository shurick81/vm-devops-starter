$DataStamp = get-date -Format yyyyMMddTHHmmss

$logFile = '{0}-{1}.log' -f "sqlncli.msi",$DataStamp
$MSIArguments = @(
    "/qn"
    "/i"
    ('"{0}"' -f "C:\Install\CRMPrerequisites\sqlncli.msi")
    "IACCEPTSQLNCLILICENSETERMS=YES"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
Sleep 10;

$logFile = '{0}-{1}.log' -f "SQLSysClrTypes.msi",$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f "C:\Install\CRMPrerequisites\SQLSysClrTypes.msi")
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
Sleep 10;

$logFile = '{0}-{1}.log' -f "SharedManagementObjects.msi",$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f "C:\Install\CRMPrerequisites\SharedManagementObjects.msi")
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
Sleep 10;

$logFile = '{0}-{1}.log' -f "msodbcsql.msi",$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f "C:\Install\CRMPrerequisites\msodbcsql.msi")
    "/qn"
    "/norestart"
    "/L*v"
    $logFile
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
Sleep 10;

$logFile = '{0}-{1}.log' -f "dw20sharedamd64.msi",$DataStamp
$MSIArguments = @(
    "/i"
    ('"{0}"' -f "C:\Install\CRM\CRM9.0-Server-ENU-amd64\DW\dw20sharedamd64.msi")
    "/qn"
    "/norestart"
    "/LV*"
    $logFile
    "REBOOT=ReallySuppress"
    "APPGUID={0C524D55-1409-0080-BD7E-530E52560E52}"
    "REINSTALL=ALL"
    "REINSTALLMODE=vomus"
)
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow
Sleep 10;
