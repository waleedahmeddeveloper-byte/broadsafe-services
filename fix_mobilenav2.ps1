param()
$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'

$svcFiles  = Get-ChildItem "$base\services" -Filter *.html | ForEach-Object { $_.FullName }
$rootPages = @("$base\index.html","$base\about.html","$base\contact.html","$base\apply-online.html")
$allFiles  = $rootPages + $svcFiles

$enc = [System.Text.Encoding]::UTF8
$total = 0

# Root page mobile-nav (relative paths)
$rootMobileNav = @"
    <!-- Mobile Navigation -->
<div class="mobile-nav">
    <button class="mobile-nav-close" aria-label="Close mobile menu">
        <i class="fas fa-times"></i>
    </button>
"@

# Service page mobile-nav (relative paths using ../)
$svcMobileNav = @"
    <!-- Mobile Navigation -->
<div class="mobile-nav">
    <button class="mobile-nav-close" aria-label="Close mobile menu">
        <i class="fas fa-times"></i>
    </button>
"@

foreach ($f in $allFiles) {
    $c = [System.IO.File]::ReadAllText($f, $enc)
    $before = $c
    
    # Try to find the mobile-nav inside <main>
    # The pattern is: <main id="main-content" role="main">\n    <!-- Mobile Navigation -->
    # We need to extract the entire mobile-nav div block
    
    $mainWithNav = '<main id="main-content" role="main">' + "`n" + '    <!-- Mobile Navigation -->'
    $mainOnly    = '<main id="main-content" role="main">'
    
    if (-not $c.Contains($mainWithNav)) {
        Write-Host "SKIP (mobile-nav not inside main): $($f -replace [regex]::Escape($base),'')"
        continue
    }
    
    # Find the full mobile-nav block: from "    <!-- Mobile Navigation -->" to "</div>" 
    # that comes before the next section
    $startMarker = '    <!-- Mobile Navigation -->'
    $endMarker   = '</div>'
    
    $startIdx = $c.IndexOf($startMarker)
    if ($startIdx -lt 0) {
        Write-Host "SKIP (startMarker not found): $($f -replace [regex]::Escape($base),'')"
        continue
    }
    
    # Find the </div> for this mobile-nav (look for </div> followed by blank lines then a section)
    $searchFrom = $startIdx + $startMarker.Length
    $endIdx = $c.IndexOf($endMarker, $searchFrom)
    if ($endIdx -lt 0) {
        Write-Host "SKIP (endMarker not found): $($f -replace [regex]::Escape($base),'')"
        continue
    }
    
    # Extract the full mobile-nav block (including trailing newlines)
    $blockEnd = $endIdx + $endMarker.Length
    # Skip trailing newlines to find the full block
    while ($blockEnd -lt $c.Length -and ($c[$blockEnd] -eq "`n" -or $c[$blockEnd] -eq "`r")) {
        $blockEnd++
    }
    
    $mobileNavBlock = $c.Substring($startIdx, $blockEnd - $startIdx)
    
    # Remove mobile-nav block from inside <main>
    # The <main> tag is immediately before the mobile-nav block
    $c = $c.Replace($mainOnly + "`n" + $mobileNavBlock, $mainOnly + "`n")
    
    # Insert mobile-nav after </header>
    $c = $c.Replace("</header>", "</header>`n`n" + $mobileNavBlock.TrimEnd() + "`n")
    
    if ($c -ne $before) {
        [System.IO.File]::WriteAllText($f, $c, $enc)
        Write-Host "FIXED: $($f -replace [regex]::Escape($base),'')"
        $total++
    } else {
        Write-Host "NO CHANGE: $($f -replace [regex]::Escape($base),'')"
    }
}

Write-Host "`nTotal updated: $total"
