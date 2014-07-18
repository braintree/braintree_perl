package Net::Braintree::PaymentMethod;
use Moose;
extends 'Net::Braintree::ResultObject';

has token => ( is => 'rw' );

sub create {
  my ($class, $params) = @_;
  $class->gateway->payment_method->create($params);
}

sub delete {
  my ($class, $token) = @_;
  $class->gateway->payment_method->delete($token);
}

sub find {
  my ($class, $token) = @_;
  $class->gateway->payment_method->find($token);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
