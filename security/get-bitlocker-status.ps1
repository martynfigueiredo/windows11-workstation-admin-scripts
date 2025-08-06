<#
    .SYNOPSIS
        Displays BitLocker encryption status for all volumes.

    .NOTES
        Requires administrator privileges. Works on Windows 10/11 Pro, Enterprise, and Education.
#>

# Ensure BitLocker module is available
if (-not (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue)) {
    Write-Host "BitLocker module not found. This script requires Windows 10/11 Pro or higher." -ForegroundColor Yellow
    return
}

$volumes = Get-BitLockerVolume

$results = foreach ($v in $volumes) {
    $keyProtectors = ($v.KeyProtector | ForEach-Object { $_.KeyProtectorType }) -join ", "

    [PSCustomObject]@{
        "Volume"             = $v.MountPoint
        "Protection Status"  = $v.ProtectionStatus
        "Encryption Method"  = $v.EncryptionMethod
        "Encryption %"       = $v.EncryptionPercentage
        "Auto Unlock"        = $v.AutoUnlockEnabled
        "Key Protectors"     = $keyProtectors
    }
}

Write-Host "`n========= BitLocker Status =========" -ForegroundColor Cyan
$results | Format-Table -AutoSize
