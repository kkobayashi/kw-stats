use strict;
use warnings;
use LWP::UserAgent;
use URI::Escape;

# cf. Wikipedia article traffic statistics http://stats.grok.se/

my $year = 2011;

while (my $kw=<>){
  $kw =~ tr/\x0A\x0D//d;
  $kw =~ s/\t.*//;

  for my $m (1 .. 12){
    my $uri = sprintf("http://stats.grok.se/json/ja/%s%02d/%s", $year, $m, uri_escape($kw));
    my $req = HTTP::Request->new(GET => $uri);
    my $ua  = LWP::UserAgent->new;
    $ua->timeout(5);
  
    print STDERR "getting " .  $req->uri . " ...\n";
    my $res = $ua->request($req);
    ### response : $res->as_string
    print STDERR "getting json failed : $uri" if $res->code ne '200';

    sleep 1;

    open my $ofh, '>', sprintf("%s.%s%02d.json", uri_escape($kw), $year, $m);
    print $ofh $res->content;
    close $ofh;
  }
}
