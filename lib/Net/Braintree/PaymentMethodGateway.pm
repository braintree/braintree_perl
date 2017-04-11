package Net::Braintree::PaymentMethodGateway;
use Moo;
use Carp qw(confess);

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  $self->_make_request("/payment_methods", 'post', {payment_method => $params});
}

sub update {
  my ($self, $token, $params) = @_;
  $self->_make_request("/payment_methods/any/" . $token, "put", {payment_method => $params});
}

sub delete {
  my ($self, $token) = @_;
  $self->_make_request("/payment_methods/any/" . $token, 'delete');
}

sub find {
  my ($self, $token) = @_;
  if (!defined($token) || Net::Braintree::Util::trim($token) eq "") {
    confess "NotFoundError";
  }

  my $response = $self->_make_request("/payment_methods/any/" . $token, 'get');
  return $response->payment_method;
}

sub _make_request {
  my ($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);

  return Net::Braintree::Result->new(response => $response);
}

1;
