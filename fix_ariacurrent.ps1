$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc = [System.Text.Encoding]::UTF8
$total = 0

$files = @(
    'services\mobilepatrols.html',
    'services\staticguarding.html',
    'services\securecarparkservices.html'
)

foreach ($fn in $files) {
    $f = Join-Path $base $fn
    $c = [System.IO.File]::ReadAllText($f, $enc)
    $lines = $c -split "`n"
    $found = $lines | Where-Object { $_ -match 'class="active"' }
    if ($found) {
        Write-Host "${fn}:"
        $found | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "${fn}: no active class found"
    }
    
    # Fix: add aria-current to any active nav link that's missing it
    $before = $c
    $c = $c -replace '(class="active")(?! aria-current)', '$1 aria-current="page"'
    if ($c -ne $before) {
        [System.IO.File]::WriteAllText($f, $c, $enc)
        Write-Host "  -> FIXED aria-current"
        $total++
    }
}
Write-Host "Done. Total: $total"
