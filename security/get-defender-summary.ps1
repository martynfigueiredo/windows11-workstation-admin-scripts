<#
    .SYNOPSIS
        Summarizes Windows Defender status, definitions, and protection settings.

    .NOTES
        Resilient across all configurations. Works even when Defender is inactive.
#>

Write-Host "`n========= Windows Defender Summary =========" -ForegroundColor Cyan

try {
    $status = Get-MpComputerStatus -ErrorAction Stop

    if ($null -eq $status) {
        Write-Host "⚠️  Windows Defender is not active on this system." -ForegroundColor Yellow
        return
    }

    $lastQuick = if ($status.LastQuickScanDate) { $status.LastQuickScanDate.ToString("yyyy-MM-dd HH:mm") } else { "Never" }
    $lastFull  = if ($status.LastFullScanDate)  { $status.LastFullScanDate.ToString("yyyy-MM-dd HH:mm") } else { "Never" }

    $report = [PSCustomObject]@{
        "Last Quick Scan"           = $lastQuick
        "Last Full Scan"            = $lastFull  
        "Antivirus Enabled"         = $status.AntivirusEnabled
        "Antispyware Enabled"       = $status.AntispywareEnabled
        "Real-Time Protection"      = $status.RealTimeProtectionEnabled
        "Behavior Monitoring"       = $status.BehaviorMonitorEnabled
        "IOAV Protection"           = $status.IOAVProtectionEnabled
        "Tamper Protection"         = $status.IsTamperProtected
        "Network Inspection System" = $status.NISEnabled
        "Signature Age (days)"      = $status.AntivirusSignatureAge
        "Signature Version"         = $status.AVSignatureVersion
        "Engine Version"            = $status.AMEngineVersion
        "Product Version"           = $status.AntivirusProductVersion
    }

    $report | Format-Table -AutoSize -Wrap | Out-String | Write-Host
}
catch {
    Write-Host "⚠️  Windows Defender is not installed or accessible. Possibly replaced by another antivirus." -ForegroundColor Yellow
}
