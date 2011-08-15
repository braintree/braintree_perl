package Net::Braintree::TransparentRedirectGateway;
use Moose;

use Carp qw(confess);
use DateTime;
use Net::Braintree::Util;
use Net::Braintree::Digest qw(hexdigest);
use Net::Braintree::HTTP;
use Net::Braintree::Result;
use Net::Braintree::TransparentRedirect::QueryString;

has 'gateway' => (is => 'ro');

sub confirm {
  my ($self, $query_string) = @_;
  my $qs = Net::Braintree::TransparentRedirect::QueryString->new(config => $self->gateway->config);
  $qs->validate($query_string);
  my $params = $qs->parse($query_string);
  $self->_make_request("/transparent_redirect_requests/". $params->{id} . "/confirm", "post", undef);
}

sub transaction_data {
  my ($self, $params) = @_;
  $self->requires($params, qw(redirect_url transaction));
  $self->requires_type($params);
  $params->{'kind'} = 'create_transaction';
  return $self->data_string($params);
}

sub create_customer_data {
  my ($self, $params) = @_;
  $self->requires($params, qw(redirect_url));
  $params->{'kind'} = 'create_customer';
  return $self -> data_string($params);
}

sub update_customer_data {
  my ($self, $params) = @_;
  $self->requires($params, qw(redirect_url customer_id));
  $params->{'kind'} = 'update_customer';
  return $self->data_string($params);
}

sub create_credit_card_data {
  my ($self, $params) = @_;
  $self->requires($params, qw(redirect_url credit_card));
  confess "ArgumentError: credit card must be associated with a customer" unless $params->{'credit_card'}->{'customer_id'};
  $params->{'kind'} = 'create_payment_method';
  return $self->data_string($params);
}

sub update_credit_card_data {
  my ($self, $params) = @_;
  $self->requires($params, qw(redirect_url payment_method_token));
  $params->{'kind'} = 'update_payment_method';
  return $self->data_string($params);
}

sub url {
  return shift->gateway->config->base_merchant_url . "/transparent_redirect_requests";
}

sub requires {
  my ($self, $params, @required) = @_;
  foreach my $field (@required) {
    confess "ArgumentError:  $field is required" unless $params->{$field}
  }
}

sub requires_type {
  my ($self, $params) = @_;
  confess "ArgumentError: Transaction type is required" unless $params->{'transaction'}->{'type'} ;
  if ($params->{'transaction'}->{'type'} ne 'sale' &&
    $params->{'transaction'}->{'type'} ne 'credit') {
    confess "ArgumentError: Transaction type must be credit or sale";
  }
}

sub time_string {
  my $dt = DateTime->now;
  return $dt -> strftime("%Y%m%d%H%M%S");
}

sub data_string {
  my ($self, $params) = @_;
  $params->{'api_version'} = '2';
  $params->{'time'}        = time_string;
  $params->{'public_key'}  = $self->gateway->config->public_key;
  return $self->build_tr_data($params);
}

sub build_tr_data {
  my ($self, $params) = @_;
  my $query = hash_to_query_string($params);
  my $tr_hash = hexdigest($self->gateway->config->private_key, $query);
  return "$tr_hash|$query";
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

1;
