package Net::Braintree::UnknownPaymentMethod;
use Moose;
extends 'Net::Braintree::PaymentMethod';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

__PACKAGE__->meta->make_immutable;
1;
