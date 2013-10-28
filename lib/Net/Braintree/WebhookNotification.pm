package Net::Braintree::WebhookNotification;

use Net::Braintree::WebhookNotification::Kind;
use Moose;

extends 'Net::Braintree::ResultObject';

my $meta = __PACKAGE__->meta;

sub BUILD {
  my ($self, $attributes) = @_;

  my $wrapper_node = $attributes->{subject};

  if (ref($wrapper_node->{api_error_response}) eq 'HASH') {
    $wrapper_node = $wrapper_node->{api_error_response};
  }

  if (ref($wrapper_node->{subscription}) eq 'HASH') {
    $meta->add_attribute('subscription', is => 'rw');
    $self->subscription(Net::Braintree::Subscription->new($wrapper_node->{subscription}));
  }

  if (ref($wrapper_node->{merchant_account}) eq 'HASH') {
    $meta->add_attribute('merchant_account', is => 'rw');
    $self->merchant_account(Net::Braintree::MerchantAccount->new($wrapper_node->{merchant_account}));
  }

  if (ref($wrapper_node->{transaction}) eq 'HASH') {
    $meta->add_attribute('transaction', is => 'rw');
    $self->transaction(Net::Braintree::Transaction->new($wrapper_node->{transaction}));
  }

  if (ref($wrapper_node->{partner_merchant}) eq 'HASH') {
    $meta->add_attribute('partner_merchant', is => 'rw');
    $self->partner_merchant(Net::Braintree::PartnerMerchant->new($wrapper_node->{partner_merchant}));
  }

  if (ref($wrapper_node->{errors}) eq 'HASH') {
    $meta->add_attribute('errors', is => 'rw');
    $meta->add_attribute('message', is => 'rw');
    $self->errors(Net::Braintree::ValidationErrorCollection->new($wrapper_node->{errors}));
    $self->message($wrapper_node->{message});
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
