package Net::Braintree::MerchantAccount;

use Moose;
extends "Net::Braintree::ResultObject";
my $meta = __PACKAGE__->meta;

{
  package Net::Braintree::MerchantAccount::Status;

  use constant Active => "active";
  use constant Pending => "pending";
  use constant Suspended => "suspended";
}

sub BUILD {
  my ($self, $attributes) = @_;
  $meta->add_attribute('master_merchant_account', is => 'rw');
  $self->master_merchant_account(Net::Braintree::MerchantAccount->new($attributes->{master_merchant_account})) if ref($attributes->{master_merchant_account}) eq 'HASH';
  delete($attributes->{master_merchant_account});
  $self->set_attributes_from_hash($self, $attributes);
}

sub create {
  my ($class, $params) = @_;
  $class->gateway->merchant_account->create($params);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
