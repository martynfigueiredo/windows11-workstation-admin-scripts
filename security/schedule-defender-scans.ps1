<#
    .SYNOPSIS
        Creates scheduled tasks for full and quick Windows Defender scans.

    .NOTES
        Run as Administrator.
#>

# Get Defender path
$defenderPath = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"

if (-not (Test-Path $defenderPath)) {
    Write-Host "⚠️  MpCmdRun.exe not found. Is Defender installed?" -ForegroundColor Yellow
    return
}

# Define scan commands
$fullScan  = "`"$defenderPath`" -Scan -ScanType 2"
$quickScan = "`"$defenderPath`" -Scan -ScanType 1"

# Define triggers
$fullTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Saturday -At 1am
$quickTrigger = @(
    New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 1am
    New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 1am
)

# Define task settings
$taskActionFull  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command $fullScan"
$taskActionQuick = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command $quickScan"

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register tasks
Register-ScheduledTask -TaskName "Defender Full Scan" `
    -Trigger $fullTrigger `
    -Action $taskActionFull `
    -Principal $principal `
    -Description "Runs a full Windows Defender scan every Saturday at 01:00 AM" `
    -Force

Register-ScheduledTask -TaskName "Defender Quick Scan" `
    -Trigger $quickTrigger `
    -Action $taskActionQuick `
    -Principal $principal `
    -Description "Runs a quick Windows Defender scan every Monday and Wednesday at 01:00 AM" `
    -Force

Write-Host "`n✅ Defender scan tasks created successfully." -ForegroundColor Green
