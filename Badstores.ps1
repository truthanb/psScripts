# http://aresproject/issue/1-3770
# "Sales report" email to let admin know how showroom is doing with instructions on how to market it
# "{{input.ShowroomProgram.0.Admin.DisplayName}}" <{{input.ShowroomProgram.0.Admin.PreferredEmail}}>

$sql = @"
declare @when date = dateadd(day, -1, @now)
select ord.Id, st.Name [Status], isnull(store.approveddate, ord.createddate), store.deadline, store.sendnoticesto
from OrderView ord
inner join ShowroomProgramView store on store.OrderId=ord.Id
inner join ShowroomProgramStatusType st on st.Id=store.[Status]
where ord.OrderType=2 and ord.IsCanceled=0 and store.Deadline > @when and store.[Status] in (8,23) --  approved, hidden
and ord.TotalOrderCost=0
"@
#FOR 0'ING STORES. 


$rows = $service.GetAdHocQueryKeys($data.Key, $sql, $template.IdKey, $data.now, $data.LastRun)

$index = 0
$0 = $data.now.Date.AddDays(-1)
$1 = $0.AddDays(1)

foreach ($row in $rows) {
try {
	$info = $data.LoadOrder( $row[0] )
	

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
                "Thanks for setting up the {{input.ShowroomProgram.0.Title}} team store! In order to aid in the success of your store we encourage you to take a few minutes each day to promote it and keep track of it’s progress. 
                Its easy! The online admin page enables you to send promotional emails, spread the word on social media, and check the sales reports. Lastly, you can go the old-fashioned route and print a flyer to distribute. 
                To access the flyer, all you have to do is log in to your www.aresteamstore.com account and  click the ‘print flier’ button on the admin page. If you have any questions, don’t hesitate to reach out to us, we’re here to help!"
            }
        {$_ -eq [math]::floor($totaldaysopen/2)}
            {
                if ($row[4] -eq '')
                {
                    "The {{input.ShowroomProgram.0.Title}} team store is halfway to its deadline, and no one has made any purchases as far as our automated system can tell! If you're reading this message, please let us know how we can help with your team store. 
                    We could consider pushing the store close deadline back or try to help you out with promoting the store. Alternatively, we notice that no attempts have been made through our admin tools to send a promotional email. If you take a moment to promote your
                    through the admin tool it could help aid in a successful store."
                }
                else 
                {
                    "The {{input.ShowroomProgram.0.Title}} team store is halfway to its deadline. We recognize your previous attempts to promote your store, and hope to help get some purchases on board. Please contact us at 800-439-8614 if there is anything we can do
                    to help fix and promote your store. "
                }
            }     
        {$_ -eq [math]::floor($totaldaysopen*.8)}
            {            
                if ($row[4] -eq '')
                {
                    "We are in the home stretch now for the {{input.ShowroomProgram.0.Title}} team store. According to our information there has not been a purchase in this store and we do not see any attempts to promote the store using our email tool in the admin screen.
                    Is there anything we can do to salvage this store? Perhaps we could extend the due date or perhaps there is a techical detail blocking purchases. Please advise on how we can help you with your store!"
                }
                else 
                {
                    "We are in the home stretch now for the {{input.ShowroomProgram.0.Title}} team store. We've tried to promote it but it seems like customers aren't acting on our message. Please let us know what we can do to help with this store and or any planned stores in the future."
                }
	    }
                Default {""}
        }
	$args = $data.ToArgs($row, @{ "message"=$message })
	
	$email = $template.ToEmail($data, $info.OrderTable[0], $args)
	# $email.AddAttachment($data.ReportStream("/Reports/TeamShowroomPurchasesByProduct", "PDF", @{"ShowroomProgramId"=$row[0]}), "salesreport.pdf")
} catch [Exception] {
	$row[0]
	$_.Exception
}
$index++
if ($index -gt 25)
{exit}
}