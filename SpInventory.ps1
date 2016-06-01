#Some info was adjusted as to not give away sensitive information.
[System.Reflection.Assembly]::LoadWithPartialName(“System.Diagnostics”)
$sw = new-object system.diagnostics.stopwatch
$sw.Start()
$pData = Import-Csv '\\ares.priv\filesystem\Global\Archive\Ares\Inventory\HerculesEdi\Speedo\SpeedoSKUS.csv'
#if the product csv was updated, make sure the column is still headed by the word "SKU", or this script will not work.
$invCSV = @()
$loginUrl = "https://speedousab2b.com/ "
$userName = Read-Host 'What is your username?'
$pass = Read-Host 'What is your password?' -AsSecureString
$ie = New-Object -com InternetExplorer.Application
$ie.visible = $false #toggle browser. $false runs in background. $true shows what's goin on.


$ie.Navigate($loginUrl)
while($ie.ReadyState -ne 4){start-sleep -m 100}
$userNameInput = $ie.document.GetElementById("TxtUserName")
$passInput = $ie.document.GetElementById("TxtPassword")
$loginButton = $ie.document.GetElementById("BtnLogin")


$userNameInput.value = $userName
$passInput.value = $pass
$loginButton.click()
start-sleep -Seconds 5
$navFrame = $ie.document.frames.item(0)

while($navFrame.document.GetElementById("ctl00_PRSearch_tb_keyword") -eq $null) #wait for page to load 500 ms at a time.
    {Start-Sleep -Milliseconds 500}

foreach ($p in $pData) {

    $topFrame = $ie.document.GetElementsByTagName("frame") | where {$_.name -eq "topFrame"}
    $topFrame.contentWindow.document.GetElementById("ctl00_PRSearch_tb_keyword").value = $p.SKU
    $topFrame.contentWindow.document.GetElementById("ctl00_PRSearch_ImageButtonSearch").click()

    $mainFrame = $ie.document.GetElementsByTagName("frame") | where {$_.name -eq "FrmMain"}
    while($mainFrame.contentWindow.document.GetElementById("ctl00_ContentPlaceHolder3_LabelResultText").innerHTML -notmatch $p.SKU){Start-Sleep -Milliseconds 500}
    #start-sleep -Milliseconds 1000

    $pRows = $mainFrame.contentWindow.document.GetElementsByTagName("tr") | where {$_.className -eq "trodd" -or $_.className -eq "treven"}
    [int]$i=0
    foreach ($row in $pRows) {
        $colorElement = $row.getElementsByTagName("span") | where {$_.className -eq "PrdGridAttrValue2"}
        [string]$elementString = $colorElement.innerHTML
        $cSubString = $elementString.Substring(0, 3) #color codes are first 3 digits, but $elementString has color code followed by name in parenthesis.
        
        $sizeElements = $row.getElementsByTagName("span") | where {$_.className -eq "PrdGridPrdATPInfo"}
        if ($sizeElements.Count -lt 3){ #single size products have 2 size elements
            $GTIN = $p.SKU+$cSubString

            $qtyElement = $mainFrame.contentWindow.document.GetElementById("ctl00_ContentPlaceHolder3_RepeaterMainGridWithoutTable_ctl00_RepeaterGrid_ctl00_LinkButtonATPLink")
            $qty = $qtyElement.textContent
      
            if ($qty -match "\+"){
                $qty = $qty -replace "\+", ""
            }write-host $GTIN "  " $qty
        }
        else{
            [int]$j=0
            foreach ($size in $sizeElements){
                if ($size.innerHTML.length -eq 0){continue} #Simple skip. Each size has 2 $sizeElements where every "second" one in the index is worthless.
                
                
                $sizeName = $size.innerHTML
                $qtyElement = $mainFrame.contentWindow.document.GetElementById("ctl00_ContentPlaceHolder3_RepeaterMainGridWithoutTable_ctl"+$i.ToString("00")+"_RepeaterGrid_ctl"+$j.ToString("00")+"_LinkButtonATPLink")
                $qty = $qtyElement.textContent
      
                if ($qty -match "\+"){
                    $qty = $qty -replace "\+", ""
                }
                if ($sizeName -eq ""){
                    $GTIN = $p.SKU+$cSubString
                }
                else{
                    $GTIN = $p.SKU+$cSubString+$sizeName
                } write-host $GTIN "  " $qty
                
                
                $invCSV += [pscustomobject]@{col1=$GTIN;col2=$qty}
                $j++
            }#end foreach size
        }#end else
        $i++
    }#end foreach $pRows
}

$invCSV | Export-Csv <#Enter Valid Filepath #> -Force -NoTypeInformation
$logout = $navFrame.document.GetElementsByTagName("a") | where {$_.className -eq "ctl00_PRCommonMenuLogon_MenuPRCommonMenu_1 PRCommonMenu_Menu ctl00_PRCommonMenuLogon_MenuPRCommonMenu_3"}
$logout.click()
$ie.Quit()
#Get-Process iexplore | Foreach-Object { $_.CloseMainWindow() }

$sw.Stop()
echo $sw.Elapsed.TotalMinutes " minutes"
