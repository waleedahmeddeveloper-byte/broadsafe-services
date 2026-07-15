param()
$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'

function Fix-File($path, $old, $new) {
    $enc = [System.Text.Encoding]::UTF8
    $c = [System.IO.File]::ReadAllText($path, $enc)
    if ($c.Contains($old)) {
        $fixed = $c.Replace($old, $new)
        [System.IO.File]::WriteAllText($path, $fixed, $enc)
        return $true
    }
    return $false
}

function Fix-FileRegex($path, $pattern, $replacement) {
    $enc = [System.Text.Encoding]::UTF8
    $c = [System.IO.File]::ReadAllText($path, $enc)
    $fixed = [regex]::Replace($c, $pattern, $replacement)
    if ($fixed -ne $c) {
        [System.IO.File]::WriteAllText($path, $fixed, $enc)
        return $true
    }
    return $false
}

$svcFiles = Get-ChildItem "$base\services" -Filter *.html | ForEach-Object { $_.FullName }
$allFiles = @("$base\index.html","$base\about.html","$base\contact.html","$base\apply-online.html") + $svcFiles
$total = 0

# ======================================================
# FIX B: Restore broken active nav links
# ======================================================
Write-Host "`n=== FIX B: Fix broken active nav href=# ==="

# index.html: desktop nav, mobile nav inside main, footer Quick Links
$fixes = @(
    @{ Path="$base\index.html"; Old='<a href="#" class="active">Home</a>'; New='<a href="index.html" class="active" aria-current="page">Home</a>' }
    @{ Path="$base\index.html"; Old='<li><a href="#" class="active">Home</a></li>'; New='<li><a href="index.html" class="active" aria-current="page">Home</a></li>' }
    @{ Path="$base\about.html"; Old='<a href="#" class="active">About</a>'; New='<a href="about.html" class="active" aria-current="page">About</a>' }
    @{ Path="$base\about.html"; Old='<li><a href="#" class="active">About</a></li>'; New='<li><a href="about.html" class="active" aria-current="page">About</a></li>' }
    @{ Path="$base\contact.html"; Old='<a href="#" class="active">Contact</a>'; New='<a href="contact.html" class="active" aria-current="page">Contact</a>' }
    @{ Path="$base\contact.html"; Old='<li><a href="#" class="active">Contact</a></li>'; New='<li><a href="contact.html" class="active" aria-current="page">Contact</a></li>' }
    # Footer Quick Links on root pages also have href="#"
    @{ Path="$base\index.html"; Old='<li><a href="#" class="active">Home</a></li>'; New='<li><a href="index.html" class="active" aria-current="page">Home</a></li>' }
)
foreach ($f in $fixes) {
    if (Fix-File $f.Path $f.Old $f.New) {
        Write-Host "  FIXED: $($f.Path -replace [regex]::Escape($base),'') - active nav"
        $total++
    }
}

# Service pages: add aria-current to existing class="active" links
foreach ($f in $svcFiles) {
    if (Fix-File $f 'class="active">Services</a>' 'class="active" aria-current="page">Services</a>') {
        Write-Host "  FIXED aria-current: $($f -replace [regex]::Escape($base),'')"
        $total++
    }
}
# services/index.html
if (Fix-File "$base\services\index.html" 'class="active">Services</a>' 'class="active" aria-current="page">Services</a>') {
    Write-Host "  FIXED services/index.html aria-current"
    $total++
}

# ======================================================
# FIX C: Expand service page footer "Our Services" - add 4 missing services
# ======================================================
Write-Host "`n=== FIX C: Expand service footer (add missing services) ==="
$oldEnd = '<li><a href="/services/manufacturingwarehousingsecurity">Manufacturing & Warehousing</a></li>'
$newEnd = '<li><a href="/services/manufacturingwarehousingsecurity">Manufacturing & Warehousing</a></li>
                <li><a href="/services/facilitymanagementservices">Facility Management</a></li>
                <li><a href="/services/cleaningservices">Cleaning Services</a></li>
                <li><a href="/services/securecarparkservices">Secure Car Park</a></li>
                <li><a href="/services/maintenanceservices">Maintenance Services</a></li>'
foreach ($f in $svcFiles) {
    if (Fix-File $f $oldEnd $newEnd) {
        Write-Host "  FIXED footer services list: $($f -replace [regex]::Escape($base),'')"
        $total++
    }
}

# ======================================================
# FIX D: Service page footer Quick Links "Work with us" -> "Apply Online"
# ======================================================
Write-Host "`n=== FIX D: Footer 'Work with us' -> 'Apply Online' ==="
foreach ($f in $svcFiles) {
    if (Fix-File $f '<a href="/apply-online">Work with us</a>' '<a href="/apply-online">Apply Online</a>') {
        Write-Host "  FIXED: $($f -replace [regex]::Escape($base),'')"
        $total++
    }
}

