<#
    .SYNOPSIS
        Schedules a daily Windows Defender signature update using Task Scheduler.

    .NOTES
        Run as Administrator.
#>

# Get path to Defender update command
$defenderPath = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"

if (-not (Test-Path $defenderPath)) {
    Write-Host "⚠️  MpCmdRun.exe not found. Is Defender installed?" -ForegroundColor Yellow
    return
}

# Command to trigger signature update
$updateCommand = "`"$defenderPath`" -SignatureUpdate"

# Create daily trigger at 3:00 AM
$trigger = New-ScheduledTaskTrigger -Daily -At 3am

# Create action to run the update
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command $updateCommand"

# Set to run as SYSTEM with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName "Defender Signature Update" `
    -Trigger $trigger `
    -Action $action `
    -Principal $principal `
    -Description "Daily update of Windows Defender virus definitions at 3:00 AM" `
    -Force

Write-Host "`n✅ Defender update task created successfully." -ForegroundColor Green
