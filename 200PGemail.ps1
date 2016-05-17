#This sends an email to Kathryn when it finds an order was placed by a distributor for some of the the 200PG colors that are on a special clearance, so she can go in and unclearance the products.
$serverName = "ProdSQL1"
$dbName = "Athena"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlCMD = New-Object System.Data.SqlClient.SqlCommand

$SqlConnection.ConnectionString="Server=$serverName;Database=$dbName;Integrated Security=SSPI"

$SqlConnection.Open()


$SqlCMD.CommandText="
Select o.[Id], j.[JobName]
From OrderView o
Inner Join Job j on j.OrderId = O.Id
Inner Join JobProduct jp on jp.JobId = j.Id
Inner Join ProductColor pc on pc.Id = jp.ProductColorId
Where o.CustomerId in(46087, 2287451, 46082, 2274185, 2288094, 45711, 60505, 2284734, 2282696, 49725)
and pc.id in(265069, 264985, 264986, 265014, 265012, 264983, 264987, 265015, 264984, 265013) 
and o.FinalizedDate > dateadd(day, -30, getdate())
"

$SqlCMD.Connection = $SqlConnection

$idResults = @()

$SqlReturn=$SqlCMD.ExecuteReader()

$emailFrom = "ben@areswear.com"
$emailTo = "kpond@dyenomite.com"
$today = get-date -Format MM/dd/yyyy
$subject = "200PG in distributor orders $today"
$body = "Here are some orders with 200pg colors from our distributors you should look at. <br><br> "
$send = $false
while ($SqlReturn.Read())
{
    $body+=($SqlReturn['Id'].ToString()+"<br>")
    $send=$true
}
if (-not $send){exit}
$body+="<br><br> -BenBot"
$SqlCMd.Dispose()
$SqlConnection.Close()
$message = New-Object Net.Mail.MailMessage $emailFrom,$emailTo
$message.Subject = $subject
$message.Body = $body
$message.IsBodyHTML = $true
$smtpServer = "olympian.ares.priv"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
"sending email"
$smtp.Send($message)