$base = 'C:\Users\user\OneDrive\Documents\Broadsafe web data'

$checks = @(
    @{ Label="A. USAGE comments in alarmresponses"; Path="$base\services\alarmresponses.html"; Pattern="USAGE:"; PresenceIs="BAD" }
    @{ Label="B. href=# active in index.html";      Path="$base\index.html";                  Pattern='href="#" class="active"'; PresenceIs="BAD" }
    @{ Label="   aria-current in index.html";        Path="$base\index.html";                  Pattern='aria-current';            PresenceIs="GOOD" }
    @{ Label="C. Maintenance Services in svc footer";Path="$base\services\alarmresponses.html";Pattern='Maintenance Services';   PresenceIs="GOOD" }
    @{ Label="D. Work with us in svc footer";        Path="$base\services\alarmresponses.html";Pattern='Work with us';           PresenceIs="BAD" }
    @{ Label="E. fonts.googleapis preconnect";       Path="$base\services\alarmresponses.html";Pattern='fonts.googleapis.com';  PresenceIs="BAD" }
    @{ Label="F. Slick CSS in about.html";           Path="$base\about.html";                  Pattern='slick-carousel';         PresenceIs="BAD" }
    @{ Label="G. maximum-scale in about.html";       Path="$base\about.html";                  Pattern='maximum-scale';          PresenceIs="BAD" }
    @{ Label="H. contact desc expanded";             Path="$base\contact.html";                Pattern='enquiries and quotes';   PresenceIs="GOOD" }
    @{ Label="I. index.html hero CTA fixed";         Path="$base\index.html";                  Pattern='href="services/index.html"';PresenceIs="GOOD" }
)

foreach ($c in $checks) {
    $found = Select-String -Path $c.Path -Pattern $c.Pattern -SimpleMatch -List -Quiet
    if ($c.PresenceIs -eq "GOOD") {
        $status = if ($found) { "OK" } else { "MISSING - NOT FIXED" }
    } else {
        $status = if ($found) { "STILL PRESENT - NOT FIXED" } else { "OK - FIXED" }
    }
    Write-Host "$($c.Label): $status"
}
