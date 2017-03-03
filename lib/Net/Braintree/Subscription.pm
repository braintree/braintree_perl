package Net::Braintree::Subscription;
use Net::Braintree::SubscriptionGateway;
use Net::Braintree::Subscription::Status;

use Moose;
extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;
  my $sub_objects = { 'transactions' => 'Net::Braintree::Transaction'};
  $self->setup_sub_objects($self, $attributes, $sub_objects);
  $self->set_attributes_from_hash($self, $attributes);
}

sub create {
  my ($class, $params) = @_;
  $class->gateway->subscription->create($params);
}

sub find {
  my ($class, $id) = @_;
  $class->gateway->subscription->find($id);
}

sub update {
  my ($class, $id, $params) = @_;
  $class->gateway->subscription->update($id, $params);
}

sub cancel {
  my ($class, $id) = @_;
  $class->gateway->subscription->cancel($id);
}

sub retry_charge {
  my ($class, $subscription_id, $amount) = @_;
  $class->gateway->transaction->retry_subscription_charge($subscription_id, $amount);
}

sub search {
  my($class, $block) = @_;
  $class->gateway->subscription->search($block);
}

sub all {
  my $class = shift;
  $class->gateway->subscription->all;
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

__PACKAGE__->meta->make_immutable;
1;
