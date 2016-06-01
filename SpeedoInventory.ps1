Set-ExecutionPolicy Unrestricted
Start-Transcript -Path C:\Users\btruthan\Desktop\TASKS\Ares\Speedo_Inventory\SpeedoLastRun.txt -Force
#dll needed to read ieObject document
#add-type -Path "C:\Users\btruthan\Desktop\TASKS\Ares\Speedo_Inventory\Microsoft.mshtml.dll" #Req'd when running on Server 2012 OS, but not for Win10.
[System.Reflection.Assembly]::LoadWithPartialName(“System.Diagnostics”)
$sw = new-object system.diagnostics.stopwatch
$sw.Start()
$pData = Import-Csv '\\ares.priv\filesystem\Global\Archive\Ares\Inventory\HerculesEdi\Speedo\SpeedoSKUS.csv'
#if the product csv was updated, make sure the column is still headed by the word "SKU", or this script will not work.
$invCSV = @()
$loginUrl = "https://speedousab2b.com/ "
$userName = Read-Host -Prompt "Enter Username:"
$pass = Read-Host -Prompt - "Enter Password:" -AsSecureString

$ie = New-Object -com InternetExplorer.Application
$ie.visible = $true #toggle browser. $false runs in background. $true shows what's goin on.


$ie.Navigate($loginUrl)
while($ie.ReadyState -ne 4){start-sleep -m 100}
start-sleep -Seconds 5
$userNameInput = $ie.document.GetElementById("sign-in-email")
$passInput = $ie.document.GetElementById("sign-in-password")
$loginButton = $ie.document.GetElementsByTagName("button") | where {$_.className -eq "button red"}


$userNameInput.value = $userName
$passInput.value = $pass
$loginButton.click()
start-sleep -Seconds 5

while(($ie.document.GetElementsByTagName("input") | where {$_.Name -eq "query"}) -eq $null) #wait for page to load 500 ms at a time.
    {Start-Sleep -Milliseconds 500}

foreach ($p in $pData) {
    #
    #$searchDiv = $ie.document.GetElementById('search-field-1686')
    #$searchInput = $searchDiv.GetElementsByTagName("input") | where {$_.Name -eq "query"} #searchfield id looks like it may be dynamic.
    #$searchInput.value = $p.SKU
    #$searchButton = $ie.document.GetElementById('search-field-1686').GetElementsByTagName("button")
    #$searchButton.click()

    $searchURL = "https://www.speedousab2b.com/shop/?storeId=21001&catalogId=14751&langId=-1&pageSize=10&beginIndex=0&sType=SimpleSearch&resultCatEntryType=2&showResultsPage=true&searchSource=Q&pageView=&query=$($p.sku)"
    $ie.Navigate($searchURL)

    while(($ie.document.GetElementsByTagName("li") | ?{$_.className -eq "last"}) -notlike "$p.SKU"){start-sleep -m 1000}
    #start-sleep -Milliseconds 1000

    $pRows = $ie.document.GetElementsByTagName("li") | where {$_.className -eq "product"}
    [int]$i=0
    foreach ($row in $pRows) {
        $colorElement = $row.getElementsByTagName("div") | where {$_.className -eq "color"}
        [string]$elementString = $colorElement.innerText
        $elementString -match '.*\((?<colorcode>\d+)'
        $cSubString = $Matches['colorcode']

        $sizeElements = $row.getElementsByTagName("div") | where {$_.className -eq "item"}

        foreach ($size in $sizeElements){
                   
           $sizeElement = $size.GetElementsByTagName("div") | ?{$_.className -eq "size cell"}
           $speedoSizeName = $sizeElement.innerText.Trim()
           switch($speedoSizeName){
               "ONE SIZE" {$sizeName = ""}
               "X-SMALL" {$sizeName = "XS"}
               "SMALL" {$sizeName = "S"}
               "MEDIUM" {$sizeName = "M"}
               "LARGE" {$sizeName = "L"}
               "X-LARGE" {$sizeName = "XL"}
               "2X-LARGE" {$sizeName = "XXL"}
               default {$sizeName = ""}
           } #end switch   
           $qtyElement = $size.GetElementsByTagName("div") | ?{$_.className -eq "stock cell"}
           $qty = $qtyElement.innerText
               
           if ($qty -match "\+"){
               $qty = $qty -replace "\+", ""
           }
           if ($qty -like "*/*" -or $qty -eq "sold out"){
               $qty = "0"
           }
           if ($sizeName -eq ""){
               $GTIN = $p.SKU+$cSubString
           }
           else{
               $GTIN = $p.SKU+$cSubString+$sizeName
           } write-host $GTIN "  " $qty
           
           
           $invCSV += [pscustomobject]@{col1=$GTIN;col2=$qty}
        }#end foreach size
        
        $i++
    }#end foreach $pRows
}

$invCSV | Export-Csv <# Enter a Valid FilePath ex: "C:\Users\Blah|Desktop\inv.csv" #> -Force -NoTypeInformation
$ie.Navigate("https://www.speedousab2b.com/user/logoff.html?langId=-1&storeId=21001&catalogId=14751&URL=StoreView")
$ie.Quit()
#Get-Process iexplore | Foreach-Object { $_.CloseMainWindow() }

$sw.Stop()
echo $sw.Elapsed.TotalMinutes " minutes"
Stop-Transcript