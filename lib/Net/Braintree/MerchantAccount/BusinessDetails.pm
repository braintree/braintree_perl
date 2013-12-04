package Net::Braintree::MerchantAccount::BusinessDetails;
use Net::Braintree::MerchantAccount::AddressDetails;

use Moose;
extends "Net::Braintree::ResultObject";
my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;

  $meta->add_attribute('address_details', is => 'rw');
  $self->address_details(Net::Braintree::MerchantAccount::AddressDetails->new($attributes->{address})) if ref($attributes->{address}) eq 'HASH';
  delete($attributes->{address});

  $self->set_attributes_from_hash($self, $attributes);
}

1;
