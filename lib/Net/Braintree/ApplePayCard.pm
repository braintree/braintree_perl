package Net::Braintree::ApplePayCard;
use Net::Braintree::ApplePayCard::CardType;

use Moose;
extends 'Net::Braintree::PaymentMethod';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

sub expiration_date {
  my $self = shift;
  return $self->expiration_month . "/" . $self->expiration_year;
}

sub is_default {
  return shift->default;
}

__PACKAGE__->meta->make_immutable;
1;
