<#
    .SYNOPSIS
        Checks Windows native backup status including wbadmin and File History.

    .NOTES
        Run as Administrator for accurate output from wbadmin.
#>

Write-Host "`n========= Windows Backup (wbadmin) =========" -ForegroundColor Cyan

# Check wbadmin status
try {
    $wbadminOutput = wbadmin get status 2>&1
    if ($wbadminOutput -match "No backup") {
        Write-Host "Windows Backup: No backup has been configured." -ForegroundColor Yellow
    } else {
        $wbadminOutput
    }
} catch {
    Write-Host "Error accessing wbadmin. Ensure the system supports Windows Server Backup or run as administrator." -ForegroundColor Red
}

Write-Host "`n========= File History =========" -ForegroundColor Cyan

# Check File History
try {
    $fhStatus = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\FileHistory\Configuration" -ErrorAction Stop

    [PSCustomObject]@{
        "File History Enabled" = $true
        "Target Drive"         = $fhStatus.TargetUrl
        "Backup User"          = $fhStatus.Owner
        "Backup Frequency"     = $fhStatus.BackupPeriod
    } | Format-Table -AutoSize
} catch {
    Write-Host "File History is not enabled or has never been configured." -ForegroundColor Yellow
}
