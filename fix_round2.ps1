$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$rootFiles = @('index.html','about.html','contact.html','apply-online.html') | ForEach-Object { Join-Path $base $_ }
$svcFiles  = Get-ChildItem "$base\services" -Filter *.html | ForEach-Object { $_.FullName }
$allFiles  = $rootFiles + $svcFiles

function R($path, $old, $new) {
    $c = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    if ($c.Contains($old)) {
        $c = $c.Replace($old, $new)
        [System.IO.File]::WriteAllText($path, $c, [System.Text.Encoding]::UTF8)
        return $true
    }
    return $false
}

$total = 0

# ======================================================
# FIX A: Clean corrupted HTML comment text (dev-only usage notes with injected skip links)
# ======================================================
Write-Host "`n=== FIX A: Remove corrupted developer comment blocks ==="
$devComments = @(
    # First pattern: noscript usage comment
    @{
        Old = "<!--`nUSAGE: Copy this noscript tag into each page's <body>`n    <a href=""#main-content"" class=""skip-link"">Skip to main content</a> section, right after opening <body>`n    <a href=""#main-content"" class=""skip-link"">Skip to main content</a> tag`nPlace BEFORE header component`n-->"
        New = ""
    },
    # Second pattern: header usage comment  
    @{
        Old = "<!--`nUSAGE: Copy this header into each page's <body>`n    <a href=""#main-content"" class=""skip-link"">Skip to main content</a> section, right after opening <body>`n    <a href=""#main-content"" class=""skip-link"">Skip to main content</a> tag`nRequires: Mobile navigation component, responsive CSS, and JavaScript`n-->"
        New = ""
    },
    @{
        Old = "    <!-- Skip Navigation Link for Accessibility -->`n"
        New = ""
    },
    @{
        Old = "`n    <!-`n`n`n-->"
        New = ""
    },
    @{
        Old = "`n    <!--`n`n`n-->`n`n`n`n    "
        New = "`n    "
    }
)

foreach ($f in $allFiles) {
    $c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
    $changed = $false
    
    # Remove all developer comment blocks with regex
    $before = $c
    
    # Pattern 1: noscript usage comment (with or without skip link injection)
    $c = [regex]::Replace($c, '(?s)<!--\s*\nUSAGE: Copy this noscript tag into each page.*?-->', '')
    # Pattern 2: header usage comment
    $c = [regex]::Replace($c, '(?s)<!--\s*\nUSAGE: Copy this header into each page.*?-->', '')
    # Pattern 3: any usage comment block
    $c = [regex]::Replace($c, '(?s)<!--\s*\nUSAGE:.*?-->', '')
    # Pattern 4: empty comment blocks (3+ blank lines inside)
    $c = [regex]::Replace($c, '<!--\s*\n\s*\n\s*\n\s*-->', '')
    # Pattern 5: "Skip Navigation Link for Accessibility" comment
    $c = $c.Replace('    <!-- Skip Navigation Link for Accessibility -->', '')
    # Pattern 6: "<!-- Header -->" inside main (placeholder from template)
    $c = [regex]::Replace($c, '\s*<!-- Header -->\s*\n\s*\n', "`n")
    # Pattern 7: "<!-- Header (Standardized to match reference) -->" comment
    $c = $c.Replace('    <!-- Header (Standardized to match reference) -->', '')
    # Pattern 8: "<!-- Header -->" standalone
    $c = [regex]::Replace($c, '\s*<!-- Header -->\s*', "`n")
    
    if ($c -ne $before) {
        [System.IO.File]::WriteAllText($f, $c, [System.Text.Encoding]::UTF8)
        Write-Host "  CLEANED: $($f -replace [regex]::Escape($base),'')"
        $total++
    }
}

# ======================================================
# FIX B: Restore broken active nav links (href="#" -> real href + aria-current)
# ======================================================
Write-Host "`n=== FIX B: Fix active nav links (restore href, add aria-current) ==="

# index.html - Home active
if (R "$base\index.html" '<a href="#" class="active">Home</a>' '<a href="index.html" class="active" aria-current="page">Home</a>') {
    Write-Host "  FIXED desktop nav Home: index.html"; $total++
}
# Mobile nav in index.html
if (R "$base\index.html" '<li><a href="#" class="active">Home</a></li>' '<li><a href="index.html" class="active" aria-current="page">Home</a></li>') {
    Write-Host "  FIXED mobile nav Home: index.html"; $total++
}

