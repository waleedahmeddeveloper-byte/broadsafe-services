$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc = [System.Text.Encoding]::UTF8

$svcFiles  = Get-ChildItem "$base\services" -Filter *.html | ForEach-Object { $_.FullName }
$rootPages = @("$base\index.html","$base\about.html","$base\contact.html","$base\apply-online.html")
$allFiles  = $rootPages + $svcFiles

$pass = 0; $fail = 0; $issues = @()

foreach ($f in $allFiles) {
    $c = [System.IO.File]::ReadAllText($f, $enc)
    $short = $f -replace [regex]::Escape($base + '\'),''

    # Check: no USAGE developer comments
    if ($c -match 'USAGE: Copy this') {
        $issues += "[FAIL] $short - Still has USAGE developer comment"; $fail++
    }

    # Check: no href="#" in nav links (outside of smooth scroll targets)
    $brokenNavHref = [regex]::Matches($c, '<a href="#" class="active"')
    if ($brokenNavHref.Count -gt 0) {
        $issues += "[FAIL] $short - Has broken href=# active nav ($($brokenNavHref.Count) hits)"; $fail++
    }

    # Check: mobile-nav not inside main
    $mainIdx   = $c.IndexOf('<main id="main-content"')
    $mobileIdx = $c.IndexOf('<div class="mobile-nav">')
    if ($mobileIdx -gt $mainIdx -and $mainIdx -ge 0) {
        $issues += "[FAIL] $short - mobile-nav still inside <main>"; $fail++
    } elseif ($mobileIdx -lt 0) {
        $issues += "[WARN] $short - mobile-nav div not found"; $fail++
    }

    # Check: fonts.googleapis.com preconnect removed
    if ($c -match 'fonts\.googleapis\.com') {
        $issues += "[FAIL] $short - fonts.googleapis.com preconnect still present"; $fail++
    }

    # Check: Slick CSS removed from non-index
    if ($f -notmatch 'index\.html' -and $c -match 'slick-carousel') {
        $issues += "[FAIL] $short - Slick carousel CSS on non-slider page"; $fail++
    }

    # Check: skip link present
    if (-not ($c -match 'class="skip-link"')) {
        $issues += "[FAIL] $short - Skip link missing"; $fail++
    }

    # Check: aria-current present on at least one nav link
    if (-not ($c -match 'aria-current="page"')) {
        $issues += "[FAIL] $short - No aria-current on active nav link"; $fail++
    }

    # Check: no maximum-scale in viewport
    if ($c -match 'maximum-scale') {
        $issues += "[FAIL] $short - viewport has maximum-scale"; $fail++
    }

    # Check: copyright 2025-2026
    if (-not ($c -match '2025')) {
        $issues += "[FAIL] $short - No 2025 in copyright"; $fail++
    }

    # Check: canonical with www.
    if (-not ($c -match 'rel="canonical"')) {
        $issues += "[FAIL] $short - No canonical tag"; $fail++
    }

    # Check: lang=en-AU somewhere
    if (-not ($c -match 'lang="en-AU"')) {
        $issues += "[FAIL] $short - No lang=en-AU"; $fail++
    }

    # Check: GTM present
    if (-not ($c -match 'GTM-KNQRM38F')) {
        $issues += "[FAIL] $short - GTM missing"; $fail++
    }

    $pass++
}

Write-Host "=== AUDIT COMPLETE: $pass pages checked ==="
if ($issues.Count -eq 0) {
    Write-Host "ALL CHECKS PASSED - No issues found!"
} else {
    Write-Host "$($issues.Count) issues found:`n"
    $issues | ForEach-Object { Write-Host "  $_" }
}
