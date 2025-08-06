<#
    .SYNOPSIS
        Displays Windows Firewall status per network profile (Domain, Private, Public).

    .NOTES
        Uses NetSecurity module (available in Windows 10/11).
#>

$profiles = @("Domain", "Private", "Public")
$results = foreach ($profile in $profiles) {
    $settings = Get-NetFirewallProfile -Profile $profile

    [PSCustomObject]@{
        "Profile"                  = $profile
        "Enabled"                  = $settings.Enabled
        "Default Inbound Action"   = $settings.DefaultInboundAction
        "Default Outbound Action"  = $settings.DefaultOutboundAction
        "Allow Notifications"      = $settings.AllowNotifications
        "Allow Inbound Rules"      = $settings.AllowInboundRules
        "Log File Path"            = $settings.LogFileName
        "Log Max Size (KB)"        = $settings.LogMaxSizeKilobytes
        "Logging Enabled"          = $settings.LogAllowed
    }
}

Write-Host "`n========= Windows Firewall Status =========" -ForegroundColor Cyan
$results | Format-Table -AutoSize
