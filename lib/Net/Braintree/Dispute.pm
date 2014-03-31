package Net::Braintree::Dispute;
use Net::Braintree::Dispute::Status;
use Net::Braintree::Dispute::Reason;

use Moose;
extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

1;
