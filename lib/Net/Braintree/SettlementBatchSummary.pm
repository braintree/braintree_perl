package Net::Braintree::SettlementBatchSummary;
use Moo;
extends 'Net::Braintree::ResultObject';

sub BUILD {
  my ($self, $attributes) = @_;
  $self->set_attributes_from_hash($self, $attributes);
}

sub generate {
  my($class, $settlement_date, $group_by_custom_field) = @_;
  $class->gateway->settlement_batch_summary->generate($settlement_date, $group_by_custom_field);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

__PACKAGE__->meta->make_immutable;
1;
