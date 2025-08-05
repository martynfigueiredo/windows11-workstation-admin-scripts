<#
    .SYNOPSIS
        Lists all installed applications on the system with detailed information.

    .NOTES
        Combines data from both 32-bit and 64-bit registry views.
        Run as administrator for full visibility.
#>

function Get-InstalledAppsFromRegistry {
    param([string]$RegPath)

    Get-ItemProperty $RegPath |
    Where-Object { $_.DisplayName -and $_.DisplayName -ne "" } |
    Select-Object @{
        Name = 'Name'; Expression = { $_.DisplayName }
    }, @{
        Name = 'Publisher'; Expression = { $_.Publisher }
    }, @{
        Name = 'Install Date'; Expression = {
            if ($_.InstallDate) {
                try {
                    [datetime]::ParseExact($_.InstallDate, 'yyyyMMdd', $null)
                } catch { $null }
            } else { $null }
        }
    }, @{
        Name = 'Version'; Expression = { $_.DisplayVersion }
    }, @{
        Name = 'Estimated Size (MB)'; Expression = {
            if ($_.EstimatedSize) {
                [math]::Round($_.EstimatedSize / 1024, 2)
            } else { $null }
        }
    }
}

$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$allApps = foreach ($path in $paths) {
    Get-InstalledAppsFromRegistry -RegPath $path
}

Write-Host "`n========= Installed Applications =========" -ForegroundColor Cyan
$allApps | Sort-Object Name | Format-Table -AutoSize
