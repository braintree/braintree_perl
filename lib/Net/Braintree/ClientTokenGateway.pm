package Net::Braintree::ClientTokenGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params client_token_signature_with_customer_id client_token_signature_without_customer_id);
use Net::Braintree::Result;
use URI;

has 'gateway' => (is => 'ro');

sub generate {
  my ($self, $params) = @_;
  if ($params) {
    confess "ArgumentError" unless $self->_conditionally_verify_params($params);
    $params = {client_token => $params};
  }
  my $result = $self->_make_request("/client_token", 'post', $params);
  $result->{"response"}->{"client_token"}->{"value"};
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  Net::Braintree::Result->new(response => $response);
}

sub _conditionally_verify_params {
  my ($self, $params) = @_;

  if (exists $params->{"customer_id"}) {
    verify_params($params, client_token_signature_with_customer_id);
  } else {
    verify_params($params, client_token_signature_without_customer_id);
  };
}

1;