# about.html - About active
if (R "$base\about.html" '<a href="#" class="active">About</a>' '<a href="about.html" class="active" aria-current="page">About</a>') {
    Write-Host "  FIXED desktop nav About: about.html"; $total++
}

# contact.html - Contact active
if (R "$base\contact.html" '<a href="#" class="active">Contact</a>' '<a href="contact.html" class="active" aria-current="page">Contact</a>') {
    Write-Host "  FIXED desktop nav Contact: contact.html"; $total++
}

# services/index.html - Services active (uses /services root-relative href)
if (R "$base\services\index.html" '<a href="/services" class="active">Services</a>' '<a href="/services" class="active" aria-current="page">Services</a>') {
    Write-Host "  FIXED desktop nav Services: services/index.html"; $total++
}

# All other service pages - Services active
foreach ($f in $svcFiles) {
    if ($f -notlike '*services\index.html') {
        if (R $f '<a href="index.html" class="active">Services</a>' '<a href="index.html" class="active" aria-current="page">Services</a>') {
            Write-Host "  FIXED Services active: $($f -replace [regex]::Escape($base),'')"; $total++
        }
    }
}

# ======================================================
# FIX C: Service page footers - add missing 4 services to "Our Services" list
# ======================================================
Write-Host "`n=== FIX C: Expand service page footer 'Our Services' list ==="
$shortServiceList = @"
                <li><a href="/services/alarmresponses">Alarm Responses</a></li>
                <li><a href="/services/eventsecurity">Event Security</a></li>
                <li><a href="/services/constructionsitesecurity">Construction Sites</a></li>
                <li><a href="/services/commercialsitesecurity">Commercial Site</a></li>
                <li><a href="/services/manufacturingwarehousingsecurity">Manufacturing & Warehousing</a></li>
            </ul>
"@
$fullServiceList = @"
                <li><a href="/services/alarmresponses">Alarm Responses</a></li>
                <li><a href="/services/eventsecurity">Event Security</a></li>
                <li><a href="/services/constructionsitesecurity">Construction Sites</a></li>
                <li><a href="/services/commercialsitesecurity">Commercial Site</a></li>
                <li><a href="/services/manufacturingwarehousingsecurity">Manufacturing & Warehousing</a></li>
                <li><a href="/services/facilitymanagementservices">Facility Management</a></li>
                <li><a href="/services/cleaningservices">Cleaning Services</a></li>
                <li><a href="/services/securecarparkservices">Secure Car Park</a></li>
                <li><a href="/services/maintenanceservices">Maintenance Services</a></li>
            </ul>
"@

foreach ($f in $svcFiles) {
    if (R $f $shortServiceList $fullServiceList) {
        Write-Host "  FIXED footer services: $($f -replace [regex]::Escape($base),'')"; $total++
    }
}

# ======================================================
# FIX D: Service page footer Quick Links "Work with us" -> "Apply Online"
# ======================================================
Write-Host "`n=== FIX D: Footer Quick Links label consistency ==="
foreach ($f in $svcFiles) {
    if (R $f '<a href="/apply-online">Work with us</a>' '<a href="/apply-online">Apply Online</a>') {
        Write-Host "  FIXED footer Apply Online: $($f -replace [regex]::Escape($base),'')"; $total++
    }
}

# ======================================================
# FIX E: Remove unused fonts.googleapis.com preconnect from all pages
# ======================================================
Write-Host "`n=== FIX E: Remove unused Google Fonts preconnect ==="
foreach ($f in $allFiles) {
    if (R $f '<link rel="preconnect" href="https://fonts.googleapis.com">' '') {
        Write-Host "  FIXED removed fonts preconnect: $($f -replace [regex]::Escape($base),'')"; $total++
    }
    # Also remove fonts.gstatic.com preconnect if present
    R $f '<link rel="preconnect" href="https://fonts.gstatic.com">' '' | Out-Null
    R $f '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>' '' | Out-Null
}

# ======================================================
# FIX F: Remove Slick Carousel CSS from non-index pages
# ======================================================
Write-Host "`n=== FIX F: Remove Slick CSS from non-slider pages ==="
$slickCss1 = '<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>'
$slickCss2 = '<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick-theme.css"/>'
# Remove from all non-index pages
$nonSliderPages = @($svcFiles) + @("$base\about.html","$base\contact.html","$base\apply-online.html")
foreach ($f in $nonSliderPages) {
    $c = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
    $before = $c
    $c = $c.Replace($slickCss1, '').Replace($slickCss2, '')
    if ($c -ne $before) {
        [System.IO.File]::WriteAllText($f, $c, [System.Text.Encoding]::UTF8)
        Write-Host "  FIXED removed Slick CSS: $($f -replace [regex]::Escape($base),'')"; $total++
    }
}

