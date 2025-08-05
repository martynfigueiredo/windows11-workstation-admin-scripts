<#
    .SYNOPSIS
        Retrieves detailed CPU and physical memory information in a single unified output.

    .NOTES
        Run as administrator for full hardware visibility.
#>

# CPU Info
$cpu = Get-CimInstance Win32_Processor

$cpuSummary = [PSCustomObject]@{
    "CPU Name"               = $cpu.Name
    "Socket Designation"     = $cpu.SocketDesignation
    "Cores"                  = $cpu.NumberOfCores
    "Logical Processors"     = $cpu.NumberOfLogicalProcessors
    "Max Clock Speed (GHz)"  = [math]::Round($cpu.MaxClockSpeed / 1000, 2)
    "Architecture (bits)"    = $cpu.AddressWidth
    "Virtualization Enabled" = $cpu.VirtualizationFirmwareEnabled
    "L2 Cache (KB)"          = $cpu.L2CacheSize
    "L3 Cache (KB)"          = $cpu.L3CacheSize
}

# Memory Info
$memModules = Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
    [PSCustomObject]@{
        "Bank Label"     = $_.BankLabel
        "Capacity (GB)"  = [math]::Round($_.Capacity / 1GB, 2)
        "Speed (MHz)"    = $_.Speed
        "Manufacturer"   = $_.Manufacturer
        "Part Number"    = $_.PartNumber
        "Memory Type"    = $_.MemoryType
    }
}

$totalMemory = ($memModules | Measure-Object "Capacity (GB)" -Sum).Sum

# Unified Report Output
Write-Host "`n========= CPU Information =========" -ForegroundColor Cyan
$cpuSummary | Format-Table -AutoSize

Write-Host "`n========= Memory Modules =========" -ForegroundColor Cyan
$memModules | Format-Table -AutoSize

Write-Host "`nTotal Installed Memory: $totalMemory GB" -ForegroundColor Yellow
