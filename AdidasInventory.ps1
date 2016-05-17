[System.Reflection.Assembly]::LoadWithPartialName(“System.Diagnostics”)
$sw = new-object system.diagnostics.stopwatch
$sw.Start()
$pData = Import-Csv '\\ares.priv\filesystem\Global\Archive\Ares\Inventory\HerculesEdi\Adidas\AdidasProducts.csv'
#if the product csv was updated, make sure the column is still headed by the word "Product", or this script will not work.
$invCSV = @()
$loginUrl = "https://usa.adidas.com/CWE"
$userName = Read-Host 'What is your username?'
$pass = Read-Host 'What is your password?' -AsSecureString
$searchUrl = "https://usa.adidas.com/cwe/OnlineOrder/MaterialSearch.aspx"

$ie = New-Object -com InternetExplorer.Application
$ie.visible = $true #toggle browser. $false runs in background. $true shows what's goin on.


$ie.Navigate($loginUrl)
while($ie.ReadyState -ne 4){start-sleep -m 100}
$userNameInput = $ie.document.GetElementById("tbLoginUserId")
$passInput = $ie.document.GetElementById("tbLoginPswd")
$loginButton = $ie.document.GetElementById("uniform-btnLogin")


$userNameInput.value = $userName
$passInput.value = $pass
$loginButton.click()
while($ie.document.GetElementById("ctl00_MasterContent_Body_lblWelcome") -eq $null) #wait for page to load 500 ms at a time.
    {Start-Sleep -Milliseconds 500}

$ie.Navigate($searchUrl) #go to the product search
    
while($ie.document.GetElementById("ctl00_MasterContent_Body_tabSearchCriteria_tpArticle_txtArticleNumberSearch") -eq $null) #wait for page to load 500 ms at a time.
        {Start-Sleep -Milliseconds 500}
foreach($product in $pData){


    $gatp = "GATP"
    $ie.document.GetElementById("ctl00_MasterContent_Body_tabSearchCriteria_tpArticle_txtArticleNumberSearch").value = ""
    $ie.document.GetElementById("ctl00_MasterContent_Body_tabSearchCriteria_tpArticle_txtArticleNumberSearch").value = $product.Product
    $ie.document.GetElementById("ctl00_MasterContent_Body_btnSearch").click()
    Start-Sleep -Milliseconds 5000
    while(($ie.Document.getElementsByTagName("tr") | where {$_.ClassName -eq "inventory"}).count -eq 0)
    {Start-Sleep -Milliseconds 1500}
    Start-Sleep -Seconds 2 #let shtuff render
    
   
    
    $quantities = $ie.Document.getElementsByTagName("td") | where {$_.ClassName -like "$gatp*"}   

    
    if ($quantities.length -ne $null){
        foreach ($q in $quantities){
            $quantityParent = $q.parentElement #the quantity row
            $parentPrevious = $quantityParent.previousSibling #the row above quantity row
            $children = $parentPrevious.children
            $qCellIndex = $q.cellIndex
            $sizeCell = $children | Where-Object{$_.cellIndex -eq $qCellIndex}
            $size = $sizeCell.innerText
            $GTIN = "$size"+$product.Product
            $invCSV += [pscustomobject]@{col1=$GTIN;col2=$q.innerHTML}
            Write-Host "$GTIN, $($q.innerHTML)"            
        }
    }
    $ie.document.GetElementById("btnCancel").click()
    
}

$invCSV | Export-Csv "\\ares.priv\filesystem\Global\Archive\Ares\Inventory\HerculesEdi\Adidas\inv.csv" -Force -NoTypeInformation
$ie.document.GetElementById("ctl00_liMenuLogOut").click()
$ie.Quit()
$sw.Stop()
echo $sw.Elapsed.TotalMinutes " minutes"