# ======================================================
# FIX G: Fix about.html viewport meta (remove non-standard attrs)
# ======================================================
Write-Host "`n=== FIX G: Fix about.html viewport meta ==="
if (R "$base\about.html" '<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">' '<meta name="viewport" content="width=device-width, initial-scale=1.0">') {
    Write-Host "  FIXED about.html viewport"; $total++
}

# ======================================================
# FIX H: Fix contact.html meta description (93 chars -> 150 chars)
# ======================================================
Write-Host "`n=== FIX H: Expand contact.html meta description ==="
$oldDesc = '<meta name="description" content="Contact Broadsafe Services for security enquiries, quotes, and 24/7 support across Australia.">'
$newDesc = '<meta name="description" content="Contact Broadsafe Services for security enquiries and quotes. Reach our 24/7 team by phone on 03 7064 8292 or submit an enquiry online. Serving all of Australia.">'
if (R "$base\contact.html" $oldDesc $newDesc) {
    Write-Host "  FIXED contact.html meta description ($($newDesc.Length) chars)"; $total++
}
# Also fix OG and Twitter description
if (R "$base\contact.html" '<meta property="og:description" content="Contact Broadsafe Services for security enquiries, quotes, and 24/7 support across Australia.">' '<meta property="og:description" content="Contact Broadsafe Services for security enquiries and quotes. Reach our 24/7 team by phone on 03 7064 8292. Serving all of Australia.">') {
    Write-Host "  FIXED contact.html og:description"; $total++
}
if (R "$base\contact.html" '<meta name="twitter:description" content="Contact Broadsafe Services for security enquiries, quotes, and 24/7 support across Australia.">' '<meta name="twitter:description" content="Contact Broadsafe Services for security enquiries and quotes. Reach our 24/7 team by phone on 03 7064 8292. Serving all of Australia.">') {
    Write-Host "  FIXED contact.html twitter:description"; $total++
}

# ======================================================
# FIX I: Fix index.html hero "services" CTA link (no .html extension)
# ======================================================
Write-Host "`n=== FIX I: Fix index.html hero 'Our Services' button href ==="
if (R "$base\index.html" '<a href="services" class="cta-button">Our Services</a>' '<a href="services/index.html" class="cta-button">Our Services</a>') {
    Write-Host "  FIXED: index.html hero services link"; $total++
}

# ======================================================
# FIX J: Remove the redundant initMobileMenu DOMContentLoaded listener from second script block
# (the first script block already sets up mobile menu correctly with window.__mobileNavInitialized guard)
# Only remove the redundant 'active' class handler from initMobileMenu, not the whole function
# ======================================================
Write-Host "`n=== FIX J: Fix duplicate mobile menu listener (active vs is-open class conflict) ==="
# The second script block's initMobileMenu uses 'active' class which has no CSS rule
# The first block uses 'is-open' which is properly styled
# Fix: remove the redundant initMobileMenu call and add a guard to prevent double-registration
# This affects the shared responsive JS file
$responsiveJs = "$base\assets\js\responsive.js"
if (Test-Path $responsiveJs) {
    $c = [System.IO.File]::ReadAllText($responsiveJs, [System.Text.Encoding]::UTF8)
    $before = $c
    # Wrap initMobileMenu with a guard check
    $c = $c.Replace(
        'function initMobileMenu() {',
        'function initMobileMenu() { if (window.__mobileNavInitialized) { return; }'
    )
    if ($c -ne $before) {
        [System.IO.File]::WriteAllText($responsiveJs, $c, [System.Text.Encoding]::UTF8)
        Write-Host "  FIXED responsive.js initMobileMenu guard"; $total++
    } else {
        Write-Host "  SKIP responsive.js (pattern not found or already fixed)"
    }
}

# ======================================================
# FIX K: Add aria-label to footer nav sections
# ======================================================
Write-Host "`n=== FIX K: Add aria-label to sitemap.xml link in all footers ==="
# Replace the quick links footer section to add aria-label to footer nav
foreach ($f in $allFiles) {
    if (R $f '<li><a href="sitemap.xml">Sitemap</a></li>' '<li><a href="sitemap.xml" aria-label="View XML Sitemap">Sitemap</a></li>') {
        Write-Host "  FIXED sitemap footer link: $($f -replace [regex]::Escape($base),'')"; $total++
    }
}

Write-Host "`n=== Total changes: $total ==="
Write-Host "Done."
