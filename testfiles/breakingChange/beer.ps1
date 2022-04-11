[CmdletBinding()]
param (

)

$beers = Get-Beer -Size Maß

foreach ($beer in $beers) {
	if ($beer.Brand -ne 'Kölsch') {
		Drink-Beer $beer
	}
}

Get-Beer -Brand Kölsch | Remove-Beer