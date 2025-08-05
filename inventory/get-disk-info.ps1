<#
    .SYNOPSIS
        Lists physical disks with associated volumes in a unified table.

    .NOTES
        Requires admin privileges for full metadata access.
#>

$diskData = @()

$physicalDisks = Get-PhysicalDisk
$volumes = Get-Volume
$partitions = Get-Partition
$diskDrives = Get-Disk

foreach ($disk in $diskDrives) {
    $diskNumber = $disk.Number
    $pd = $physicalDisks | Where-Object { $_.DeviceId -eq $diskNumber }

    $matchingPartitions = $partitions | Where-Object { $_.DiskNumber -eq $diskNumber }

    foreach ($part in $matchingPartitions) {
        $vol = $volumes | Where-Object { $_.DriveLetter -eq $part.DriveLetter }

        if ($vol) {
            $diskData += [PSCustomObject]@{
                "Disk #"           = $diskNumber
                "Drive Letter"     = $vol.DriveLetter
                "Volume Label"     = $vol.FileSystemLabel
                "File System"      = $vol.FileSystem
                "Size (GB)"        = [math]::Round($vol.Size / 1GB, 2)
                "Free (GB)"        = [math]::Round($vol.SizeRemaining / 1GB, 2)
                "Disk Model"       = $pd.FriendlyName
                "Media Type"       = $pd.MediaType
                "Bus Type"         = $pd.BusType
                "Serial Number"    = $pd.SerialNumber
                "Health Status"    = $pd.HealthStatus
                "Firmware Version" = $pd.FirmwareVersion
            }
        }
    }
}

$diskData | Sort-Object "Disk #" | Format-Table -AutoSize
