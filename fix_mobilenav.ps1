param()
$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'

$svcFiles  = Get-ChildItem "$base\services" -Filter *.html | ForEach-Object { $_.FullName }
$rootPages = @("$base\index.html","$base\about.html","$base\contact.html","$base\apply-online.html")
$allFiles  = $rootPages + $svcFiles

$enc = [System.Text.Encoding]::UTF8
$total = 0

foreach ($f in $allFiles) {
    $c = [System.IO.File]::ReadAllText($f, $enc)
    
    # Pattern: <main ...>\n    <!-- Mobile Navigation -->\n<div class="mobile-nav">...\n</div>\n\n
    # Capture: (mainOpenWithNewline)(mobileNavBlock)(restOfContent)
    $pattern = '(?s)(<main[^>]*>\s*\n)([ \t]*<!-- Mobile Navigation -->\n<div class="mobile-nav">.*?</div>\n\n)'
    $m = [regex]::Match($c, $pattern)
    
    if ($m.Success) {
        $mainOpen = $m.Groups[1].Value   # e.g. "    <main id="main-content" role="main">\n"
        $mobileNavBlock = $m.Groups[2].Value  # "    <!-- Mobile Navigation -->\n<div class="mobile-nav">...</div>\n\n"
        
        # Remove mobile nav from inside main
        $c = $c.Replace($mainOpen + $mobileNavBlock, $mainOpen)
        
        # Insert mobile nav between </header> and the blank lines before <main>
        # The area after </header> has some blank lines then <main>
        $c = $c.Replace("</header>`n", "</header>`n`n" + $mobileNavBlock)
        
        [System.IO.File]::WriteAllText($f, $c, $enc)
        Write-Host "FIXED: $($f -replace [regex]::Escape($base),'')"
        $total++
    } else {
        # Debug: show context around main
        $idx = $c.IndexOf('<main ')
        if ($idx -ge 0) {
            $ctx = $c.Substring($idx, [Math]::Min(200, $c.Length - $idx))
            Write-Host "SKIP (no mobile-nav inside main): $($f -replace [regex]::Escape($base),'') | Ctx: $($ctx.Substring(0,100))"
        } else {
            Write-Host "SKIP (no <main>): $($f -replace [regex]::Escape($base),'')"
        }
    }
}

Write-Host "`nTotal: $total files updated."
