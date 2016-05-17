# some .liquid for the email body{%for row in query%} {{row.Affiliate}} {{row.Vendor}} {{row.PO}}<br/> {%endfor%} {{input}}
  


$sql = @" 
select a.Abbreviation as Affiliate, v.name as Vendor, vo.Id, vo.vendorponum as PO, vo.EstimatedReceiveDate as [Est Date], vo.Memo 
from vendororder vo 
inner join vendor v on v.id = vo.VendorId 
inner join Affiliate a on a.id = vo.AffiliateId 
where vo.EstimatedReceiveDate <> '' 
and vo.EstimatedReceiveDate = @now 
and vo.AllReceivedDate is null 
and vo.IsFinalized = 1 
and vo.IsForReturnRequest = 0 
order by a.Abbreviation "@ 

try{ 
	$rows = $service.GetAdHocQueryKeys($data.Key, $sql, $template.IdKey, $data.now.date, $data.LastRun) 
	$rows.Rows.Count 
	$row = $rows.Rows[0] 
	$args = $data.ToArgs($rows.Rows[0], @{'query'=$rows}) 
	$email = $template.ToEmail($data, $info, $args) 
	}
catch [Exception] { $_.Exception }