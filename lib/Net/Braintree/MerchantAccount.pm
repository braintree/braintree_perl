package Net::Braintree::MerchantAccount;
use Net::Braintree::MerchantAccount::IndividualDetails;
use Net::Braintree::MerchantAccount::AddressDetails;
use Net::Braintree::MerchantAccount::BusinessDetails;
use Net::Braintree::MerchantAccount::FundingDetails;

use Moose;
extends "Net::Braintree::ResultObject";
my $meta = __PACKAGE__->meta;

{
  package Net::Braintree::MerchantAccount::Status;

  use constant Active => "active";
  use constant Pending => "pending";
  use constant Suspended => "suspended";
}

{
  package Net::Braintree::MerchantAccount::FundingDestination;

  use constant Bank => "bank";
  use constant Email => "email";
  use constant MobilePhone => "mobile_phone";
}

sub BUILD {
  my ($self, $attributes) = @_;
  $meta->add_attribute('master_merchant_account', is => 'rw');
  $self->master_merchant_account(Net::Braintree::MerchantAccount->new($attributes->{master_merchant_account})) if ref($attributes->{master_merchant_account}) eq 'HASH';
  delete($attributes->{master_merchant_account});

  $meta->add_attribute('individual_details', is => 'rw');
  $self->individual_details(Net::Braintree::MerchantAccount::IndividualDetails->new($attributes->{individual})) if ref($attributes->{individual}) eq 'HASH';
  delete($attributes->{individual});

  $meta->add_attribute('business_details', is => 'rw');
  $self->business_details(Net::Braintree::MerchantAccount::BusinessDetails->new($attributes->{business})) if ref($attributes->{business}) eq 'HASH';
  delete($attributes->{business});

  $meta->add_attribute('funding_details', is => 'rw');
  $self->funding_details(Net::Braintree::MerchantAccount::FundingDetails->new($attributes->{funding})) if ref($attributes->{funding}) eq 'HASH';
  delete($attributes->{funding});

  $self->set_attributes_from_hash($self, $attributes);
}

sub create {
  my ($class, $params) = @_;
  $class->gateway->merchant_account->create($params);
}

sub update {
  my ($class, $merchant_account_id, $params) = @_;
  $class->gateway->merchant_account->update($merchant_account_id, $params);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
