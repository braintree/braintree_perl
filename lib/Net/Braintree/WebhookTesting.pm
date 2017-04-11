package Net::Braintree::WebhookTesting;

use Moo;


sub sample_notification {
  my ($class, $kind, $id) = @_;

  return $class->gateway->webhook_testing->sample_notification($kind, $id);
}

sub gateway {
  return Net::Braintree->configuration->gateway;
}

1;
