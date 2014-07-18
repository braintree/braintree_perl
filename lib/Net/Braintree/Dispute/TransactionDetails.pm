package Net::Braintree::Dispute::TransactionDetails;

use Moose;
extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

1;
