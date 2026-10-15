$backendRoot = $PSScriptRoot
$frontendRoot = [System.IO.Path]::GetFullPath((Join-Path $backendRoot "..\..\khoaluan"))
$aiPython = Join-Path $backendRoot "ai_service\.venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $aiPython)) {
    Write-Error "Chưa cài AI service. Xem ai_service\README.md."
    exit 1
}

if (-not (Test-Path -LiteralPath (Join-Path $frontendRoot "pubspec.yaml"))) {
    Write-Error "Không tìm thấy Flutter frontend tại $frontendRoot"
    exit 1
}

if (-not (Get-NetTCPConnection -State Listen -LocalPort 8001 -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath $aiPython `
        -ArgumentList "-m", "uvicorn", "app:app", "--host", "127.0.0.1", "--port", "8001" `
        -WorkingDirectory (Join-Path $backendRoot "ai_service") `
        -WindowStyle Hidden
}

if (-not (Get-NetTCPConnection -State Listen -LocalPort 5024 -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "dotnet" `
        -ArgumentList "run", "--no-build" `
        -WorkingDirectory $backendRoot `
        -WindowStyle Hidden
}

if (-not (Get-NetTCPConnection -State Listen -LocalPort 8085 -ErrorAction SilentlyContinue)) {
    $flutterCommand = (Get-Command flutter -ErrorAction Stop).Source
    Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" `
        -ArgumentList "/c", "`"$flutterCommand`" run -d web-server --web-port 8085" `
        -WorkingDirectory $frontendRoot `
        -WindowStyle Hidden
}

Write-Host "AI service: http://127.0.0.1:8001/health"
Write-Host "Backend:    http://localhost:5024"
Write-Host "Flutter:    http://localhost:8085"
