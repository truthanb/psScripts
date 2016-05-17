#BAW
if (test-path "M:\Archive\Ares\Inventory\HerculesEDI\BAW\inv.csv")
{
    [datetime]$now=[datetime]::Now
    [datetime]$createdate = (Get-ChildItem M:\Archive\Ares\Inventory\HerculesEDI\BAW\inv.csv).CreationTime
        If ($now.date -gt $createdate)
        {
            del M:\Archive\Ares\Inventory\HerculesEDI\BAW\inv.csv
        }
        else
        {
            "The inventory file has already been imported today. Delete it if you want to import another"
            exit
        }
}
$shell_app = new-object -com shell.application
if (test-path ("M:\External File Uploads\areswear.com\inv-{0:yyyy-MM-dd}.csv" -f (get-date)))
    {
        move-item ("M:\External File Uploads\areswear.com\inv-{0:yyyy-MM-dd}.csv" -f (get-date)) "M:\Archive\Ares\Inventory\HerculesEDI\BAW\inv.csv"
    }
else
    {
        "There was no new inventory file to import at this time."
    }