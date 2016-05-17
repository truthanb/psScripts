$data = Get-Field $screen m_info
foreach ($p in $data.ProductTable) {
	if ($p.IsEnabled -eq $False){continue}
	if ($p.isWebVisible -eq $False){continue}
	
	foreach($pc in $p.Colors) {
		if ($pc.IsEnabled -eq $False) {continue}
		if ($pc.VendorId -eq 467) {
			if ($pc.ColorId -eq 40) {continue}
			$productColorSize = $pc.Sizes
			foreach ($pcs in $productColorSize) {
				
				$sizeName = $pcs.Size.Name
				if ($sizeName -eq "XL"){$sizeName = "X"}
				if ($sizeName -eq "XXL"){$sizeName = "XX"}
				if ($sizeName -eq "3XL"){$sizeName = "XXXL"}
				if ($sizeName -eq "YXS"){$sizeName = "XS"}
				if ($sizeName -eq "YS"){$sizeName = "S"}
				if ($sizeName -eq "YM"){$sizeName = "M"}
				if ($sizeName -eq "YL"){$sizeName = "L"}
				if ($sizeName -eq "YXL"){$sizeName = "X"}
				
				$styleName = $pcs.vendorProductNumber.Trim()
                		if ($pcs.VendorProductNumber.length -lt 3) {continue}
				
                                
				$GTIN = $sizeName + $styleName
				$pcs.VendorSKU = $GTIN
			} #end $pcs
		} #end if Vendor 467
	} #end for
} #end $p