# ======================================================
# FIX E: Remove unused fonts.googleapis.com preconnect from all pages
# ======================================================
Write-Host "`n=== FIX E: Remove unused Google Fonts preconnect ==="
foreach ($f in $allFiles) {
    if (Fix-File $f '<link rel="preconnect" href="https://fonts.googleapis.com">' '') {
        Write-Host "  FIXED: $($f -replace [regex]::Escape($base),'')"
        $total++
    }
    Fix-File $f "`n<link rel=""preconnect"" href=""https://fonts.googleapis.com"">" '' | Out-Null
}

# ======================================================
# FIX G: Fix about.html viewport meta (remove non-standard attributes)
# ======================================================
Write-Host "`n=== FIX G: Fix about.html viewport meta ==="
if (Fix-File "$base\about.html" 'content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes"' 'content="width=device-width, initial-scale=1.0"') {
    Write-Host "  FIXED about.html viewport"
    $total++
}

# ======================================================
# FIX H: Expand contact.html meta description (93 chars -> ~155 chars)
# ======================================================
Write-Host "`n=== FIX H: Expand contact.html meta description ==="
if (Fix-File "$base\contact.html" 'content="Contact Broadsafe Services for security enquiries, quotes, and 24/7 support across Australia."' 'content="Contact Broadsafe Services for professional security enquiries and quotes. Reach our 24/7 team on 03 7064 8292 or submit an enquiry online. We serve businesses across all of Australia."') {
    Write-Host "  FIXED: contact.html meta description"
    $total++
}
if (Fix-File "$base\contact.html" '<meta property="og:description" content="Contact Broadsafe Services for security enquiries, quotes, and 24/7 support across Australia.">' '<meta property="og:description" content="Contact Broadsafe Services for professional security enquiries and quotes. Reach our 24/7 team on 03 7064 8292 or enquire online. We serve businesses across all of Australia.">') {
    Write-Host "  FIXED: contact.html og:description"
    $total++
}
if (Fix-File "$base\contact.html" '<meta name="twitter:description" content="Contact Broadsafe Services for security enquiries, quotes, and 24/7 support across Australia.">' '<meta name="twitter:description" content="Contact Broadsafe Services for professional security enquiries and quotes. Reach our 24/7 team on 03 7064 8292 or enquire online. We serve businesses across all of Australia.">') {
    Write-Host "  FIXED: contact.html twitter:description"
    $total++
}

# ======================================================
# FIX K: Fix mobile nav placement - move from inside <main> to between </header> and <main>
# This is the semantic structure fix
# ======================================================
Write-Host "`n=== FIX K: Move mobile-nav outside of <main> (semantic fix) ==="

# For index.html and root pages - mobile nav is immediately after <main ...> open tag
# Pattern: <main id="main-content" role="main">\n<div class="mobile-nav">...</div>\n
# Fix: remove from inside main, insert between </header> and <main>
$rootPages = @("$base\index.html","$base\about.html","$base\contact.html","$base\apply-online.html")
foreach ($f in $rootPages) {
    $enc = [System.Text.Encoding]::UTF8
    $c = [System.IO.File]::ReadAllText($f, $enc)
    
    # Extract mobile-nav block from inside main
    $mobileNavPattern = '(?s)(<main[^>]*>\s*)(\n<!-- Mobile Navigation -->\n<div class="mobile-nav">.*?</div>\n\n)'
    $m = [regex]::Match($c, $mobileNavPattern)
    if ($m.Success) {
        $mainOpenTag = $m.Groups[1].Value.TrimEnd()
        $mobileNavBlock = $m.Groups[2].Value
        # Remove mobile-nav from inside main
        $c = $c.Replace($m.Groups[1].Value + $m.Groups[2].Value, "$mainOpenTag`n`n")
        # Insert mobile-nav after </header>
        $c = $c.Replace("</header>`n", "</header>`n`n$mobileNavBlock")
        [System.IO.File]::WriteAllText($f, $c, $enc)
        Write-Host "  FIXED mobile-nav moved outside main: $($f -replace [regex]::Escape($base),'')"
        $total++
    } else {
        Write-Host "  SKIP (pattern not found): $($f -replace [regex]::Escape($base),'')"
    }
}

# Service pages
foreach ($f in $svcFiles) {
    $enc = [System.Text.Encoding]::UTF8
    $c = [System.IO.File]::ReadAllText($f, $enc)
    $mobileNavPattern = '(?s)(<main[^>]*>\s*)(\n<!-- Mobile Navigation -->\n<div class="mobile-nav">.*?</div>\n\n)'
    $m = [regex]::Match($c, $mobileNavPattern)
    if ($m.Success) {
        $mainOpenTag = $m.Groups[1].Value.TrimEnd()
        $mobileNavBlock = $m.Groups[2].Value
        $c = $c.Replace($m.Groups[1].Value + $m.Groups[2].Value, "$mainOpenTag`n`n")
        $c = $c.Replace("</header>`n", "</header>`n`n$mobileNavBlock")
        [System.IO.File]::WriteAllText($f, $c, $enc)
        Write-Host "  FIXED mobile-nav moved outside main: $($f -replace [regex]::Escape($base),'')"
        $total++
    } else {
        Write-Host "  SKIP (pattern not found): $($f -replace [regex]::Escape($base),'')"
    }
}

Write-Host "`n=== Total changes applied: $total ==="
Write-Host "Done."
