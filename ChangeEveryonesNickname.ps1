param(
    [Parameter(mandatory = $true)]
    [UInt64]$GuildId,
    [Parameter(mandatory = $false)]
    [UInt64]$Nick,
    [Parameter(mandatory = $false)]
    [string]$InputFile = "./Input/NicknameList.txt"
)

. "$PSScriptRoot/Vars.ps1"

if ($null -eq $DiscordToken) {
    Write-Error -Message 'you must set $DiscordToken in Vars.ps1 to use AddRoleToUsers'
    Exit 1
}

$Headers = @{"authorization" = "Bot $DiscordToken"; "user-agent" = "powershellcord/7.3 (valk@randomairborne.dev)" }
$Payload = @{"nick" = $Nick } | ConvertTo-Json

foreach ($UserId in Get-Content $InputFile) {
    try {
        $Uri = "https://discord.com/api/v10/guilds/$GuildId/members/$UserId"
        $Response = Invoke-WebRequest -URI $Uri -Method "PATCH" -Headers $Headers -Body $Payload
        $Status = $Response.StatusCode
        $Data = $Response | ConvertFrom-Json
        if ($Status.Equals(204)) {
            Write-Output "Changed nickname of $($UserId) to $($Data.username) ($($UserId))"
        } elseif ($Status.Equals(404)) {
            Write-Output "User $UserId is not in server $GuildId"
        } else {
            Write-Error "Failed to modify nickname $RoleId on $UserId"
        }
    }
    catch {
        Write-Error  "Failed to modify nickname $RoleId on $UserId"
        Write-Warning $_
    }
    $RatelimitRemaining = [int]($Response.Headers["x-ratelimit-remaining"][0])
    $RatelimitReset = [int]($Response.Headers["x-ratelimit-reset-after"][0]) + 1
    if ($RatelimitRemaining -eq 0) {
        Write-Output "sleeping for $RatelimitReset seconds to avoid ratelimiting"
        Start-Sleep -Seconds $RatelimitReset
    }
}