package Net::Braintree::CreditCardGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params credit_card_signature);
use Net::Braintree::Util qw(validate_id);
use Net::Braintree::Result;
use Try::Tiny;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, credit_card_signature);
  $self->_make_request("/payment_methods/", "post", {credit_card => $params});
}

sub delete {
  my ($self, $token) = @_;
  $self->_make_request("/payment_methods/credit_card/$token", "delete", undef);
}

sub update {
  my ($self, $token, $params) = @_;
  confess "ArgumentError" unless verify_params($params, credit_card_signature);
  $self->_make_request("/payment_methods/credit_card/$token", "put", {credit_card => $params});
}

sub find {
  my ($self, $token) = @_;
  confess "NotFoundError" unless validate_id($token);
  $self->_make_request("/payment_methods/credit_card/$token", "get", undef)->credit_card;
}

sub from_nonce {
  my ($self, $nonce) = @_;
  confess "NotFoundError" unless validate_id($nonce);

  try {
    return $self->_make_request("/payment_methods/from_nonce/$nonce", "get", undef)->credit_card;
  } catch {
    confess "Payment method with nonce $nonce locked, consumed or not found";
  }
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

__PACKAGE__->meta->make_immutable;
1;
