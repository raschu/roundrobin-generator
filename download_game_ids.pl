use strict;
use warnings;
use Time::Local;

#config
my @players = qw(bishopnator Tor_aehh_Schach wean11 PerlHacker muggel ok63 Fierolocchio);
my $from    = '1615990538';
my $to      = '1616012217';
my $max     = 30;
#end config

my %games;
my @sortgames;
my ($site, $date, $time, $white, $black, $uxts, $sec, $min, $hours, $day, $month, $year);

for my $p (@players) {
    my @d = qx(curl https://lichess.org/api/games/user/$p -G -d max=$max);

    for my $i (@d) {
        chomp $i;
        
        if ($i =~ m/\[Site/) {
            my @d = split(/\"/, $i);
            $site = $d[1];
        }
        
        if ($i =~ m/\[White /) {
            my @d = split(/\"/, $i);
            $white = $d[1];
        }
        
        if ($i =~ m/\[Black /) {
            my @d = split(/\"/, $i);
            $black = $d[1];
        }       
        
        if ($i =~ m/\[UTCDate/) {
            my @d = split(/\"/, $i);
            $date = $d[1];
            ($year, $month, $day) = split(/\./, $date);
            $month--;
        }
        
        if ($i =~ m/\[UTCTime/) {
            my @d = split(/\"/, $i);
            $time = $d[1];
            ($hours, $min, $sec) = split(/\:/, $time);
            
            warn "Debug site : $site\n";
            warn "Debug white: $white\n";
            warn "Debug black: $black\n";
            warn "Debug date : $date\n";
            warn "Debug time : $time\n";
            warn "hours: $hours\n";
            warn "min  : $min\n";
            warn "sec  : $sec\n";
            warn "year : $year\n";
            warn "month: $month\n";
            warn "day  : $day\n";        
            
            $uxts = timelocal($sec,$min,$hours,$day,$month,$year);
            warn "uxts : $uxts\n";
            
            $games{$site} = "$uxts|$date|$time|$white|$black" if $uxts > $from and $uxts < $to;
            
            warn "-----------------\n";
        }         
    }
}

#warn Dumper \%games;

for my $k (keys %games) {
    push(@sortgames, "$games{$k}|$k");
}

my $cnt = 0;
for (sort @sortgames) {
    my @d = split(/\|/, $_);
    $cnt++;
    print "$d[5]|$d[1]|$d[2]|$d[3]|$d[4]\n";
}

print "$cnt games found in the range from $from to $to\n";
