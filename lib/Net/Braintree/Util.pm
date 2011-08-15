package Net::Braintree::Util;
use strict;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(flatten is_hash is_array hash_to_query_string equal_arrays);
our @EXPORT_OK = qw();

sub flatten {
  my($hash, $namespace) = @_;
  my %flat_hash = ();
  while(my ($key, $value) = each(%$hash)) {
    if(is_hash($value)) {
      my $sub_entries = flatten($value, add_namespace($key, $namespace));
      %flat_hash = (%flat_hash, %$sub_entries);
    } else {
      $flat_hash{add_namespace($key, $namespace)} = $value;
    }
  }
  return \%flat_hash;
}

sub add_namespace {
  my ($key, $namespace) = @_;
  return $key unless $namespace;
  return "${namespace}[${key}]";
}

sub is_hash {
  UNIVERSAL::isa(shift, 'HASH');
}

sub is_array {
  UNIVERSAL::isa(shift, 'ARRAY');
}

sub equal_arrays {
  my ($first, $second) = @_;
  return 0 unless @$first == @$second;
  for (my $i = 0; $i < @$first; $i++) {
    return 0 if $first->[$i] ne $second->[$i];
  }
  return 1;
}

sub hash_to_query_string {
  my $query = URI::Query -> new(flatten(shift));
  return $query->stringify();
}
1;
