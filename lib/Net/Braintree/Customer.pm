package Net::Braintree::Customer;
use Moose;
extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  my $sub_objects = {
    credit_cards => "Net::Braintree::CreditCard",
    addresses => "Net::Braintree::Address"
  };

  $self->setup_sub_objects($self, $attributes, $sub_objects);
  $self->set_attributes_from_hash($self, $attributes);
}

sub create {
  my ($class, $params) = @_;
  $class->gateway->customer->create($params);
}

sub find {
  my($class, $id) = @_;
  $class->gateway->customer->find($id);
}

sub delete {
  my ($class, $id) = @_;
  $class->gateway->customer->delete($id);
}

sub update {
  my ($class, $id, $params) = @_;
  $class->gateway->customer->update($id, $params);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
