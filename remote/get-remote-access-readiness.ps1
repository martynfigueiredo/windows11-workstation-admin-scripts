<#
    .SYNOPSIS
        Performs a full readiness check to verify if the system is properly configured for Remote Desktop access.

    .NOTES
        Requires Administrator privileges for some checks.
#>

Write-Host "`n========= Remote Access Readiness Check =========" -ForegroundColor Cyan

# --- RDP Enabled
$rdpEnabled = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -ErrorAction SilentlyContinue
if ($rdpEnabled.fDenyTSConnections -eq 0) {
    Write-Host "✔ Remote Desktop is ENABLED." -ForegroundColor Green
} else {
    Write-Host "❌ Remote Desktop is DISABLED." -ForegroundColor Red
}

# --- NLA Authentication
$nla = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -ErrorAction SilentlyContinue
if ($nla.UserAuthentication -eq 1) {
    Write-Host "✔ Network Level Authentication (NLA) is ENABLED." -ForegroundColor Green
} else {
    Write-Host "⚠️  Network Level Authentication is DISABLED." -ForegroundColor Yellow
}

# --- Firewall RDP Rule
$fw = Get-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled True -ErrorAction SilentlyContinue
if ($fw) {
    Write-Host "✔ RDP Firewall Rule is ENABLED." -ForegroundColor Green
} else {
    Write-Host "❌ RDP Firewall Rule is DISABLED or MISSING." -ForegroundColor Red
}

# --- Port Listening
$port3389 = netstat -an | Select-String ":3389 .*LISTENING"
if ($port3389) {
    Write-Host "✔ RDP Port 3389 is LISTENING." -ForegroundColor Green
} else {
    Write-Host "❌ RDP Port 3389 is NOT listening." -ForegroundColor Red
}

# --- Network Profile
$profile = Get-NetConnectionProfile | Select-Object -First 1
Write-Host "Network Profile: $($profile.Name) ($($profile.NetworkCategory))"
if ($profile.NetworkCategory -eq "Public") {
    Write-Host "⚠️  Public network may block RDP connections." -ForegroundColor Yellow
} else {
    Write-Host "✔ Network profile is Private/Domain." -ForegroundColor Green
}

# --- RDP Service
$ts = Get-Service TermService -ErrorAction SilentlyContinue
if ($ts.Status -eq 'Running') {
    Write-Host "✔ TermService (RDP service) is RUNNING." -ForegroundColor Green
} else {
    Write-Host "❌ TermService is NOT running." -ForegroundColor Red
}

# --- RDP Startup Type
if ($ts.StartType -eq "Automatic") {
    Write-Host "✔ TermService is set to AUTO start." -ForegroundColor Green
} else {
    Write-Host "⚠️  TermService is not set to auto start." -ForegroundColor Yellow
}

# --- User in RDP Group
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$rdpGroup = Get-LocalGroupMember -Group "Remote Desktop Users" -ErrorAction SilentlyContinue
$userInGroup = $rdpGroup | Where-Object { $_.Name -eq $currentUser }
if ($userInGroup) {
    Write-Host "✔ Current user is in Remote Desktop Users group." -ForegroundColor Green
} else {
    Write-Host "⚠️  Current user is NOT in Remote Desktop Users group." -ForegroundColor Yellow
}

# --- TCP KeepAlive
$keepAlive = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "KeepAliveTime" -ErrorAction SilentlyContinue
if ($keepAlive) {
    Write-Host "✔ TCP KeepAliveTime = $($keepAlive.KeepAliveTime) ms" -ForegroundColor Green
} else {
    Write-Host "⚠️  TCP KeepAliveTime is NOT set." -ForegroundColor Yellow
}

# --- RDP Max Sessions
$rdpMaxConn = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "MaxInstanceCount" -ErrorAction SilentlyContinue
if ($rdpMaxConn) {
    Write-Host "✔ Max RDP Sessions Allowed: $($rdpMaxConn.MaxInstanceCount)" -ForegroundColor Green
}

# --- Power Settings
$sleepAC = powercfg -query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | Select-String -Pattern "Power Setting Index"
$displayAC = powercfg -query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE | Select-String -Pattern "Power Setting Index"
Write-Host "✔ Sleep Timeout (AC): $($sleepAC -replace '.*Index:\s*','')"
Write-Host "✔ Display Timeout (AC): $($displayAC -replace '.*Index:\s*','')"

# --- Licensing Mode (optional RDS)
$licensing = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core" -ErrorAction SilentlyContinue
if ($licensing.ProductVersion) {
    Write-Host "✔ RDS Licensing Mode Detected: $($licensing.ProductVersion)" -ForegroundColor Green
}

# --- Certificate status
$cert = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SSLCertificateSHA1Hash" -ErrorAction SilentlyContinue
if ($cert.SSLCertificateSHA1Hash) {
    Write-Host "✔ Custom RDP certificate detected (SHA1: $($cert.SSLCertificateSHA1Hash.Substring(0,10))...)" -ForegroundColor Green
} else {
    Write-Host "⚠️  No custom RDP certificate found (may use self-signed)." -ForegroundColor Yellow
}
