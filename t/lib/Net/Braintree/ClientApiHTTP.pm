package Net::Braintree::ClientApiHTTP;

use HTTP::Request;
use URI::Escape;
use JSON;

use LWP::UserAgent;
use Moose;
use Carp qw(confess);

has 'config' => (is => 'ro', default => sub {Net::Braintree->configuration });
has 'fingerprint' => (is => 'rw');
has 'shared_customer_identifier' => (is => 'rw');
has 'shared_customer_identifier_type' => (is => 'rw');

sub get_cards {
  my $self = shift;
  return _do_http($self, "GET", $self->config->base_merchant_url .
    '/client_api/v1/payment_methods'.
    '?authorizationFingerprint=' . uri_escape($self->fingerprint) .
    '&sharedCustomerIdentifier=' . $self->shared_customer_identifier .
    '&sharedCustomerIdentifierType=' . $self->shared_customer_identifier_type
  );
};

sub add_card {
  my ($self, $params) = @_;
  return _do_http($self, "POST", $self->config->base_merchant_url . '/client_api/v1/payment_methods/credit_cards', $params)
};

sub add_payment_method {
  my ($self, $params) = @_;
  $params->{'authorizationFingerprint'} = $self->fingerprint;
  $params->{'sharedCustomerIdentifier'} = $self->shared_customer_identifier;
  $params->{'sharedCustomerIdentifierType'} = $self->shared_customer_identifier_type;

  my $payment_method_type;
  if (defined($params->{'paypal_account'})) {
    $payment_method_type = "paypal_accounts";
  } else {
    $payment_method_type = "credit_cards";
  }

  return _do_http(
    $self,
    "POST",
    $self->config->base_merchant_url . '/client_api/v1/payment_methods/' . $payment_method_type,
    $params);
}

sub get_one_time_nonce_for_paypal {
  my $self = shift;
  my $response = _do_http($self, "POST", $self->config->base_merchant_url .
    '/client_api/v1/payment_methods/paypal_accounts.json' .
    '?authorization_fingerprint=' . uri_escape($self->fingerprint) .
    '&shared_customer_identifier=' . $self->shared_customer_identifier .
    '&shared_customer_identifier_type=' . $self->shared_customer_identifier_type .
    '&paypal_account[access_token]=access_token' .
    '&paypal_account[correlation_id]=1223' .
    '&paypal_account[options][validate]=false'
  );

  my $json = decode_json($response->content);
  my @paypalAccounts = @{$json->{"paypalAccounts"}};

  return $paypalAccounts[0]->{'nonce'};
}

sub get_future_payment_nonce_for_paypal {
  my $self = shift;
  my $response = _do_http($self, "POST", $self->config->base_merchant_url .
    '/client_api/v1/payment_methods/paypal_accounts.json' .
    '?authorization_fingerprint=' . uri_escape($self->fingerprint) .
    '&shared_customer_identifier=' . $self->shared_customer_identifier .
    '&shared_customer_identifier_type=' . $self->shared_customer_identifier_type .
    '&paypal_account[consent_code]=consent' .
    '&paypal_account[correlation_id]=1223' .
    '&paypal_account[options][validate]=false'
  );

  my $json = decode_json($response->content);
  my @paypalAccounts = @{$json->{"paypalAccounts"}};

  return $paypalAccounts[0]->{'nonce'};
}

sub get_nonce_for_new_card {
  my ($self, $credit_card_number) = @_;

  my $response = $self->add_card({
    share => "true",
    credit_card => {
      number => $credit_card_number,
      expiration_date => "11/2099"
    }
  });

  return decode_json($response->content)->{"creditCards"}[0]{"nonce"};
}

sub get_nonce_for_new_card_with_params{
  my ($self, $params) = @_;
  my $response = $self->add_card({
    credit_card => $params
  });

  return decode_json($response->content)->{"creditCards"}[0]{"nonce"};
}

sub create_paypal_account {
  my ($self, $params) = @_;
  my $updated_params = {
    authorization_fingerprint => $self->fingerprint,
    paypal_account => $params
  };

  _do_http($self, "POST", $self->config->base_merchant_url . '/client_api/v1/payment_methods/paypal_accounts', $updated_params);
}

sub _do_http {
  my ($self, $method, $url, $params) = @_;
  my $request = HTTP::Request->new($method => $url);

  $params->{authorization_fingerprint} = $self->fingerprint;
  $params->{shared_customer_identifier} = $self->shared_customer_identifier;
  $params->{shared_customer_identifier_type} = $self->shared_customer_identifier_type;
  if ($params) {
    $request->content(encode_json $params);
    $request->content_type("application/json; charset=utf-8");
  }

  $request->header("X-ApiVersion" => $self->config->api_version);
  $request->header("environment" => $self->config->environment);
  $request->header("User-Agent" => "Braintree Perl Module " . Net::Braintree->VERSION);

  my $agent = LWP::UserAgent->new;
  return $agent->request($request);
};

1;
