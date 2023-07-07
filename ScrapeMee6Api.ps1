param(
    [Parameter(mandatory = $true)]
    [UInt64]$GuildId,
    [Parameter(mandatory = $false)]
    [UInt64]$LastLevel = 0
)


$Page = 0
$Players = [System.Collections.Generic.List[System.Collections.Hashtable]]::new()
$CurrentLevel = $null

New-Item -ItemType Directory "./Output/" -Force | Out-Null

do {
    try {
        $Uri = "https://mee6.xyz/api/plugins/levels/leaderboard/" + $GuildId + "?limit=1000&page=$Page"
        $Response = Invoke-WebRequest -URI $Uri
        $Data = $Response | ConvertFrom-Json
        foreach ($Player in $Data.players) {
            $Players.Add(@{
                    id       = $Player.id
                    xp       = $Player.xp
                    level    = $Player.level
                    username = $Player.username
                })
        }
        $CurrentLevel = $Data.players[-1].level
        Write-Output "Got page $Page, users of level greater than $CurrentLevel"
        $Page = $Page + 1
    }
    catch {
        Write-Warning "Failed to fetch from dashboard"
        Write-Warning $_
    }
    Start-Sleep -Seconds 2
} while ($CurrentLevel -ge $LastLevel)
Write-Information "Done, data written to ./Output/Mee6Leaderboard.json"
$Players | ConvertTo-Json -depth 100 | Out-File -Encoding utf8 "./Output/Mee6Leaderboard.json"
