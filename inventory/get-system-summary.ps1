<#
    .SYNOPSIS
        Retrieves a complete summary of the Windows 11 workstation: OS, hardware, uptime, model, serial, etc.

    .NOTES
        Best run with administrative privileges for full data access.
#>

$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS

$uptime = (Get-Date) - $os.LastBootUpTime

$summary = [PSCustomObject]@{
    "Computer Name"        = $cs.Name
    "Manufacturer"         = $cs.Manufacturer
    "Model"                = $cs.Model
    "Serial Number"        = $bios.SerialNumber
    "OS Name"              = $os.Caption
    "OS Version"           = $os.Version
    "Build Number"         = $os.BuildNumber
    "Install Date"         = $os.InstallDate.ToString("yyyy-MM-dd HH:mm")
    "Last Boot Time"       = $os.LastBootUpTi
