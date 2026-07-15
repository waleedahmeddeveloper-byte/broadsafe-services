$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc = [System.Text.Encoding]::UTF8
$total = 0

# These 3 service pages have a "Header" comment between <main> and <div class="mobile-nav">
$files = @(
    'services\mobilepatrols.html',
    'services\staticguarding.html',
    'services\securecarparkservices.html'
)

foreach ($fn in $files) {
    $f = Join-Path $base $fn
    $c = [System.IO.File]::ReadAllText($f, $enc)
    $before = $c

    # Find start of the comment that precedes mobile-nav
    $startMarker = '    <!-- Mobile Navigation -->'
    $endMarker   = '</div>'
    $mainTag     = '<main id="main-content" role="main">'

    $navCommentIdx = $c.IndexOf($startMarker)
    if ($navCommentIdx -lt 0) { Write-Host "SKIP (no nav comment): $fn"; continue }

    # Walk back from navCommentIdx to find the start of the "Header" comment before it
    # The block to remove from inside main starts just after <main>
    $mainIdx = $c.IndexOf($mainTag)
    if ($mainIdx -lt 0) { Write-Host "SKIP (no main): $fn"; continue }

    $afterMain = $mainIdx + $mainTag.Length   # position right after ">"

    # Find end of the mobile-nav div (the </div> after mobile-nav content)
    $endIdx = $c.IndexOf($endMarker, $navCommentIdx + $startMarker.Length)
    if ($endIdx -lt 0) { Write-Host "SKIP (no end): $fn"; continue }

    $blockEnd = $endIdx + $endMarker.Length
    # Skip trailing newlines
    while ($blockEnd -lt $c.Length -and ($c[$blockEnd] -eq "`n" -or $c[$blockEnd] -eq "`r")) {
        $blockEnd++
    }

    # The block to move = everything from afterMain (exclusive of \n) to blockEnd
    # afterMain points at the char right after >, typically a newline
    # The block is from $afterMain to $blockEnd
    $blockToMove = $c.Substring($afterMain, $blockEnd - $afterMain)

    # Remove that block from inside main, replace with just a newline
    $c = $c.Remove($afterMain, $blockEnd - $afterMain)

    # Insert mobile nav block after </header>
    # We need only the actual mobile-nav comment + div, not the "Header" comment
    $navBlockOnly = $c.Substring($c.IndexOf($startMarker, $c.IndexOf('</header>')), 0) # placeholder

    # Build just the mobile-nav portion (from <!-- Mobile Navigation --> to </div>)
    # Re-find in original $before
    $navStart = $before.IndexOf($startMarker)
    $navEnd   = $before.IndexOf($endMarker, $navStart + $startMarker.Length) + $endMarker.Length
    $mobileNavBlock = $before.Substring($navStart, $navEnd - $navStart).TrimEnd()

    # Insert after </header>
    $c = $c.Replace("</header>`n", "</header>`n`n" + $mobileNavBlock + "`n`n")

    if ($c -ne $before) {
        [System.IO.File]::WriteAllText($f, $c, $enc)
        Write-Host "FIXED: $fn"
        $total++
    } else {
        Write-Host "NO CHANGE: $fn"
    }
}

Write-Host "`nTotal: $total"
