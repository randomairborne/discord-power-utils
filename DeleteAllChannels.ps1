param(
    [Parameter(mandatory = $true)]
    [UInt64]$GuildId
)

. "$PSScriptRoot/Vars.ps1"

if ($null -eq $DiscordToken) {
    Write-Error -Message 'you must set $DiscordToken in Vars.ps1 to use DeleteAllChannels'
    Exit 1
}

$Headers = @{"authorization" = "Bot $DiscordToken"; "user-agent" = "powershellcord/7.3 (valk@randomairborne.dev)" }
$Channels = Invoke-WebRequest -URI $Uri -Method "GET" -Headers $Headers | ConvertFrom-Json

foreach ($Channel in $Channels) {
    try {
        $Uri = "https://discord.com/api/v10/channels/${Channel.id}"
        $Status = $Response.StatusCode
        $Data = $Response | ConvertFrom-Json
        if ($Status.Equals(200)) {
            Write-Output "Deleted channel ${Channel.name} (${Channel.id})"
        } elseif ($Status.Equals(404)) {
            Write-Output "Channel ${Channel.id} not found"
        } else {
            Write-Error "Failed to delete channel ${Channel.id}"
        }
    }
    catch {
        Write-Error "Failed to delete channel ${Channel.id}"
        Write-Warning $_
    }
    $RatelimitRemaining = [int]($Response.Headers["x-ratelimit-remaining"][0])
    $RatelimitReset = [int]($Response.Headers["x-ratelimit-reset-after"][0]) + 1
    if ($RatelimitRemaining -eq 0) {
        Write-Output "sleeping for $RatelimitReset seconds to avoid ratelimiting"
        Start-Sleep -Seconds $RatelimitReset
    }
}
