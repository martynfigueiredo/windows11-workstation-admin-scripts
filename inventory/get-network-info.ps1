<#
    .SYNOPSIS
        Retrieves network adapter configuration details: IPs, gateways, DNS, MAC, status.

    .NOTES
        Covers both IPv4 and IPv6 configurations and physical details per adapter.
#>

$adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

$networkData = @()

foreach ($adapter in $adapters) {
    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adapter.ifIndex
    $dns = ($ipConfig.DnsServer.ServerAddresses -join ", ")
    $ipv4 = ($ipConfig.IPv4Address.IPAddress -join ", ")
    $ipv6 = ($ipConfig.IPv6Address.IPAddress -join ", ")
    $gateway = ($ipConfig.IPv4DefaultGateway.NextHop -join ", ")

    $networkData += [PSCustomObject]@{
        "Adapter Name"     = $adapter.Name
