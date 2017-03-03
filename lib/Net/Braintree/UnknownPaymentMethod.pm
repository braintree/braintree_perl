package Net::Braintree::UnknownPaymentMethod;
use Moo;
extends 'Net::Braintree::PaymentMethod';

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

__PACKAGE__->meta->make_immutable;
1;
