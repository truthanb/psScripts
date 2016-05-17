$data = Get-Field $screen m_info
$outCSV=@()
$date = (Get-Date).ToString("MM/dd/yyyy")
foreach ($p in $data.ProductTable) {
    if ($p.IsEnabled -eq $False) {continue}
    [string]$vendorSKU=$p.VendorProductNumber.Trim()
    foreach ($pc in $p.Colors) {
        if ($pc.IsEnabled -eq $False) {continue}
        if ($pc.VendorId -eq 30) {
            [string]$colorName = $pc.Color.DisplayName
            foreach ($pcs in $pc.Sizes) {
                if ($pcs.VendorLastUpdateDate -ne $date) {
                    [string]$row=$vendorSKU+"_"+$colorName
                    if ($outCSV -contains $row) {continue}
                    else {
                        $outCSV+=$row+","+$pcs.VendorLastUpdateDate
                        }#end else
                }#endif
            }#end foreach pcs
        }#end if vendor
    }#end foreach $pc
}#end foreach $p
$outCSV | Select-Object @{Name='Name';Expression={$_}} | export-csv "C:\Users\btruthan\Desktop\sanmarrrrrgh.csv" -NoTypeInformation