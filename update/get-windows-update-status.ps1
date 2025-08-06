<#
    .SYNOPSIS
        Displays Windows Update configuration and most recently installed updates.

    .NOTES
        Shows automatic update settings and last installed patches in a single report.
#>

# Get configuration
$wuSettings = (New-Object -ComObject Microsoft.Update.AutoUpdate).Settings
$notificationLevel = switch ($wuSettings.NotificationLevel) {
    1 { "Not Configured / Disabled" }
    2 { "Notify Before Download" }
    3 { "Auto Download & Notify" }
    4 { "Scheduled Install" }
    default { "Unknown" }
}

# Get last 10 installed updates
$updates = Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 10 |
    Select-Object @{Name="KB"; Expression={$_.HotFixID}},
                  @{Name="Description"; Expression={$_.Description}},
                  @{Name="Installed On"; Expression={$_.InstalledOn.ToString("yyyy-MM-dd")}},
                  @{Name="Installed By"; Expression={$_.InstalledBy}}

# Output report
Write-Host "`n========= Windows Update Status Report =========" -ForegroundColor Cyan

[PSCustomObject]@{
    "Auto Update Enabled" = $wuSettings.NotificationLevel -ne 1
    "Update Mode"         = $notificationLevel
    "Last Patch Date"     = ($updates | Select-Object -First 1)."Installed On"
}

Write-Host "`n--- Last Installed Updates ---`n" -ForegroundColor DarkCyan
$updates | Format-Table -AutoSize
