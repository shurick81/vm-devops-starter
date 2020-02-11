$crmPath = ( Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSCRM ).CRM_Server_InstallDir;
cd $crmPath
.\CertificateReconfiguration.ps1 -certificateFile c:\certs\crmsigning.contos00.local.pfx -password "576eeec5667" -updateCrm -certificateType S2STokenIssuer -serviceAccount "contos00\_crmsrv" -storeFindType FindBySubjectDistinguishedName
