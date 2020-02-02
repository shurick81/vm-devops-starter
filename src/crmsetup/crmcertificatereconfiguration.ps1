cd "C:\Program Files\Dynamics 365\tools"
.\CertificateReconfiguration.ps1 -certificateFile c:\certs\crmsigning.contoso.local.pfx -password "576eeec5667" -updateCrm -certificateType S2STokenIssuer -serviceAccount "contoso\_crmsrv" -storeFindType FindBySubjectDistinguishedName
