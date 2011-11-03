package Net::Braintree::Util;
use strict;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(to_instance_array flatten is_hashref is_arrayref hash_to_query_string equal_arrays difference_arrays validate_id);
our @EXPORT_OK = qw();

sub flatten {
  my($hash, $namespace) = @_;
  my %flat_hash = ();
  while(my ($key, $value) = each(%$hash)) {
    if(is_hashref($value)) {
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
  my ($first, $second) = @_;
  return 0 unless @$first == @$second;
  for (my $i = 0; $i < @$first; $i++) {
    return 0 if $first->[$i] ne $second->[$i];
  }
  return 1;
}

sub difference_arrays {
  my ($array1, $array2) = @_;
  my @diff;
  foreach my $element (@$array1) {
    push(@diff, $element) unless $element ~~ $array2;
  }
  return \@diff;
}

sub hash_to_query_string {
  my $query = URI::Query -> new(flatten(shift));
  return $query->stringify();
}

sub to_instance_array {
  my ($attrs, $class) = @_;
  my @result = ();
  if(ref $attrs ne "ARRAY") {
    push(@result, $class->new($attrs));
  } else {
    for(@$attrs) {
      push(@result, $class->new($_));
    }
  }
  return \@result;
}
sub trim {
  my $string = shift;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

sub validate_id {
  my $id = shift;
  return 0 if(!defined($id) || trim($id) eq "");
  return 1;
}

1;
