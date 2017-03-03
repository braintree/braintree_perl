package Net::Braintree::DisbursementDetails;

use Moose;
extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

sub is_valid {
  my $self = shift;
  if (defined($self->disbursement_date)) {
    1;
  } else {
    0;
  }
};

__PACKAGE__->meta->make_immutable;
1;
