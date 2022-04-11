@{
	BeerFactory = @{
		'2.0.0' = @{
			'Get-Beer' = @{
				Description = "Complete rewrite, requires different syntax and data input"
			}
		}
		'2.1.0' = @{
			'Get-Beer' = @{
				Parameters = @{
					Brand = 'Now expects a string'
					Size = 'No longer supports "Horn" as input'
				}
			}
			'Remove-Beer' = @{
				Description = 'Command was dropped due to heresy dispute.'
			}
		}
	}
}