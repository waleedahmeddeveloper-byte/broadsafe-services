$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc  = [System.Text.Encoding]::UTF8

# Check the footer "Our Services" list for href=# (current page link)
$svcFiles = @(
    'services\cashintransit.html',
    'services\cleaningservices.html',
    'services\commercialsitesecurity.html',
    'services\corporatesecurity.html',
    'services\eventsecurity.html',
    'services\facilitymanagementservices.html'
)

foreach ($fn in $svcFiles) {
    $path = Join-Path $base $fn
    $c = [System.IO.File]::ReadAllText($path, $enc)
    $hits = [regex]::Matches($c, 'href="#"[^>]*class="active"[^>]*>([^<]+)</a>')
    foreach ($h in $hits) {
        Write-Host "${fn}: footer active link -> $($h.Value.Substring(0, [Math]::Min(80,$h.Value.Length)))"
    }
    # Also check reverse order: class="active" before href="#"
    $hits2 = [regex]::Matches($c, '<a href="#" class="active">([^<]+)</a>')
    foreach ($h in $hits2) {
        Write-Host "${fn}: nav active link -> $($h.Value)"
    }
}

# Check apply-online.html aria-current missing
$path2 = Join-Path $base 'apply-online.html'
$c2 = [System.IO.File]::ReadAllText($path2, $enc)
if ($c2 -match 'aria-current') { Write-Host "apply-online: HAS aria-current" } else { Write-Host "apply-online: MISSING aria-current" }
$hits3 = [regex]::Matches($c2, 'class="active"[^>]*>')
foreach ($h in $hits3) { Write-Host "apply-online active: $($h.Value)" }
