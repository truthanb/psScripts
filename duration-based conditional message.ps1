[datetime]$opendate="2/24/14"
[datetime]$closedate="3/24/14"
[datetime]$now=[datetime]::Now
#$closedate - $opendate
$duration= New-TimeSpan $opendate $closedate
$timeleft= New-Timespan $now $closedate
$durdays=$duration.Days
    if($durdays -eq 0)
        {
            $durdays=1
        }
$daysleft=$timeleft.Days 
[float]$rel=$daysleft/$durdays
"rel "+ $rel
[float]$dayval=1/$durdays
"dayval "+ $dayval
$a = switch ($rel)
{
    {$_ -le .3 -and ($_ -ge (.3-$dayval))} 
        {
            "Hurry Hurry"
        }
    {$_ -le .5 -and ($_ -ge (.5-$dayval))}
        {
            "The store is about halfway over"
        }
    {$_ -le 1 -and ($_ -ge (1-($dayval*2)))}
        {
            "The admin page is your friend"
        }
    Default  {""}
}
Write-Host $durdays
Write-Host $daysleft
Write-Host $rel
Write-Host $a