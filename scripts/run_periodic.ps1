param(
    [int]$Runs = 3,
    [int]$IntervalSeconds = 60
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$dbtProject = Join-Path $repoRoot "dbt"

Push-Location $dbtProject

try {
    for ($i = 1; $i -le $Runs; $i++) {

        Write-Host ""
        Write-Host "===== Periodic dbt run $i of $Runs ====="
        Write-Host "Started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

        dbt build

        if ($LASTEXITCODE -ne 0) {
            Write-Error "dbt build failed."
            exit $LASTEXITCODE
        }

        Write-Host "Completed successfully."

        if ($i -lt $Runs) {
            Write-Host "Waiting $IntervalSeconds seconds..."
            Start-Sleep -Seconds $IntervalSeconds
        }
    }
}
finally {
    Pop-Location
}