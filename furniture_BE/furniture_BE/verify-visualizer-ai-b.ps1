param(
    [string]$ApiBaseUrl = "http://127.0.0.1:5024"
)

$ErrorActionPreference = "Stop"
$status = Invoke-RestMethod -Method Get -Uri "$ApiBaseUrl/api/room-designs/harmonization/status"

if ([string]::IsNullOrWhiteSpace($status.provider)) {
    throw "AI-B status is missing provider."
}
if ([string]::IsNullOrWhiteSpace($status.model)) {
    throw "AI-B status is missing model."
}
if ([int]$status.maxReferenceImages -lt 1) {
    throw "AI-B maxReferenceImages must be positive."
}

if ($status.available) {
    Write-Output "PASS_CONFIGURED_NO_PAID_CALL provider=$($status.provider) model=$($status.model) quality=$($status.quality)"
} else {
    Write-Output "PASS_NOT_CONFIGURED provider=$($status.provider) model=$($status.model) message=$($status.message)"
}
