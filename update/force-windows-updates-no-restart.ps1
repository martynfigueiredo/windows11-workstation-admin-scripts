<#
    .SYNOPSIS
        Forces Windows to check, download, and install all available updates and drivers without restarting.

    .DESCRIPTION
        Ensures the system is up to date, including Microsoft updates and optional drivers if possible.
        Works without rebooting. Administrator privileges required.

    .NOTES
        Optional: If PSWindowsUpdate is available, it will be used to enhance driver update coverage.
#>

Write-Host "`n========= Forcing Windows Update =========" -ForegroundColor Cyan

try {
    # Enable Microsoft Update for drivers and Office updates
    $ServiceManager = New-Object -ComObject Microsoft.Update.ServiceManager
    $ServiceManager.ClientApplicationID = "My Windows Update Script"
    $ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null
    Write-Host "✔ Microsoft Update service added (for drivers & Office)." -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not register Microsoft Update. It might already be registered." -ForegroundColor Yellow
}

try {
    # Check for updates
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $SearchResult = $Searcher.Search("IsInstalled=0 and Type='Software' or Type='Driver'")

    if ($SearchResult.Updates.Count -eq 0) {
        Write-Host "✅ No new updates available." -ForegroundColor Green
    } else {
        Write-Host "🔄 Updates found: $($SearchResult.Updates.Count)" -ForegroundColor Cyan

        $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($update in $SearchResult.Updates) {
            Write-Host " → Queued: $($update.Title)"
            $UpdatesToDownload.Add($update) | Out-Null
        }

        $Downloader = $Session.CreateUpdateDownloader()
        $Downloader.Updates = $UpdatesToDownload
        $Downloader.Download()

        $Installer = $Session.CreateUpdateInstaller()
        $Installer.Updates = $UpdatesToDownload
        $Result = $Installer.Install()

        Write-Host "`n✅ Updates installed. Restart not forced." -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Failed to process updates." -ForegroundColor Red
}

# Optional: Try to use PSWindowsUpdate module if available
if (Get-Command Get-WindowsUpdate -ErrorAction SilentlyContinue) {
    Write-Host "`n🔍 PSWindowsUpdate detected. Checking for additional driver updates..." -ForegroundColor Cyan
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -MicrosoftUpdate
}
