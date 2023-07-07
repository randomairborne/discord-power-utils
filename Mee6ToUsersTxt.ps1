param(
    [Parameter(mandatory = $false)]
    [UInt64]$MinimumLevel = 0,
    [Parameter(mandatory = $false)]
    [string]$InputFile = "./Input/Mee6Leaderboard.json"
)

$JsonData = $null
$OutfilePath = "./Output/UsersAboveLevel$($MinimumLevel).txt"

try {
    $JsonData = Get-Content $InputFile | ConvertFrom-Json
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

