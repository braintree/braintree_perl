package Net::Braintree::MerchantAccount::AddressDetails;

use Moo;
extends "Net::Braintree::ResultObject";

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

1;
