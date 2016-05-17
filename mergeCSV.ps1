$opens = import-csv "C:\Users\btruthan\Desktop\Birdbrain\4.csv"
$index=@{}
$reppedAccounts = import-csv "C:\Users\btruthan\Desktop\Birdbrain\Book1.csv"
foreach ($row in $reppedAccounts) {
    $index[$row.id.trim()]=$row
    }
foreach ($row in $opens) {
    $test=$index[$row.CustomerId.trim()].rep
    $row.rep=$test
    }

$opens | export-csv "c:\users\btruthan\desktop\outfile.csv" -NoTypeInformation -Force