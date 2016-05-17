#Bodek and Rhodes
#Real Paths, Username, and Password have been altered to not give away any sensitive info.
Remove-item M:\Archive\Ares\Inventory\HerculesEDI\Bodek\stkex2.out
Remove-item M:\Archive\Ares\Inventory\HerculesEDI\Bodek\stkex2.zip
$webclient = New-Object System.Net.WebClient
$data=$webclient.DownloadData("FTP://00000:AsWftp000000@00.000.000.00/FROMBODEK/stkex2.zip")
$data.length
[io.file]::WriteAllBytes("M:\Archive\Ares\Inventory\HerculesEDI\Bodek\stkex2.zip", $data) 

$shell_app = new-object -com shell.application

$zip_file = $shell_app.namespace("M:\Archive\Ares\Inventory\HerculesEDI\Bodek\stkex2.zip")
$destination = $shell_app.namespace("M:\Archive\Ares\Inventory\HerculesEDI\Bodek\")
$destination.Copyhere($zip_file.items())

#Charles River
Remove-item M:\Archive\Ares\Inventory\HerculesEDI\Charles` River\CRA_INVNT.CSV
Remove-item M:\Archive\Ares\Inventory\HerculesEDI\Charles` River\Working.CSV
$ftp = "ftp://cramkt.com/"
$user = "ares.cramkt.com"
$pass = Read-Host 'What is your password?' -AsSecureString
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($user, $pass)
$data=$webclient.DownloadData("FTP://ares.zzzzz.com:000:2822@cramkt.com/CRA_INVNT.CSV")
$data.length
[io.file]::WriteAllBytes("M:\Archive\Ares\Inventory\HerculesEDI\Charles River\CRA_INVNT.CSV", $data) 
$f = Import-Csv M:\Archive\Ares\Inventory\HerculesEDI\Charles` River\CRA_INVNT.CSV -Header Vendor,Style,Product,Col,Color_Description,Category,Size,Size_Group,UPCCODE,Features,Colors,Material,Imprint,Imprint_Type,Package,Production_Time,Dim,Br_Qty,Bronze,Br_Price___,Sl_Qty,Silver,Sl_Price___,Gl_Qty,Gold__,Gl_Price___,Stk_Qty,MSRP

$f | select UPCCODE,Stk_Qty | Export-Csv M:\Archive\Ares\Inventory\HerculesEDI\Charles` River\Working.csv -NoTypeInformation