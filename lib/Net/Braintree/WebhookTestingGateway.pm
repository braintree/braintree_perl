package Net::Braintree::WebhookTestingGateway;

use MIME::Base64;
use POSIX qw(strftime);
use Net::Braintree::Digest qw(hexdigest);
use Moose;

has 'gateway' => (is => 'ro');

sub sample_notification {
  my ($self, $kind, $id) = @_;
  my $sample_xml = $self->_sample_xml($kind, $id);
  my $payload = encode_base64($sample_xml);
  my $signature = $self->gateway->config->public_key . "|" . hexdigest($self->gateway->config->private_key, $payload);

  return ($signature, $payload);
}

sub _sample_xml {
  my ($self, $kind, $id) = @_;
  my $subscription_xml = $self->_subscription_sample_xml($id);
  my $timestamp = strftime("%Y-%m-%dT%H:%M:%SZ", gmtime());

  return <<XML
    <notification>
      <timestamp type="datetime">$timestamp</timestamp>
      <kind>$kind</kind>
      <subject>$subscription_xml</subject>
    </notification>
XML
}

sub _subscription_sample_xml {
  my ($self, $id) = @_;

  return <<XML
    <subscription>
      <id>$id</id>
      <transactions type="array">
      </transactions>
      <add_ons type="array">
      </add_ons>
      <discounts type="array">
      </discounts>
    </subscription>
XML
}

1;
