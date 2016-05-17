$data = Get-Field $screen m_info
foreach ($p in $data.ProductTable) {
	if ($p.IsEnabled -eq $False){continue}
	if ($p.VendorProductNumber -eq $Null) {continue}
	$vendorSKU = $p.VendorProductNumber.Trim()
	foreach($pc in $p.Colors) {
		if ($pc.IsEnabled -eq $False) {continue}
		if ($pc.VendorId -eq 30) {
			if ($pc.ColorId -eq 40) {continue}
			$colorName = $pc.Color.DisplayName
			$productColorSize = $pc.Sizes
			foreach ($pcs in $productColorSize) {
				$sizeName = $pcs.Size.Name
                $sku = $vendorSKU
				if ($pcs.VendorProductNumber.length -gt 3) {$sku = $pcs.VendorProductNumber.Trim()}
				if ($sizeName -eq "OS") {$sizeName = "OSFA"}
                if ($sizeName -eq "XXL") {$sizeName = "2XL"}                
				$GTIN = $sku + '-' + $colorName + '-' + $sizeName
				$pcs.VendorSKU = $GTIN
			} #end $pcs
		} #end if Vendor 30
	} #end $pc
} #end $p