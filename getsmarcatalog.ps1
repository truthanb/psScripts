$ftp = "ftp://stargate2.sanmar.com/"
$user = Read-Host 'What is your username?'
$pass = Read-Host 'What is your password?' -AsSecureString
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($user, $pass)
$data=$webclient.DownloadData("ftp://stargate2.sanmar.com/sanmarpdd/SanMar_EPDD.csv")
$data.length
[io.file]::WriteAllBytes("C:\Temp\SanMar_EPDD.csv", $data) 