package Net::Braintree::Gateway;

use Net::Braintree::AddressGateway;
use Net::Braintree::ClientTokenGateway;
use Net::Braintree::CreditCardGateway;
use Net::Braintree::CreditCardVerificationGateway;
use Net::Braintree::CustomerGateway;
use Net::Braintree::MerchantAccountGateway;
use Net::Braintree::PaymentMethodGateway;
use Net::Braintree::PayPalAccountGateway;
use Net::Braintree::SettlementBatchSummaryGateway;
use Net::Braintree::SubscriptionGateway;
use Net::Braintree::TransactionGateway;
use Net::Braintree::TransparentRedirectGateway;
use Net::Braintree::WebhookNotificationGateway;
use Net::Braintree::WebhookTestingGateway;

use Moose;

has 'config' => (is => 'ro');

has 'address' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::AddressGateway->new(gateway => $self);
});

has 'client_token' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::ClientTokenGateway->new(gateway => $self);
});

has 'credit_card' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::CreditCardGateway->new(gateway => $self);
});

has 'credit_card_verification' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::CreditCardVerificationGateway->new(gateway => $self);
});

has 'customer' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::CustomerGateway->new(gateway => $self);
});

has 'merchant_account' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::MerchantAccountGateway->new(gateway => $self);
});

has 'payment_method' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::PaymentMethodGateway->new(gateway => $self);
});

has 'paypal_account' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::PayPalAccountGateway->new(gateway => $self);
});

has 'settlement_batch_summary' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::SettlementBatchSummaryGateway->new(gateway => $self);
});

has 'subscription' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::SubscriptionGateway->new(gateway => $self);
});

has 'transaction' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::TransactionGateway->new(gateway => $self);
});

has 'transparent_redirect' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::TransparentRedirectGateway->new(gateway => $self);
});

has 'webhook_notification' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::WebhookNotificationGateway->new(gateway => $self);
});

has 'webhook_testing' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::WebhookTestingGateway->new(gateway => $self);
});

sub http {
  Net::Braintree::HTTP->new(config => shift->config);
}

1;
