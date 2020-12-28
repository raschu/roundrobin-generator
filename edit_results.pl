#!/usr/bin/perl

use DBI;
use strict;
use Term::Choose qw(choose);

my $driver   = "SQLite";
my $database = "tournament.sqlite";
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = "";
my $password = "";
my $dbh      = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
my $gameno = $ARGV[0];

print "Spielnummer: " unless defined $gameno;
chomp ($gameno = <>);

updategame($gameno);

sub updategame {
    
    my $gameno = shift;
    my $white;
    my $black;

    my $stmt = qq(SELECT id, no, game, white, black, who_won from who_wons WHERE no = $gameno;);
    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;

    if($rv < 0) {
        print $DBI::errstr;
    }

    while(my @row = $sth->fetchrow_array()) {
        print "ID     = ". $row[0] . "\n";
        print "NO     = ". $row[1] . "\n";
        print "GAME   = ". $row[2] . "\n";
        print "WHITE  = ". $row[3] . "\n";
        print "BLACK  = ". $row[4] . "\n";
        print "who_won = ". $row[5] . "\n\n";
        
        $white = $row[3];
        $black = $row[4];        
        
    }
    
    my $who_won = choose([$white, $black, 'remis'], { prompt => 'Wer hat gewonnen?' }) or exit;    
    my $stmt;
    
    if ($who_won eq $white) {
        print "$white hat gewonnen (weiss)\n";
        $stmt = qq(UPDATE who_wons set who_won = '1-0' WHERE no = $gameno;);
    } elsif ($who_won eq $black) {
        print "$black hat gewonnen (schwarz)\n";
        $stmt = qq(UPDATE who_wons set who_won = '0-1' WHERE no = $gameno;);
    } else {
        print "remis\n";
        $stmt = qq(UPDATE who_wons set who_won = 'remis' WHERE no = $gameno;);
    }

    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;

    $dbh->disconnect();
    
}
