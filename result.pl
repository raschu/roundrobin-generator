use strict;
use warnings;
use DBI;
use Data::Dumper;

my $driver   = "SQLite";
my $database = "tournament.sqlite";
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
my $cnt;
my @players;
my %ranking;

my $stmt = qq(SELECT DISTINCT(white) FROM results;);
my $sth  = $dbh->prepare( $stmt );
my $rv   = $sth->execute() or die $DBI::errstr;

while (my $row = $sth->fetchrow_array()) {
      push(@players, $row);
}

for my $p (@players) {
    my $sum;    
    my $stmt = qq(select result from results where white = '$p';);
    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;

    while (my $row = $sth->fetchrow_array()) {
          $sum++ if $row eq '1-0';
          $sum = $sum + 0.5 if $row =~ m/0.5/;
    }
    
    $stmt = qq(select result from results where black = '$p';);
    $sth  = $dbh->prepare( $stmt );
    $rv   = $sth->execute() or die $DBI::errstr;

    while (my $row = $sth->fetchrow_array()) {
          $sum++ if $row eq '0-1';
          $sum = $sum + 0.5 if $row =~ m/0.5/;
          $cnt++;
    }    
    
    $ranking{$p} = $sum;
}

foreach my $name (reverse sort { $ranking{$a} <=> $ranking{$b} or $a cmp $b } keys %ranking) {
    printf "%-20s %s\n", $name, $ranking{$name};
}

print "------------------------\n"; 
print "sum                  $cnt\n";

$dbh->disconnect();
