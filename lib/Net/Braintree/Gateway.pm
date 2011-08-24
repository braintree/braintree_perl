package Net::Braintree::Gateway;

use Net::Braintree::AddressGateway;
use Net::Braintree::CreditCardGateway;
use Net::Braintree::CustomerGateway;
use Net::Braintree::SettlementBatchSummaryGateway;
use Net::Braintree::SubscriptionGateway;
use Net::Braintree::TransactionGateway;
use Net::Braintree::TransparentRedirectGateway;

use Moose;

has 'config' => (is => 'ro');

has 'address' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::AddressGateway->new(gateway => $self);
});

has 'credit_card' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::CreditCardGateway->new(gateway => $self);
});

has 'customer' => (is => 'ro', lazy => 1, default => sub {
  my $self = shift;
  Net::Braintree::CustomerGateway->new(gateway => $self);
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

sub http {
  Net::Braintree::HTTP->new(config => shift->config);
}

1;
