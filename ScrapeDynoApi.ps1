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
$Logs = [System.Collections.Generic.List[System.Collections.Hashtable]]::new()

$Headers = @{
    Cookie = "dynobot.sid=$DynoSid"
}

New-Item -ItemType Directory "./Output/" -Force | Out-Null

while ($LastPage -ge $Page) {
    try {
        $Uri = "https://dyno.gg/api/modules/$GuildId/modlogs?pageSize=50&page=$Page"
        $Response = Invoke-WebRequest -URI $Uri -Headers $Headers
        $Data = $Response | ConvertFrom-Json
        $ModTag = ""
        $UserTag = ""
        foreach ($Action in $Data.logs) {
            if ($null -eq $Action.mod.discriminator -or 0 -eq $Action.mod.discriminator) {
                $ModTag = $Action.mod.username + "#" + $Action.mod.discriminator
            }
            else {
                $ModTag = $Action.mod.username
            }
            if ($null -eq $Action.user.discriminator -or 0 -eq $Action.user.discriminator) {
                $UserTag = $Action.user.username + "#" + $Action.user.discriminator
            }
            else {
                $UserTag = $Action.user.username
            }
            $Logs.Add(@{
                    caseId    = $Action.caseNum
                    type      = $Action.type
                    modId     = $Action.mod.id
                    modName   = $ModTag
                    userId    = $Action.user.id
                    userName  = $UserTag
                    reason    = $Action.reason
                    createdAt = $Action.createdAt
                })
        }
        $LogListLength = $Logs.Count
        Write-Output "Got page $Page, total of $LogListLength cases"
        $LastPage = $Data.pageCount - 1
        $Page = $Page + 1
    }
    catch {
        Write-Warning "Failed to fetch from dashboard"
        Write-Warning $_
    }
    Start-Sleep -Seconds 2
}
Write-Information "Done, data written to ./Output/DynoModlogHistory.json"
$Logs | ConvertTo-Json -depth 100 | Out-File -Encoding utf8 "./Output/DynoModlogHistory.json"
