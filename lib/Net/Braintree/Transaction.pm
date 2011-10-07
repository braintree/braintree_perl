package Net::Braintree::Transaction;
use Net::Braintree::Transaction::CreatedUsing;
use Net::Braintree::Transaction::Source;
use Net::Braintree::Transaction::Status;
use Net::Braintree::Transaction::Type;

use Moose;
extends "Net::Braintree::ResultObject";
my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  $meta->add_attribute('subscription', is => 'rw');
  $self->subscription(Net::Braintree::Subscription->new($attributes->{subscription})) if ref($attributes->{subscription}) eq 'HASH';
  delete($attributes->{subscription});
  $self->set_attributes_from_hash($self, $attributes);
}

sub sale {
  my ($class, $params) = @_;
  $class->create($params, 'sale');
}

sub credit {
  my ($class, $params) = @_;
  $class->create($params, 'credit');
}

sub submit_for_settlement {
  my ($class, $id) = @_;
  $class->gateway->transaction->submit_for_settlement($id);
}

sub void {
  my ($class, $id) = @_;
  $class->gateway->transaction->void($id);
}

sub refund {
  my ($class, $id, $amount) = @_;
  my $params = {};
  $params->{'amount'} = $amount if $amount;
  $class->gateway->transaction->refund($id, $params);
}

sub create {
  my ($class, $params, $type) = @_;
  $params->{'type'} = $type;
  $class->gateway->transaction->create($params);
}

sub find {
  my ($class, $id) = @_;
  $class->gateway->transaction->find($id);
}

sub search {
  my ($class, $block) = @_;
  $class->gateway->transaction->search($block);
}

sub all {
  my $class = shift;
  $class->gateway->transaction->all;
}

sub clone_transaction {
  my ($class, $id, $params) = @_;
  $class->gateway->transaction->clone_transaction($id, $params);
}

sub gateway {
  Net::Braintree->configuration->gateway;
}

1;
