use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use Web::Scraper;
use List::Util qw/first/;
use List::MoreUtils qw/uniq/;
use Encode;

my $url_bbsmenu = 'http://menu.2ch.net/bbsmenu.html';
my $url_wikipedia_voiceact = 'http://ja.wikipedia.org/wiki/Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E5%A5%B3%E6%80%A7%E5%A3%B0%E5%84%AA';
## my $url_wikipedia_voiceact = 'http://ja.wikipedia.org/wiki/Category:%E6%97%A5%E6%9C%AC%E3%81%AE%E7%94%B7%E6%80%A7%E5%A3%B0%E5%84%AA'; # for men

my $thread_titles = get_2ch_thread_titles($url_bbsmenu);
my @name_list     = get_names_from_wikipedia($url_wikipedia_voiceact);
my $names_regexp  = '(' . join('|', map{$_->{name}} @name_list) . ')';
### $names_regexp

my %url_list;
$url_list{$_->{name}} = $_->{link} foreach @name_list;

print encode("utf8", "$_\t$url_list{$_}\n") foreach uniq ($thread_titles =~ m/$names_regexp/go);

# Get names from WikiPedia
#
sub get_names_from_wikipedia{
  ### get_names_from_wikipedia start
  my $base_uri = shift;
  ### $base_uri
  
  my $uri_list = scraper {
    process '//table[@class="toc plainlinks"]/tr/td/a', 'list[]' => '@href';
    result 'list';
  }->scrape(URI->new($base_uri));
  ### $uri_list

  my @name_list = uniq map{
    sleep 1;  # to avoid dos
    print STDERR "scraping $_ ... \n";
    my $l = scraper {
      process '//div[@id="mw-pages"]//li/a', 'names[]', => { 'name' => ['text', sub {s/ \(.+//;} ], 'link' => '@href' };
      result 'names';
    }->scrape(new URI($_));
    ### $l
    $l ? @$l : ();
  } @$uri_list;
  ### @name_list
  return @name_list;
}

# Get thread titles from 2ch 声優個人 board
#
# cf. monazilla.org::2ちゃんねる開発資料
# http://www.monazilla.org/index.php?e=192
#
sub get_2ch_thread_titles{
  ### get_2ch_thread_titles start
  my $url_bbsmenu = shift;

  ## 1. set up request & user-agent
  my $request = HTTP::Request->new(GET => $url_bbsmenu);
  $request->accept_decodable;    ## gzip-acceptable

  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  $ua->agent("Monazilla/1.00");  ## 2ch-browser convention
  print STDERR "getting " .  $request->uri . " ...\n";

  my $response = $ua->request($request);
  ### response : $response->decoded_content

  ## 2. scrape bbsmenu and find '声優個人' board
  my $board = scraper {
    process 'a', 'board[]' => {
      url  => '@href',
      name => 'TEXT',
    };
  result 'board'; 
  }->scrape($response);
  ### $board
  
  my $va = first { $_->{name} =~ /声優個人/ } @$board;
  ### $va
  
  ## 3 get thread title list
  $request->uri($va->{url} . 'subject.txt');
  print STDERR "getting " .  $request->uri . " ...\n";
  
  $response = $ua->request($request);
  my $decoded_content = decode("shiftjis", $response->decoded_content);
  ### $decoded_content
  return $decoded_content;
}
