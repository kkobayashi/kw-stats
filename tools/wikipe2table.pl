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

my %table;
while(<>){
  tr/\x0A\x0D//d;
  json_to_hash($_, \%table);
}
### %table

my @keys = sort keys %table;
### @keys

printf("\t%s\n", join("\t", @keys));
for(my $i=$from; $i<=$to; $i++){
  printf("%s\t%s\n", $i, join("\t", map{ exists $table{$_}->{$i} ? $table{$_}->{$i} : 0 } @keys));
}

sub json_to_hash{
  my $file = file(shift);
  my $hash = shift;
  ### file : "$file"

  my $data = decode_json($file->slurp);
  ### $data

  foreach my $k (keys %{$data->{daily_views}}){
    $hash->{$data->{title}}->{$k} = $data->{daily_views}->{$k};
  }
}
