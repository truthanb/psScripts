$sql = @"
select O.Id, O.FinalizedDate, O.OrderDueToShipDate, O.CreditHoldReason, O.TotalOrderCost
from OrderView O
where O.OrderType = 4 and
O.IsOnCreditHold = 1 and
O.IsCanceled = 0
"@

$rows = $service.GetAdHocQueryKeys($data.Key, $sql, $template.IdKey, $data.Now, $data.LastRun)

$index = 0

foreach ($row in $rows)
{
	$info = $data.LoadOrder( $row[0] )

	try
	{
		$reasons = @()
		$hold = $row[3]
		if ($hold -band 1) {
			$reasons += "Shipping Address does not match Billing Address";
		}
		if ($hold -band 2) {
			$reasons += "Credit Limit is exceeded";
		}
		if ($hold -band 4) {
			$reasons += "Account is not authorized for credit";
		}
		if ($hold -band 8) {
			$reasons += "An invoice is past due";
		}
		if ($hold -band 16) {
			$reasons += "A web order was placed";
		}
		if ($hold -band 32) {
			$reasons += "Manually put on hold by Credit Manager";
		}
		if ($hold -band 64) {
			$reasons += "Check Payment";
		}
		[datetime]$finalizedDate=$row[1]
		[datetime]$dueDate=$row[2]
		[datetime]$now=[datetime]::Now
        $sinceOpen =  New-Timespan $finalizedDate $now
        $tillDue = New-Timespan $now $dueDate 
        $daysSinceFinalized = $sincOpen.Days
        $daysTillDue = $tillDue.Days
                
        $message = switch ($daysSinceFinalized)
        {
        	{$_ -eq 1}{"1"}
        	
            Default {"fallthrough"}
        }
        if ($message -eq  "fallthrough")
        {
        	$message = switch ($daysTillDue)
        	{
        		{$_ -eq 0}{"due"}
        		{$_ -eq 1}{"1away"}
        		{$_ -eq 2}{"2away"}
        		{$_ -eq 3}{"3away"}
        		Default {"again"}
        	}
        }
        if ($message -eq "again")
        {
        	$pastDue = New-TimeSpan $dueDate $now
        	$pastDueDays = $pastDue.Days
        	$message = switch ($pastDueDays)
        	{
        		{$_ -eq 1}{"1day"}
				{$_ -eq 7}{"1wk"}
        		{$_ -eq 14}{"2wk"}
        		Default {""}
        	}       	
        }
        if ($message -eq "")
        {continue}

		$args = $data.ToArgs($row, @{ "message"=$message; "reasons"=$reasons;})
		$email = $template.ToEmail($data, $info.OrderTable[0], $args)
	} 

	catch [Exception]
	{
		$row[0]
		$_.Exception
	}

	$index++
	#if ($index -gt 10)
	#{exit}
}