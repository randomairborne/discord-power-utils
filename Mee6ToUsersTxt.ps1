param(
    [Parameter(mandatory = $false)]
    [UInt64]$MinimumLevel = 0
)

$JsonData = $null
$OutfilePath = "./Output/UsersAboveLevel$($MinimumLevel).txt"

try {
    $JsonData = Get-Content ./Input/Mee6Leaderboard.json | ConvertFrom-Json
    New-Item -Path . -Name $OutfilePath -ItemType "file"
}
catch {
    Write-Warning "Failed to convert JSON"
    Write-Warning $_
    Exit 1
}

foreach ($User in $JsonData) {
    if ($User.level -lt $MinimumLevel) {
        Break
    }
    Add-Content -Path $OutfilePath -Value $User.id
}

