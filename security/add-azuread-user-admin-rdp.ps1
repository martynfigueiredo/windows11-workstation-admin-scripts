<#
    .SYNOPSIS
        Adds an Azure AD user to the local Administrators and Remote Desktop Users groups,
        and enables Remote Desktop and its firewall rule.

    .PARAMETER UserUPN
        The UPN (user@domain) of the Azure AD user to add (without the “AzureAD\” prefix).

    .NOTES
        Requires running PowerShell as an administrator. The device must be Azure AD‑joined.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserUPN
)

try {
    $aadIdentity = "AzureAD\" + $UserUPN

    Add-LocalGroupMember -Group "Administrators" -Member $aadIdentity -ErrorAction Stop
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $aadIdentity -ErrorAction Stop

    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
        -Name "fDenyTSConnections" -Value 0 -ErrorAction Stop

    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop

    Write-Host "User $aadIdentity has been added as a local administrator and Remote Desktop user. Remote Desktop is now enabled." -ForegroundColor Green
}
catch {
    Write-Error "An error occurred: $_"
}
