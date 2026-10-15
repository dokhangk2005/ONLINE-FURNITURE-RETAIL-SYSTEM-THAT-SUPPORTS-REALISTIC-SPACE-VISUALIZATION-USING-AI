param(
    [string]$BackendUrl = "http://127.0.0.1:5024",
    [string]$ImagePath = ""
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($ImagePath)) {
    $ImagePath = [System.IO.Path]::GetFullPath(
        (Join-Path $PSScriptRoot "..\..\khoaluan\assets\images\main-2-lux.jpg")
    )
}
if (-not (Test-Path -LiteralPath $ImagePath)) {
    throw "Không tìm thấy ảnh kiểm thử: $ImagePath"
}

$createdRaw = curl.exe -s `
    -F "roomImage=@$ImagePath;type=image/jpeg" `
    -F "title=Visual pipeline 2E verification" `
    "$BackendUrl/api/room-designs"
$created = $createdRaw | ConvertFrom-Json
if (-not $created.roomDesignId) {
    throw "Không tạo được thiết kế kiểm thử: $createdRaw"
}

$baseUrl = "$BackendUrl/api/room-designs/$($created.roomDesignId)"
$token = $created.accessToken
try {
    $firstWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $first = (curl.exe -s -X POST "${baseUrl}/analyze?accessToken=$token") | ConvertFrom-Json
    $firstWatch.Stop()

    $cacheWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $second = (curl.exe -s -X POST "${baseUrl}/analyze?accessToken=$token") | ConvertFrom-Json
    $cacheWatch.Stop()

    if ($first.cached -ne $false) { throw "Lần phân tích đầu không được là cache." }
    if ($second.cached -ne $true) { throw "Lần phân tích thứ hai phải lấy cache." }
    if ($first.depthGrid.values.Count -ne 768) { throw "Depth grid không đủ 768 điểm." }
    if ($first.lighting.grid.values.Count -ne 192) { throw "Light grid không đủ 192 điểm." }

    $imagePaths = @(
        $first.depthMapUrl,
        $first.floorMaskUrl,
        $first.wallMaskUrl,
        $first.overlayUrl,
        $first.occlusionMaskUrl,
        $first.foregroundUrl
    )
    foreach ($path in $imagePaths) {
        $response = Invoke-WebRequest "$BackendUrl${path}?accessToken=$token" -UseBasicParsing
        if ($response.StatusCode -ne 200 -or $response.RawContentLength -le 0) {
            throw "Ảnh phân tích không hợp lệ: $path"
        }
        if ([string]::IsNullOrWhiteSpace($response.Headers.ETag)) {
            throw "Ảnh phân tích thiếu ETag: $path"
        }
        $status = 0
        try {
            $conditional = Invoke-WebRequest `
                "$BackendUrl${path}?accessToken=$token" `
                -UseBasicParsing `
                -Headers @{ 'If-None-Match' = $response.Headers.ETag }
            $status = [int]$conditional.StatusCode
        }
        catch {
            if ($null -eq $_.Exception.Response) { throw }
            $status = [int]$_.Exception.Response.StatusCode
        }
        if ($status -ne "304") { throw "ETag không trả 304 cho $path (nhận $status)." }
    }

    $payload = @{
        title = "Visual pipeline 2E verification"
        items = @()
        occlusionEdits = @(
            @{ x = 0.4; y = 0.6; radius = 0.03; restore = $false; strokeId = 1 }
        )
    } | ConvertTo-Json -Depth 8
    Invoke-RestMethod -Method Put `
        -Uri "${baseUrl}?accessToken=$token" `
        -ContentType "application/json" `
        -Body $payload | Out-Null
    $loaded = Invoke-RestMethod "${baseUrl}?accessToken=$token"
    $scene = $loaded.sceneJson | ConvertFrom-Json
    if ($scene.occlusionEdits.Count -ne 1) { throw "Không lưu được nét sửa mask." }

    [pscustomobject]@{
        FirstRequestMs = $firstWatch.ElapsedMilliseconds
        AiProcessingMs = $first.processingMs
        CachedRequestMs = $cacheWatch.ElapsedMilliseconds
        CacheAgeSeconds = $second.cacheAgeSeconds
        Width = $first.width
        Height = $first.height
        FloorTopLeftX = $first.floorPlane.points[0].x
        FloorTopRightX = $first.floorPlane.points[1].x
        FloorBottomLeftX = $first.floorPlane.points[3].x
        FloorBottomRightX = $first.floorPlane.points[2].x
        OcclusionCoverage = $first.occlusionCoverage
        VerifiedImages = $imagePaths.Count
        Result = "PASS"
    } | Format-List
}
finally {
    curl.exe -s -X DELETE "${baseUrl}?accessToken=$token" | Out-Null
}
