<#
    .SYNOPSIS
        Enables TCP KeepAlive and disables sleep and hibernate for continuous remote access.

    .DESCRIPTION
        - Sets TCP KeepAliveTime to maintain persistent network connections
        - Disables standby, hibernate, and screen timeouts
        Useful for remote workstations or systems requiring 24/7 availability.

    .NOTES
        Run as Administrator.
        KeepAlive requires reboot or TCP stack restart to take effect.
#>

Write-Host "`n========= Applying System Availability Settings =========" -ForegroundColor Cyan

try {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    $name = "KeepAliveTime"
    $value = 999999

    if (Test-Path $path) {
        if (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue) {
            Set-ItemProperty -Path $path -Name $name -Value $value
        } else {
            New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWord
        }
    }

    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0 2>$null
    powercfg /change hibernate-timeout-dc 0 2>$null
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "CrashDumpEnabled" -Value 0

    Write-Host "`n✅ System keep-alive and power settings applied." -ForegroundColor Green
}
catch {
    Write-Host "❌ Failed to apply one or more settings. Please run as Administrator." -ForegroundColor Red
}
