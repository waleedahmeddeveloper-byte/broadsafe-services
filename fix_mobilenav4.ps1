$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc = [System.Text.Encoding]::UTF8

# The mobile-nav block template for service pages (uses ../ relative paths)
# Taken from alarmresponses.html which was correctly fixed
$refFile = "$base\services\alarmresponses.html"
$refContent = [System.IO.File]::ReadAllText($refFile, $enc)

# Extract the mobile-nav block from the reference file (now outside of main, after </header>)
$navStart = $refContent.IndexOf('<!-- Mobile Navigation -->')
$navEnd   = $refContent.IndexOf('</div>', $navStart) + 6
$mobileNavBlock = $refContent.Substring($navStart, $navEnd - $navStart)
Write-Host "Mobile nav block extracted ($($mobileNavBlock.Length) chars):"
Write-Host $mobileNavBlock
Write-Host "---"

# Files that lost their mobile-nav
$files = @(
    'services\mobilepatrols.html',
    'services\staticguarding.html',
    'services\securecarparkservices.html'
)

foreach ($fn in $files) {
    $f = Join-Path $base $fn
    $c = [System.IO.File]::ReadAllText($f, $enc)
    
    # Check mobile-nav is missing
    if ($c.Contains('class="mobile-nav"')) {
        Write-Host "SKIP (mobile-nav already present): $fn"
        continue
    }
    
    # Insert after </header>
    $hdrClose = $c.IndexOf('</header>')
    if ($hdrClose -lt 0) {
        Write-Host "SKIP (no </header>): $fn"
        continue
    }
    
    $insertPos = $hdrClose + 9  # after </header>
    $c = $c.Insert($insertPos, "`n`n" + $mobileNavBlock + "`n")
    
    [System.IO.File]::WriteAllText($f, $c, $enc)
    Write-Host "FIXED: $fn"
}
