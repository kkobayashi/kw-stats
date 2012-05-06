use strict;
use warnings;
use utf8;
use Path::Class;
use JSON::XS;
use Date::Simple qw/date/;
binmode STDOUT => ":utf8";

my $from = date(shift);
my $to   = date(shift);
### from : "$from"
### to   : "$to"

my %table = map { tr/\x0A\x0D//d; json_to_hash($_) } <>;
### %table

# http://d.hatena.ne.jp/keyword/%E3%82%8A%E3%81%AE -> http://d.hatena.ne.jp/keyword/%3F%3F%3F%3F%3F
my @keys = map { /\?/ ? () : $_ } sort keys %table;
### @keys

printf("\t%s\n", join("\t", @keys));
for(my $i=$from; $i<=$to; $i++){
  printf("%s\t%s\n", $i, join("\t", map{ exists $table{$_}->{$i} ? $table{$_}->{$i} : 0 } @keys));
}

sub json_to_hash{
  my $file = file(shift);
  ### file : "$file"
  my $data = decode_json($file->slurp)->[0];

  my $from  = date $data->{from};
  my $to    = date $data->{to};
  my $count = $data->{refer_count} || $data->{access_count};

  my @dates;
  for(my $i=$from; $i<=$to; $i++){
    push(@dates, $i);
  }

  my %table;
  @table{@dates} = map { $_ ? $_ : 0 } @$count;

  my %d = ($data->{keyword}  => \%table);
  ### %d
  return %d;
}
