package Net::Braintree::PayPalDetails;

use Moo;
extends 'Net::Braintree::ResultObject';

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes); 
}

__PACKAGE__->meta->make_immutable;
1;
