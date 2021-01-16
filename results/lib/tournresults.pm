package tournresults;
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '0.1';

my $driver   = "SQLite";
my $database = "/root/www/ralphweb/public/chess/roundrobin/tournament.sqlite";
#my $database = "C:/Users/ralph/temp/roundrobin-generator/tournament.sqlite";
my $dsn      = "DBI:$driver:dbname=$database";
my $userid   = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;


get '/results' => sub {
    content_type 'application/json';
    my @rows  = database->quick_select('results',{},{order_by => {asc => 'id'}});
    template 'index.tt', {data => to_json \@rows}, { layout => 'main' };
};

get '/ranking' => sub { 
    my $h .= "<meta charset=\"utf-8\"/><table id=\"ranking\"><tr><th>Name</th><th>Punkte</th></tr>\n";
    my @players = calcresults();
    my @playersf;
    for my $p (@players) {
        my ($score, $player) = split(/\,/, $p);
        push(@playersf, $score / 1000 . ",$player");
        $h .= "<tr><td>" . $player . "</td><td>" . $score / 1000 . "</tr>";
    }
    
    template 'ranking.tt', {ranking => $h};
};

get '/' => sub {
    my $stmt = qq(SELECT DISTINCT(white) FROM results order by white desc;);
    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;
    
    my $stmt2 = qq(SELECT event FROM metadata where id = 1;);
    my $sth2  = $dbh->prepare( $stmt2 );
    my $rv2   = $sth2->execute() or die $DBI::errstr;
    
    my $event = $sth2->fetchrow_array;
    
    my $stmt3 = qq(SELECT img FROM images;);
    my $sth3  = $dbh->prepare( $stmt3 );
    my $rv3   = $sth3->execute() or die $DBI::errstr;
    
    my @images;
    
    while (my @row = $sth3->fetchrow_array()) {
        push(@images, $row[0]) unless $row[0] =~ m/placeholder/;
    }
       
    
    my $cnt  = 0;
    $cnt ++ while (my $row = $sth->fetchrow_array());
    
    template 'result', {cntrows => $cnt / 2, event => $event, images => [@images]};
};


sub calcresults {
    my $cnt;
    my @players;
    my @ranking;

    my $stmt = qq(SELECT DISTINCT(white) FROM results order by white desc;);
    my $sth  = $dbh->prepare( $stmt );
    my $rv   = $sth->execute() or die $DBI::errstr;

    while (my $row = $sth->fetchrow_array()) {
        push(@players, $row);
    }
    

    for my $p (@players) {
        my $sum  = 0;    
        my $stmt = qq(select result from results where white = '$p' ORDER BY result DESC;);
        my $sth  = $dbh->prepare( $stmt );
        my $rv   = $sth->execute() or die $DBI::errstr;

        while (my $row = $sth->fetchrow_array()) {
              $sum++ if $row eq '1-0';
              $sum = $sum + 0.5 if $row =~ m/remis/;
        }
        
        $stmt = qq(select result from results where black = '$p' ORDER BY result DESC;);
        $sth  = $dbh->prepare( $stmt );
        $rv   = $sth->execute() or die $DBI::errstr;

        while (my $row = $sth->fetchrow_array()) {
              $sum++ if $row eq '0-1';
              $sum = $sum + 0.5 if $row =~ m/remis/;
              $cnt++;
        }

        $sum = sprintf("%07d", $sum * 1000);
        
        push(@ranking, $sum . ",$p") unless $p eq "BYE";
        
    }
    
    return reverse sort @ranking;

    $dbh->disconnect();
    
}

true;
