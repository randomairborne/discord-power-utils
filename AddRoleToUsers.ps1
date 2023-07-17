param(
    [Parameter(mandatory = $true)]
    [UInt64]$GuildId,
    [Parameter(mandatory = $true)]
    [UInt64]$RoleId,
    [Parameter(mandatory = $false)]
    [switch]$Remove,
    [Parameter(mandatory = $false)]
    [string]$InputFile = "./Input/RoleList.txt"
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

foreach ($UserId in Get-Content $InputFile) {
    try {
        $Response = Invoke-WebRequest -URI "https://discord.com/api/v10/guilds/$GuildId/members/$UserId/roles/$RoleId" -Method $Method -Headers $Headers -SkipHttpErrorCheck
        $Status = $Response.StatusCode
        if ($Status.Equals(204)) {
            Write-Output "Modified role $RoleId on $UserId"
        } elseif ($Status.Equals(404)) {
            Write-Output "User $UserId is not in server $GuildId"
        } else {
            Write-Error "Failed to modify role $RoleId on $UserId"
        }
    }
    catch {
        Write-Error  "Failed to modify role $RoleId on $UserId"
        Write-Warning $_
    }
    $RatelimitRemaining = [int]($Response.Headers["x-ratelimit-remaining"][0])
    $RatelimitReset = [int]($Response.Headers["x-ratelimit-reset-after"][0]) + 1
    if ($RatelimitRemaining -eq 0) {
        Write-Output "sleeping for $RatelimitReset seconds to avoid ratelimiting"
        Start-Sleep -Seconds $RatelimitReset
    }
}