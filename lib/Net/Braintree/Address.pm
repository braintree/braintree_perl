package Net::Braintree::Address;
use Moo;
extends 'Net::Braintree::ResultObject';

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

sub create {
  my($class, $params) = @_;
  $class->gateway->address->create($params);
}

sub find {
  my ($class, $customer_id, $address_id) = @_;
  $class->gateway->address->find($customer_id, $address_id);
}

sub update {
  my ($class, $customer_id, $address_id, $params) = @_;
  $class->gateway->address->update($customer_id, $address_id, $params);
}

sub delete {
  my ($class, $customer_id, $address_id) = @_;
  $class->gateway->address->delete($customer_id, $address_id);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

sub full_name {
  my $self = shift;
  return $self->first_name . " " . $self->last_name
}

__PACKAGE__->meta->make_immutable;
1;
