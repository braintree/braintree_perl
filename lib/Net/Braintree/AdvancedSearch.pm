package Net::Braintree::AdvancedSearch;

use strict;
use vars qw(@ISA @EXPORT_OK);
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(search_to_hash);

sub search_to_hash {
  my ($self,$search) = @_;
  my $hash = {};
  for my $attribute ($search->meta()->get_all_attributes) {
    my $field = $attribute->name;
    if ($search->$field->active()) {
      $hash->{$field} = $search->$field->criteria;
    }
  }
  return $hash;
}

1;
