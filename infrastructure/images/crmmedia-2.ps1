Start-Process -FilePath "C:\Install\CRM\CRM2016-Server-ENU-amd64.exe" -ArgumentList "/extract:C:\Install\CRM\CRM2016-Server-ENU-amd64 /passive /quiet" -Wait -NoNewWindow
Start-Process -FilePath "C:\Install\CRM\CRM2016-Mui-SVE-amd64.exe" -ArgumentList "/extract:C:\Install\CRM\CRM2016-Mui-SVE-amd64 /passive /quiet" -Wait -NoNewWindow
Start-Process -FilePath "C:\Install\CRM\CRM2016-Server-KB3203310-ENU-Amd64.exe" -ArgumentList "/extract:C:\Install\CRM\CRM2016-Server-KB3203310-ENU-Amd64 /passive /quiet" -Wait -NoNewWindow
Start-Process -FilePath "C:\Install\CRM\CRM2016-Server-KB4046795-ENU-Amd64.exe" -ArgumentList "/extract:C:\Install\CRM\CRM2016-Server-KB4046795-ENU-Amd64 /passive /quiet" -Wait -NoNewWindow
