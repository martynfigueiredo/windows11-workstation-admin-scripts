<#
    .SYNOPSIS
        Lists all startup programs from registry and startup folders.

    .NOTES
        Includes machine-wide and user-specific startup entries.
#>

function Get-StartupRegistryEntries {
    param([string]$Hive, [string]$Path, [string]$Location)

    try {
        Get-ItemProperty "$Hive\$Path" -ErrorAction SilentlyContinue |
        ForEach-Object {
            $_.PSObject.Properties | ForEach-Object {
                if ($_.Name -ne "PSPath" -and $_.Name -ne "PSParentPath" -and $_.Name -ne "PSChildName") {
                    [PSCustomObject]@{
                        Location   = $Location
                        Name       = $_.Name
                        Command    = $_.Value
                        Source     = "$Hive\$Path"
                    }
                }
            }
        }
    } catch {}
}

function Get-StartupFolderItems {
    param([string]$FolderPath, [string]$Location)

    if (Test-Path $FolderPath) {
        Get-ChildItem -Path $FolderPath -Filter *.lnk -Force | ForEach-Object {
            [PSCustomObject]@{
                Location   = $Location
                Name       = $_.BaseName
                Command    = $_.FullName
                Source     = $FolderPath
            }
        }
    }
}

$results = @()

# Registry - Machine
$results += Get-StartupRegistryEntries -Hive "HKLM:" -Path "Software\Microsoft\Windows\CurrentVersion\Run" -Location "Registry (Machine - Run)"
$results += Get-StartupRegistryEntries -Hive "HKLM:" -Path "Software\Microsoft\Windows\CurrentVersion\RunOnce" -Location "Registry (Machine - RunOnce)"

# Registry - User
$results += Get-StartupRegistryEntries -Hive "HKCU:" -Path "Software\Microsoft\Windows\CurrentVersion\Run" -Location "Registry (User - Run)"
$results += Get-StartupRegistryEntries -Hive "HKCU:" -Path "Software\Microsoft\Windows\CurrentVersion\RunOnce" -Location "Registry (User - RunOnce)"

# Startup folders
$commonStartup = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
$userStartup   = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

$results += Get-StartupFolderItems -FolderPath $commonStartup -Location "Startup Folder (All Users)"
$results += Get-StartupFolderItems -FolderPath $userStartup -Location "Startup Folder (Current User)"

Write-Host "`n========= Startup Programs =========" -ForegroundColor Cyan
$results | Sort-Object Location, Name | Format-Table -AutoSize
