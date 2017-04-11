package Net::Braintree::Dispute;
use Net::Braintree::Dispute::TransactionDetails;
use Net::Braintree::Dispute::Status;
use Net::Braintree::Dispute::Reason;

use Moose;
extends 'Net::Braintree::ResultObject';

sub BUILD {
  my ($self, $attributes) = @_;
  my $meta = __PACKAGE__->meta;
  $meta->add_attribute('transaction_details', is => 'rw');
  $self->transaction_details(Net::Braintree::Dispute::TransactionDetails->new($attributes->{transaction})) if ref($attributes->{transaction}) eq 'HASH';
  delete($attributes->{transaction});
  $self->set_attributes_from_hash($self, $attributes);
}

1;
