param(
    [string[]]$Addresses = @('10.99.99.1','10.99.99.253','10.99.99.252','10.99.99.251','10.99.99.250','10.99.99.249','10.99.99.248'),
    [ValidateRange(0.001,168)][double]$Hours = 48,
    [ValidateRange(2,3600)][int]$IntervalSeconds = 10,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot ('ap-monitor-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$csvPath = Join-Path $OutputDirectory 'reachability.csv'
$endTime = [DateTime]::UtcNow.AddHours($Hours)
$lastStates = @{}
Write-Host "Monitoring until $($endTime.ToLocalTime()). Keep this PC awake and connected. Ctrl+C stops."
Write-Host "Results: $csvPath"
while ([DateTime]::UtcNow -lt $endTime) {
    $cycle = [Diagnostics.Stopwatch]::StartNew()
    foreach ($address in $Addresses) {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $latency = $null
        try {
            $reply = $ping.Send($address,1000)
            $status = $reply.Status.ToString()
            if ($status -eq 'Success') { $latency = $reply.RoundtripTime }
        } catch { $status = 'ProbeError' }
        finally { $ping.Dispose() }
        $stamp = [DateTimeOffset]::Now.ToString('o')
        [pscustomobject]@{Timestamp=$stamp;Address=$address;Status=$status;LatencyMs=$latency} |
            Export-Csv -LiteralPath $csvPath -NoTypeInformation -Append
        if (!$lastStates.ContainsKey($address) -or $lastStates[$address] -ne $status) {
            Write-Host "$stamp  $address  $status"
            $lastStates[$address] = $status
        }
    }
    $remaining = [Math]::Min($IntervalSeconds - $cycle.Elapsed.TotalSeconds, ($endTime - [DateTime]::UtcNow).TotalSeconds)
    if ($remaining -gt 0) { Start-Sleep -Milliseconds ([int]($remaining * 1000)) }
}
Write-Host 'Monitoring finished.'

