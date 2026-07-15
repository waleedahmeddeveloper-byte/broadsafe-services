$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$files = @('about.html','services\mobilepatrols.html','services\staticguarding.html','services\securecarparkservices.html')
foreach ($f in $files) {
    $path = Join-Path $base $f
    $c = [System.IO.File]::ReadAllText($path)
    $mainIdx = $c.IndexOf('<main id=')
    $navIdx  = $c.IndexOf('<div class="mobile-nav">')
    $hdrClose = $c.IndexOf('</header>')
    $insideMain = ($navIdx -gt $mainIdx)
    Write-Host "File: $f"
    Write-Host "  header-close: $hdrClose  |  main-open: $mainIdx  |  mobile-nav: $navIdx  |  inside-main: $insideMain"
    if ($navIdx -ge 0) {
        $ctx = $c.Substring([Math]::Max(0,$navIdx - 80), 160)
        Write-Host "  Context: $($ctx -replace '\n',' ')"
    }
    Write-Host ''
}
