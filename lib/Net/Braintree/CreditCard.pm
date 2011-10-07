package Net::Braintree::CreditCard;
use Net::Braintree::CreditCard::CardType;
use Net::Braintree::CreditCard::Location;

use Moose;
extends 'Net::Braintree::ResultObject';
my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $meta->add_attribute('billing_address', is => 'rw');
  $self->billing_address(Net::Braintree::Address->new($attributes->{billing_address})) if ref($attributes->{billing_address}) eq 'HASH';
  delete($attributes->{billing_address});
  $self->set_attributes_from_hash($self, $attributes);
}

sub create {
  my ($class, $params) = @_;
  $class->gateway->credit_card->create($params);
}

sub delete {
  my ($class, $token) = @_;
  $class->gateway->credit_card->delete($token);
}

sub update {
  my($class, $token, $params) = @_;
  $class->gateway->credit_card->update($token, $params);
}

sub find {
  my ($class, $token) = @_;
  $class->gateway->credit_card->find($token);
}

sub gateway {
  Net::Braintree->configuration->gateway;
}

sub masked_number {
  my $self = shift;
  return $self->bin . "******" . $self->last_4;
}

sub is_default {
  return shift->default;
}

1;
