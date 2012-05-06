use strict;
use warnings;
use LWP::UserAgent;
use Encode qw/encode decode/;
use URI::Escape;

my $from = '2011-01-01';
my $to   = '2011-12-31';
my @type = qw(refer_count access_count);

while (my $kw=<>){
  $kw =~ tr/\x0A\x0D//d;
  $kw =~ s/\t.*//;
  ### $kw

  foreach my $t (@type){
    if(! get_kw_json(uri_escape($kw), $from, $to, $t)){
      print STDERR "$kw : keywordstats for UTF-8 failed. Use EUC-JP instead..\n";
      if(! get_kw_json(uri_escape(encode('eucjp', decode('utf8', $kw))), $from, $to, $t)){
        print STDERR "$kw : keywordstats failed.\n";
      }
    }
  }
}

sub get_kw_json{
  my ($kw, $from, $to, $type) = @_;
  my $uri = sprintf("http://d.hatena.ne.jp/api/keywordstats?keyword=%s&from=%s&to=%s&%s=1", $kw, $from, $to, $type);
  ### $uri
  
  my $req = HTTP::Request->new(GET => $uri);
  my $ua  = LWP::UserAgent->new;
  $ua->timeout(5);
  
  print STDERR "getting " .  $req->uri . " ...\n";
  my $res = $ua->request($req);
  ### response : $res->as_string
  sleep 1;

  return 0 if($res->code ne '200');

  open my $ofh, '>', "${kw}.${type}.json";
  print $ofh $res->content;
  close $ofh;

  return 1;
}
