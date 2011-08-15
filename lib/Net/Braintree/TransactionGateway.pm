package Net::Braintree::TransactionGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params transaction_signature);

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, transaction_signature);
  $self->_make_request("/transactions/", "post", {transaction => $params});
}

sub find {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id", "get", undef);
}

sub retry_subscription_charge {
  my ($self, $subscription_id, $amount) = @_;
  my $params = {
    subscription_id => $subscription_id,
    amount => $amount,
    type => "sale"
  };

  $self->create($params);
}

sub submit_for_settlement {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id/submit_for_settlement", "put", undef);
}

sub void {
  my ($self, $id) = @_;
  $self->_make_request("/transactions/$id/void", "put", undef);
}

sub refund {
  my ($self, $id, $params) = @_;
  $self->_make_request("/transactions/$id/refund", "post", {transaction => $params});
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

1;
