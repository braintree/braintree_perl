package Net::Braintree::SubscriptionGateway;

use Moose;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  my $result = $self->_make_request("/subscriptions/", "post", {subscription => $params});
  return $result;
}

sub find {
  my ($self, $id) = @_;
  my $result = $self->_make_request("/subscriptions/$id", "get", undef)->subscription;
}

sub update {
  my ($self, $id, $params) = @_;
  my $result = $self->_make_request("/subscriptions/$id", "put", {subscription => $params});
}

sub cancel {
  my ($self, $id) = @_;
  my $result = $self->_make_request("/subscriptions/$id/cancel", "put", undef);
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}


1;
