use strict;
use warnings;
use Time::Local;
use Data::Dumper;
use Date::Parse;

#config
my $max  = 30; #Anzahl Partien pro Spieler, welche runtergeladen werden sollen. Hängt davon ab, wie weit das Turnier zurückliegt
#end config

open(DAT, 'players.txt');
chomp (my @players = <DAT>);
close(DAT);

print "please enter tournament date (format: 31.03.2021)\n";
chomp (my $tourndate = <STDIN>);

print "please enter tournament start (format: 19.30)\n";
chomp (my $tournstart = <STDIN>);

warn "tourndate : $tourndate\n";
warn "tournstart: $tournstart\n";

my @tdate  = split(/\./, $tourndate);
my @tstart = split(/\./, $tournstart);

my $from = str2time("$tdate[1]/$tdate[0]/$tdate[2] $tstart[0]:$tstart[1]:00");
$from    = $from - 2 * 3600;
my $to   = $from + 3 * 3600;

warn "from: $from\n";
warn "to  : $to\n";

print Dumper \@players;

my %games;
my @sortgames;
my ($site, $date, $time, $white, $black, $uxts, $sec, $min, $hours, $day, $month, $year, $result);

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

        if ($i =~ m/\[Result /) {
            my @d = split(/\"/, $i);
            $result = $d[1];
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
            
            warn "Debug site  : $site\n";
            warn "Debug white : $white\n";
            warn "Debug black : $black\n";
            warn "Debug result: $result\n";
            warn "Debug date  : $date\n";
            warn "Debug time  : $time\n";
            warn "hours: $hours\n";
            warn "min  : $min\n";
            warn "sec  : $sec\n";
            warn "year : $year\n";
            warn "month: $month\n";
            warn "day  : $day\n";        
            
            $uxts = timelocal($sec,$min,$hours,$day,$month,$year);
            warn "uxts : $uxts\n";
            
            $games{$site} = "$uxts|$date|$time|$white|$black|$result" if $uxts > $from and $uxts < $to;
            
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
    print "$d[1] $d[2]   $d[5] $d[3] - $d[4]\n";
}

print "$cnt games found in the range from $from to $to ($tourndate, $tournstart)\n";
