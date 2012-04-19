package Net::Braintree::WebhookTesting;

use Moose;

my $meta = __PACKAGE__->meta;

sub sample_notification {
  my ($class, $kind, $id) = @_;
  $class->gateway->webhook_testing->sample_notification($kind, $id);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
