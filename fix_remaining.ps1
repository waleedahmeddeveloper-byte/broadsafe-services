param()
$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc  = [System.Text.Encoding]::UTF8
$total = 0

function Fix-File($path, $old, $new) {
    $c = [System.IO.File]::ReadAllText($path, $enc)
    if ($c.Contains($old)) {
        [System.IO.File]::WriteAllText($path, $c.Replace($old, $new), $enc)
        return $true
    }
    return $false
}

# ======================================================
# FIX 1: apply-online.html - add active class + aria-current to nav link
# ======================================================
Write-Host "=== FIX 1: apply-online.html active nav ==="
# Desktop nav
if (Fix-File "$base\apply-online.html" '<a href="apply-online.html">Apply Online</a>' '<a href="apply-online.html" class="active" aria-current="page">Apply Online</a>') {
    Write-Host "  FIXED desktop nav Apply Online"
    $total++
}
# Mobile nav - has two occurrences (use replace-all approach)
$path = "$base\apply-online.html"
$c = [System.IO.File]::ReadAllText($path, $enc)
if ($c.Contains('<li><a href="apply-online.html">Apply Online</a></li>')) {
    $c = $c.Replace('<li><a href="apply-online.html">Apply Online</a></li>', '<li><a href="apply-online.html" class="active" aria-current="page">Apply Online</a></li>')
    [System.IO.File]::WriteAllText($path, $c, $enc)
    Write-Host "  FIXED mobile nav Apply Online"
    $total++
}

# ======================================================
# FIX 2: Service pages with href="#" class="active" in footer service list
# These are the CURRENT page's entry in the "Our Services" footer list
# The href should be the page's own relative URL (or just remove class="active")
# Best practice: keep href as the real page URL, just style as active
# ======================================================
Write-Host "`n=== FIX 2: Fix href=# in footer 'Our Services' active items ==="

$svcPageMap = @{
    'services\cashintransit.html'            = @{ href='/services/cashintransit';            label='Cash In Transit Services Australia' }
    'services\cleaningservices.html'         = @{ href='/services/cleaningservices';          label='Cleaning Services' }
    'services\commercialsitesecurity.html'   = @{ href='/services/commercialsitesecurity';   label='Commercial Site Security' }
    'services\corporatesecurity.html'        = @{ href='/services/corporatesecurity';         label='Corporate Security' }
    'services\eventsecurity.html'            = @{ href='/services/eventsecurity';             label='Event Security Services' }
    'services\facilitymanagementservices.html' = @{ href='/services/facilitymanagementservices'; label='Facility Management' }
}

foreach ($fn in $svcPageMap.Keys) {
    $fpath = Join-Path $base $fn
    $info  = $svcPageMap[$fn]
    $old   = '<a href="#" class="active">' + $info.label + '</a>'
    $new   = '<a href="' + $info.href + '" class="active" aria-current="page">' + $info.label + '</a>'
    if (Fix-File $fpath $old $new) {
        Write-Host "  FIXED footer active link: $fn"
        $total++
    } else {
        Write-Host "  SKIP (not found): $fn | Looking for: $old"
    }
}

# ======================================================
# FIX 3: Adjust audit script regex - the audit was matching href="#" class="active"
# which also exists in footer service lists on other pages.
# Update the maintenanceservices.html too if it has the same issue
# ======================================================
Write-Host "`n=== FIX 3: Check maintenanceservices.html for footer active href=# ==="
$path3 = "$base\services\maintenanceservices.html"
$c3 = [System.IO.File]::ReadAllText($path3, $enc)
$hits = [regex]::Matches($c3, '<a href="#" class="active">([^<]+)</a>')
foreach ($h in $hits) {
    Write-Host "  Found: $($h.Value)"
}
if ($hits.Count -eq 0) { Write-Host "  None found - OK" }

Write-Host "`nTotal: $total changes"
