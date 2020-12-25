package tournresults;
use Dancer ':syntax';
use Dancer::Plugin::Database;

our $VERSION = '0.1';


get '/results' => sub {
    content_type 'application/json';
    #my @rows  = database->quick_select('results',{result => [ '1-0', '0-1', 'remis' ]},{order_by => {asc => 'id'}});
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


sub calcresults {
    my $driver   = "SQLite";
    my $database = "c:/Users/ralph/temp/roundrobin-generator-master/tournament.sqlite";
    my $dsn      = "DBI:$driver:dbname=$database";
    my $userid   = "";
    my $password = "";
    my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
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
        my $stmt = qq(select result from results where white = '$p';);
        my $sth  = $dbh->prepare( $stmt );
        my $rv   = $sth->execute() or die $DBI::errstr;

        while (my $row = $sth->fetchrow_array()) {
              $sum++ if $row eq '1-0';
              $sum = $sum + 0.5 if $row =~ m/remis/;
        }
        
        $stmt = qq(select result from results where black = '$p';);
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


get '/' => sub {
    template 'result';
};

true;
