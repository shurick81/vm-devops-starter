$certPassword = "asd94y3475n";
$hostName = "crmsigning.contoso.local";
$pfxPass = ConvertTo-SecureString $certPassword -AsPlainText -Force;

# For Windows Server 2016 only
# $cert = New-SelfSignedCertificate -DnsName $hostName -KeySpec KeyExchange -TextExtension "2.5.29.37={text}1.3.6.1.5.5.7.3.1" -NotAfter (Get-Date).AddYears(10);

# For Windows Server 2012
$name = new-object -com "X509Enrollment.CX500DistinguishedName.1"
$name.Encode("CN=$hostName", 0)

$key = new-object -com "X509Enrollment.CX509PrivateKey.1"
$key.ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
$key.KeySpec = 1
$key.Length = 2048
$key.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"
$key.MachineContext = 1
$key.ExportPolicy = 1
$key.Create()

$serverauthoid = new-object -com "X509Enrollment.CObjectId.1"
$serverauthoid.InitializeFromValue("1.3.6.1.5.5.7.3.1")
$ekuoids = new-object -com "X509Enrollment.CObjectIds.1"
$ekuoids.add($serverauthoid)
$ekuext = new-object -com "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"
$ekuext.InitializeEncode($ekuoids)

$hashAlgorithm = New-Object -ComObject X509Enrollment.CObjectId 
$hashAlgorithm.InitializeFromAlgorithmName(1,0,0,"MD5") 

$cert = new-object -com "X509Enrollment.CX509CertificateRequestCertificate.1"
$cert.InitializeFromPrivateKey(2, $key, "")
$cert.Subject = $name
$cert.Issuer = $cert.Subject
$cert.NotBefore = Get-Date
$cert.NotAfter = $cert.NotBefore.AddYears(10)
$cert.X509Extensions.Add($ekuext)
$cert.HashAlgorithm = $hashAlgorithm 
$cert.Encode()

$enrollment = new-object -com "X509Enrollment.CX509Enrollment.1"
$enrollment.InitializeFromRequest($cert)
$certdata = $enrollment.CreateRequest(0)
$enrollment.InstallResponse(2, $certdata, 0, "")

$cert = Get-ChildItem cert:\\localmachine\my | ? { $_.Subject -eq "CN=$hostName" }

New-Item -Path c:\certs -ItemType Directory -Force | Out-Null;
$cert | Export-PfxCertificate -FilePath "c:\certs\$hostName.pfx" -Password $pfxPass -Force | Out-Null;
$cert | Remove-Item -Force;

