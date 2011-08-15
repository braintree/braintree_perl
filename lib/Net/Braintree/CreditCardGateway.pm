package Net::Braintree::CreditCardGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params credit_card_signature);
use Net::Braintree::Result;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, credit_card_signature);
  $self->_make_request("/payment_methods/", "post", {credit_card => $params});
}

sub delete {
  my ($self, $token) = @_;
  $self->_make_request("/payment_methods/$token", "delete", undef);
}

sub update {
  my ($self, $token, $params) = @_;
  confess "ArgumentError" unless verify_params($params, credit_card_signature);
  $self->_make_request("/payment_methods/$token", "put", {credit_card => $params});
}

sub find {
  my ($self, $token) = @_;
  $self->_make_request("/payment_methods/$token", "get", undef)->credit_card;
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

1;
