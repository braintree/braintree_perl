package Net::Braintree::PayPalAccountGateway;
use Moose;
use Carp qw(confess);

has 'gateway' => (is => 'ro');

sub find {
  my ($self, $token) = @_;
  $self->_make_request("/payment_methods/paypal_account/$token", "get", undef)->paypal_account;
}

sub update {
  my ($self, $token, $params) = @_;
  $self->_make_request(
    "/payment_methods/paypal_account/$token",
    "put",
    {
      paypal_account => $params
    });
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

1;
