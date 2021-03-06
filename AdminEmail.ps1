# http://aresproject/issue/1-3770
# "Sales report" email to let admin know how showroom is doing with instructions on how to market it
# "{{input.ShowroomProgram.0.Admin.DisplayName}}" <{{input.ShowroomProgram.0.Admin.PreferredEmail}}>

$sql = @"
declare @when date = dateadd(day, -1, @now)
select ord.Id, st.Name [Status], isnull(store.approveddate, ord.createddate), store.deadline, store.sendnoticesto
from OrderView ord
inner join ShowroomProgramView store on store.OrderId=ord.Id
inner join ShowroomProgramStatusType st on st.Id=store.[Status]
where ord.OrderType=2 and ord.IsCanceled=0 and store.Deadline > @when and store.[Status] in (4,8,23) -- in progress, approved, hidden
and ord.TotalOrderCost>0
"@
#FOR NON 0'ING STORES. THE EMAIL FOR 0'ING STORES WILL BE HANDLED SIMILARLY YET DIFFERENTLY. MAINLY BY REMOVING THE TOTALORDERCOST CONDITION OF $SQL.

$purchased = @"
select tpp.Id
from OrderView ord
inner join JobView job on job.OrderId=ord.Id
inner join JobProductView jp on jp.JobId=job.Id
inner join JobProductColorSizeView jpsz on jpsz.JobProductId=jp.Id
inner join TeamPlayerPurchaseView tpp on tpp.PurchaseId=jpsz.Id
inner join TeamPlayerView tp on tp.Id=tpp.PlayerId
inner join TeamView team on team.Id=tp.TeamId
where tpp.CreatedDate between @0 and @1 and ord.Id=@2
order by team.Name, tp.Name
"@

$rows = $service.GetAdHocQueryKeys($data.Key, $sql, $template.IdKey, $data.now, $data.LastRun)

$index = 0
$0 = $data.now.Date.AddDays(-1)
$1 = $0.AddDays(1)

foreach ($row in $rows) {
try {
	$info = $data.LoadOrder( $row[0] )
	$ptoday = @()
	$session.Load($purchased, $0, $1, $row[0]) | foreach-object { $ptoday += $info.TeamPlayerPurchaseTable.FindById($_[0]) }

        [datetime]$opendate=$row[2].AddDays(-1) 
        [datetime]$closedate=$row[3].AddDays(1)
        [datetime]$now=[datetime]::Now
        #$closedate - $opendate
        $timespancalc = New-Timespan $opendate.adddays(-1) $closedate
        $timesinceopen = New-Timespan $opendate $now
        $totaldaysopen = $timespancalc.Days
        $dayssinceopen = $timesinceopen.Days
        [float]$dayworth = 1/$totaldaysopen
        [float]$currentdayval = $dayssinceopen*$dayworth
        $message = switch ($dayssinceopen)
        {
        {$_ -eq 1}
            {
                if ($row[4] -eq '')
                {
                    "PROMOTE YOUR STORE VIA ADMIN PAGE"
                }
                else 
                {
                    "KEEP TRACK OF YOUR STORE VIA THE ADMIN PAGE"
                }
            }
        {$_ -eq [math]::floor($totaldaysopen/2)}
            {
                if ($row[4] -eq '')
                {
                    "PROMOTE YOUR STORE"
                }
                else 
                {
                    "Keep Promoting!"
                }
            }     
        {$_ -eq [math]::floor($totaldaysopen*.8)}
            {            
                if ($row[4] -eq '')
                {
                    "TIME IS ALMOST OUT. Let Us HELP"
                }
                else 
                {
                    "TIME IS ALMOST OUT, Consider broadcasting on social media."
                }
	    }
                Default {""}
        }
	$args = $data.ToArgs($row, @{ "ptoday"=$ptoday; "message"=$message; "HasPurchases"=($ptoday.Length -gt 0) })
	
	$email = $template.ToEmail($data, $info.OrderTable[0], $args)
	# $email.AddAttachment($data.ReportStream("/Reports/TeamShowroomPurchasesByProduct", "PDF", @{"ShowroomProgramId"=$row[0]}), "salesreport.pdf")
} catch [Exception] {
	$row[0]
	$_.Exception
}
$index++
if ($index -gt 5)
{exit}
}
