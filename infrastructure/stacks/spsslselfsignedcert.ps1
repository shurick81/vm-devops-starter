$certPassword = "576eeec5667";

$pfxPass = ConvertTo-SecureString $certPassword -AsPlainText -Force;
New-Item c:\certs -ItemType Directory
@(
    "intranet.contoso.local"
) | % {
    $hostName = $_;
    $cert = New-SelfSignedCertificate -DnsName $hostName -CertStoreLocation Cert:\LocalMachine\My;
    $cert | Export-PfxCertificate -FilePath "c:\certs\$hostName.pfx" -Password $pfxPass -Force | Out-Null;
    $cert | Remove-Item -Force;
}
