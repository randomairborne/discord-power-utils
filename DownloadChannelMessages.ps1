param(
    [Parameter(mandatory = $true)]
    [UInt64]$ChannelId
)

. "$PSScriptRoot/Vars.ps1"

if ($null -eq $DiscordToken) {
    Write-Error 'You must set $DiscordToken in Vars.ps1 to use DownloadChannelMessages'
    Exit 1
}

$Headers = @{"authorization" = "Bot $DiscordToken"; "user-agent" = "powershellcord/7.3 (valk@randomairborne.dev)" }
$OutfilePath = "./Output/ChannelMessages.jsonl"
$NewestMessageId = $null

try {
    New-Item -Path . -Name $OutfilePath -ItemType "file" -Force | Out-Null
}
catch {}

while ($true) {
    $Uri = "https://discord.com/api/v10/channels/$ChannelId/messages?limit=100&after=" + ($null -eq $NewestMessageId ? "0" : $NewestMessageId)
    $Response = Invoke-WebRequest -URI $Uri -Method "GET" -Headers $Headers

    $Data = $Response | ConvertFrom-Json
    if ($null -eq $Data) {
        Write-Output "No new messages"
        Exit 0
    }
    $NewestMessageId = $Data[0].id

    foreach ($Message in $Data) {
        Add-Content -Path $OutfilePath -Value ($Message | ConvertTo-Json -Compress -Depth 100)
    }
    Write-Output "Downloaded messages up to $NewestMessageId"

    $RatelimitRemaining = [int]($Response.Headers["x-ratelimit-remaining"][0])
    $RatelimitReset = [int]($Response.Headers["x-ratelimit-reset-after"][0]) + 1
    if ($RatelimitRemaining -eq 0) {
        Write-Output "sleeping for $RatelimitReset seconds to avoid ratelimiting"
        Start-Sleep -Seconds $RatelimitReset
    }
}
