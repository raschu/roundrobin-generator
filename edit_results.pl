#!/usr/bin/perl

use DBI;
use strict;
use Term::Choose qw(choose);

my $driver   = "SQLite";
my $database = "/root/www/ralphweb/public/chess/roundrobin/tournament.sqlite";
my $dsn      = "DBI:$driver:dbname=$database";
my $dbh      = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
my $gameno   = shift or die "Usage: edit <game_no>\n";

#print "Spielnummer: " unless defined $gameno;
#chomp ($gameno = <>);

updategame($gameno);

sub updategame {
    
    my $gameno = shift;
    my $white;
    my $black;

    my $stmt = qq(SELECT id, no, game, white, black, result from results WHERE no = $gameno;);
    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;

    if($rv < 0) {
        print $DBI::errstr;
    }

    while(my @row = $sth->fetchrow_array()) {
        #print "ID     = ". $row[0] . "\n";
        #print "NO     = ". $row[1] . "\n";
        #print "GAME   = ". $row[2] . "\n";
        print "-------------------------------------------\n";
        print "$row[3] - $row[4] ($row[5])\n";
        print "-------------------------------------------\n";
        
        $white = $row[3];
        $black = $row[4];        
        
    }
    
    my $who_won = choose([$white, $black, 'remis'], { prompt => 'Wer hat gewonnen?' }) or exit;    
    my $stmt;
    
    if ($who_won eq $white) {
        print "$white hat gewonnen (weiss)\n";
        $stmt = qq(UPDATE results set result = '1-0' WHERE no = $gameno;);
    } elsif ($who_won eq $black) {
        print "$black hat gewonnen (schwarz)\n";
        $stmt = qq(UPDATE results set result = '0-1' WHERE no = $gameno;);
    } else {
        print "remis\n";
        $stmt = qq(UPDATE results set result = 'remis' WHERE no = $gameno;);
    }

    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;

    $dbh->disconnect();
    
}
