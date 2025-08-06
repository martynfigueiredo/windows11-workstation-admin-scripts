<#
    .SYNOPSIS
        Lists all Windows optional features and their installation status.

    .NOTES
        Combines DISM feature list with Get-WindowsOptionalFeature if needed.
        Run as Administrator for full accuracy.
#>

# Get Windows features via DISM
$features = DISM /Online /Get-Features /Format:Table | Out-String

# Clean and parse into readable table
$lines = $features -split "`n" | Where-Object { $_ -match "\s+\|\s+" }

$parsed = foreach ($line in $lines) {
    $parts = $line -split "\|"
    if ($parts.Count -ge 2) {
        [PSCustomObject]@{
            "Feature Name" = $parts[0].Trim()
            "State"        = $parts[1].Trim()
        }
    }
}

Write-Host "`n========= Windows Optional Features =========" -Foreground
