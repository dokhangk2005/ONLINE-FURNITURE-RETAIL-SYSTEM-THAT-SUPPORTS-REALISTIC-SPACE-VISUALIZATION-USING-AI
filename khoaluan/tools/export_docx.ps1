$ErrorActionPreference = 'Stop'
$docx = (Resolve-Path 'D:\KLTN\khoaluan\artifacts\Tai_lieu_phan_bien_web_noi_that.docx').Path
$pdf = 'D:\KLTN\khoaluan\artifacts\Tai_lieu_phan_bien_web_noi_that.pdf'
$status = 'D:\KLTN\khoaluan\artifacts\word_export_status.txt'
Set-Content -LiteralPath $status -Value 'starting'
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$word.Options.PrintBackground = $false
try {
    Add-Content -LiteralPath $status -Value 'word-created'
    $document = $word.Documents.Open($docx, $false, $true, $false)
    Add-Content -LiteralPath $status -Value 'document-opened'
    $pages = $document.ComputeStatistics(2)
    Add-Content -LiteralPath $status -Value "pages=$pages"
    $document.ExportAsFixedFormat($pdf, 17)
    Add-Content -LiteralPath $status -Value 'exported'
    $document.Close($false)
    Add-Content -LiteralPath $status -Value 'document-closed'
}
catch {
    Add-Content -LiteralPath $status -Value ("error=" + $_.Exception.Message)
}
finally {
    $word.Quit()
    [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($word)
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    Add-Content -LiteralPath $status -Value 'word-quit'
}
