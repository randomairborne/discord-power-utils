param(
    [Parameter(mandatory = $true)]
    [UInt64]$GuildId,
    [Parameter(mandatory = $true)]
    [UInt64]$RoleId,
    [Parameter(mandatory = $false)]
    [switch]$Remove
)

. "$PSScriptRoot/Vars.ps1"

if ($null -eq $DiscordToken) {
    Write-Error -Message 'you must set $DiscordToken in Vars.ps1 to use AddRoleToUsers'
    Exit 1
}

if ($Remove) {
    $Method = "DELETE"
}
else {
    $Method = "PUT"
}

$Headers = @{"authorization" = "Bot $DiscordToken"; "user-agent" = "powershellcord/7.3 (valk@randomairborne.dev)" }

foreach ($UserId in Get-Content .\users.txt) {
    try {
        $Response = Invoke-WebRequest -URI "https://discord.com/api/v10/guilds/$GuildId/members/$UserId/roles/$RoleId" -Method $Method -Headers $Headers
        Write-Output "Added role $RoleId to $UserId"
    }
    catch {
        Write-Warning "Failed to add role"
        Write-Warning $_
    }
    $RatelimitRemaining = [int]($Response.Headers["x-ratelimit-remaining"][0])
    $RatelimitReset = [int]($Response.Headers["x-ratelimit-reset-after"][0]) + 1
    if ($RatelimitRemaining -eq 0) {
        Write-Output "sleeping for $RatelimitReset seconds to avoid ratelimiting"
        Start-Sleep -Seconds $RatelimitReset
    }
}