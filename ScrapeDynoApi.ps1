param(
    [Parameter(mandatory = $true)]
    [UInt64]$GuildId
)

. "$PSScriptRoot/Vars.ps1"

if ($null -eq $DynoSid) {
    Write-Error -Message 'you must set $DynoSid in Vars.ps1 to use AddRoleToUsers'
    Exit 1
}

$Page = 0
$LastPage = 1

$Headers = @{
    Cookie = "dynobot.sid=$DynoSid"
}

New-Item -ItemType Directory "./Output/DynoModlogHistory/" -Force | Out-Null

while ($LastPage -ge $Page) {
    try {
        $Uri = "https://dyno.gg/api/modules/$GuildId/modlogs?pageSize=50&page=$Page"
        $Response = Invoke-WebRequest -URI $Uri -Headers $Headers
        $Data = $Response | ConvertFrom-Json
        $Response | Out-File -Encoding utf8 "./Output/DynoModlogHistory/$Page.json
        Write-Output "Got page $Page"
        $LastPage = $Data.pageCount - 1
        $Page = $Page + 1
    }
    catch {
        Write-Warning "Failed to fetch from dashboard"
        Write-Warning $_
    }
    Start-Sleep -Seconds 2
}
Write-Information "Done, data written to ./Output/DynoModlogHistory/*.json"
