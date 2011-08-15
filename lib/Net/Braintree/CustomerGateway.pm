package Net::Braintree::CustomerGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params customer_signature);
use Net::Braintree::Result;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, customer_signature);
  $self->_make_request("/customers/", 'post', { customer => $params });
}

sub find {
  my ($self, $id) = @_;
  $self->_make_request("/customers/$id", 'get', undef)->customer;
}

sub delete {
  my ($self, $id) = @_;
  $self->_make_request("/customers/$id", "delete", undef);
}

sub update {
  my ($self, $id, $params) = @_;
  confess "ArgumentError" unless verify_params($params, customer_signature);
  $self->_make_request("/customers/$id", 'put', {customer => $params});
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}


1;

