package Net::Braintree::CreditCardVerification;
use Net::Braintree::CreditCard;
use Net::Braintree::CreditCard::CardType;

use Moose;

has 'avs_error_response_code' => (is => 'ro');
has 'avs_postal_code_response_code' => (is => 'ro');
has 'avs_street_address_response_code' => (is => 'ro');
has 'cvv_response_code' => (is => 'ro');
has 'merchant_account_id' => (is => 'ro');
has 'processor_response_code' => (is => 'ro');
has 'processor_response_text' => (is => 'ro');
has 'id' => (is => 'ro');
has 'gateway_rejection_reason' => (is => 'ro');
has 'credit_card' => (is => 'ro');
has 'billing' => (is => 'ro');
has 'created_at' => (is => 'ro');
has 'status' => (is => 'ro');

sub search {
  my ($class, $block) = @_;
  $class->gateway->credit_card_verification->search($block);
}

sub all {
  my $class = shift;
  $class->gateway->credit_card_verification->all;
}

sub find {
  my ($class, $token) = @_;
  $class->gateway->credit_card_verification->find($token);
}

sub gateway {
  Net::Braintree->configuration->gateway;
}


__PACKAGE__->meta->make_immutable;
1;
