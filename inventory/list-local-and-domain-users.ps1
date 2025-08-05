<#
    .SYNOPSIS
        Lists all user accounts on the system, including local, domain, and system users,
        with detailed attributes.

    .NOTES
        Run as Administrator for full results.
        This script is intended for Windows 10/11 workstations.
#>

# Get local user accounts
$localUsers = Get-LocalUser | Select-Object `
    Name,
    SID,
    Enabled,
    Description,
    LastLogon,
    PasswordChangeableDate,
    PasswordExpires,
    PasswordLastSet,
    UserMayChangePassword

# Get domain/remote users currently known to the system (logged in or profiled)
$loggedUsers = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount='False'" |
    Select-Object `
        Name,
        SID,
        FullName,
        Domain,
        Status,
        Disabled,
        Lockout,
        PasswordChangeable,
        PasswordExpires,
        PasswordRequired

# Display results
Write-Host "`n--- Local Users ---`n" -ForegroundColor Cyan
$localUsers | Format-Table -AutoSize

Write-Host "`n--- Domain Users (if any are cached on system) ---`n" -ForegroundColor Cyan
$loggedUsers | Format-Table -AutoSize
