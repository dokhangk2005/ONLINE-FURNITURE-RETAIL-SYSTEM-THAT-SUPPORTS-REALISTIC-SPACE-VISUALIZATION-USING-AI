$serviceRoot = $PSScriptRoot
$venvPython = Join-Path $serviceRoot ".venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $venvPython)) {
    Write-Error "Chưa có môi trường Python. Chạy: python -m venv .venv; .\.venv\Scripts\python -m pip install -r requirements.txt"
    exit 1
}

Set-Location -LiteralPath $serviceRoot
& $venvPython -m uvicorn app:app --host 127.0.0.1 --port 8001
