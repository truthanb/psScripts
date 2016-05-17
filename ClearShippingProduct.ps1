$data = Get-Field $screen m_info
foreach ($job in $data.JobTable)
{
$job.Alias
if ($job.Alias -eq "Shipping")
{
$job.IsInProduction = $false
$job.IsInventoryPulled = $true
$job.IsReadyToShip = $true
$job.IsShipped = $true
}}