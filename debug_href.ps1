$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'
$enc = [System.Text.Encoding]::UTF8

# Check the exact pattern in cashintransit
$path = "$base\services\cashintransit.html"
$c = [System.IO.File]::ReadAllText($path, $enc)

# Search for all variations of href="#"
$m = [regex]::Matches($c, 'href="#"')
foreach ($hit in $m) {
    $ctx = $c.Substring([Math]::Max(0, $hit.Index - 30), 100)
    Write-Host "Hit at $($hit.Index): [$($ctx -replace '\n',' ')]"
}
