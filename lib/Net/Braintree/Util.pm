package Net::Braintree::Util;

use strict;
use warnings;

use URI::Query;
use Exporter qw(import);

our @EXPORT = qw(to_instance_array flatten is_hashref is_arrayref hash_to_query_string equal_arrays difference_arrays validate_id contains);

sub flatten {
  my($hash, $namespace) = @_;
  my %flat_hash = ();
  while(my ($key, $value) = each(%$hash)) {
    if (is_hashref($value)) {
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

sub is_hashref {
  ref(shift) eq 'HASH';
}

sub is_arrayref {
  ref(shift) eq 'ARRAY';
}

sub equal_arrays {
  # XXX - String equality only (as with other Util functions).
  #       Caveat:  undef eq ""
  my ($first, $second) = @_;
  return 0 unless @$first == @$second;
  for (my $i = 0; $i < @$first; $i++) {
    return 0 if $first->[$i] ne $second->[$i];
  }
  return 1;
}

# difference_arrays AREF1 AREF2
#
# Return elements in AREF1 not in AREF2 (the relative complement of
# AREF2 in AREF1)
sub difference_arrays {
  my ($array1, $array2) = @_;
  my %possibly_overlapping;
  @possibly_overlapping{ @$array2 } = ();
  return [ grep { not exists $possibly_overlapping{$_} } @$array1 ];
}

sub hash_to_query_string {
  my $query = URI::Query -> new(flatten(shift));
  return $query->stringify();
}

sub to_instance_array {
  my ($attrs, $class) = @_;
  $attrs = [$attrs] unless is_arrayref($attrs);
  return [ map { $class->new($_) } @$attrs ];
}

sub trim {
  my $string = shift;
  for ($string) {
    s/^\s+//;
    s/\s+$//;
  }
  return $string;
}

# validate_id ID
#
# False if ID is all blanks, empty, or undef.
sub validate_id {
  my $id = shift;
  return 0 if trim($id) eq "";
  return 1;
}

sub contains {
  # See also List::MoreUtils::any { $_ eq $element } @$array
  my ($element, $array) = @_;
  for (@$array) {
    return 1 if $_ eq $element;
  }
  return 0;
}

1;
