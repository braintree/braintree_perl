package Net::Braintree::WebhookNotification;

use Net::Braintree::WebhookNotification::Kind;
use Moose;

extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;

  if (ref($attributes->{subject}) eq 'HASH' && ref($attributes->{subject}->{subscription}) eq 'HASH') {
    $meta->add_attribute('subscription', is => 'rw');
    $self->subscription(Net::Braintree::Subscription->new($attributes->{subject}->{subscription}));
  }
  delete($attributes->{subject});
  $self->set_attributes_from_hash($self, $attributes);
}

sub parse {
  my ($class, $signature, $payload) = @_;
  $class->gateway->webhook_notification->parse($signature, $payload);
}

sub verify {
  my ($class, $params) = @_;
  $class->gateway->webhook_notification->verify($params);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
