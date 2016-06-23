package Net::Braintree::TestHelper;
use lib qw(lib t/lib);
use Net::Braintree::ClientToken;
use Net::Braintree::ClientApiHTTP;
use Try::Tiny;
use Test::More;
use HTTP::Request;
use LWP::UserAgent;
use MIME::Base64;
use Net::Braintree::Util;
use DateTime::Format::Strptime;
use CGI;
use JSON;

use Net::Braintree;
Net::Braintree->configuration->environment("integration");

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS );
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(create_escrowed_transaction create_settled_transaction not_ok should_throw should_throw_containing simulate_form_post_for_tr make_subscription_past_due NON_DEFAULT_MERCHANT_ACCOUNT_ID);
our @EXPORT_OK = qw();

use constant NON_DEFAULT_MERCHANT_ACCOUNT_ID => "sandbox_credit_card_non_default";

use constant TRIALLESS_PLAN_ID => "integration_trialless_plan";

sub three_d_secure_merchant_account_id {
  "three_d_secure_merchant_account";
}

sub not_ok {
  my($predicate, $message) = @_;
  ok(!$predicate, $message);
}

sub should_throw {
  my($exception, $block, $message) = @_;
  try {
    $block->();
    fail($message . " [Should have thrown $exception]");
  } catch {
    like($_ , qr/^$exception.*/, $message);
  }
}

sub should_throw_containing {
  my($exception, $block, $message) = @_;
  try {
    $block->();
    fail($message . " [Should have thrown $exception]");
  } catch {
    like($_ , qr/.*$exception.*/, $message);
  }
}

sub settle {
  my $transaction_id = shift;
  my $http = Net::Braintree::HTTP->new(config => Net::Braintree->configuration);
  my $response = $http->put("/transactions/" . $transaction_id . "/settle");

  return Net::Braintree::Result->new(response => $response);
}

sub settlement_decline {
  my $transaction_id = shift;
  my $http = Net::Braintree::HTTP->new(config => Net::Braintree->configuration);
  my $response = $http->put("/transactions/" . $transaction_id . "/settlement_decline");

  return Net::Braintree::Result->new(response => $response);
}

sub settlement_pending {
  my $transaction_id = shift;
  my $http = Net::Braintree::HTTP->new(config => Net::Braintree->configuration);
  my $response = $http->put("/transactions/" . $transaction_id . "/settlement_pending");

  return Net::Braintree::Result->new(response => $response);
}

sub create_settled_transaction {
  my ($params) = shift;
  my $sale       = Net::Braintree::Transaction->sale($params);
  my $submit     = Net::Braintree::Transaction->submit_for_settlement($sale->transaction->id);
  my $http       = Net::Braintree::HTTP->new(config => Net::Braintree->configuration);

  return settle($sale->transaction->id);
}

sub create_escrowed_transaction {
  my $sale = Net::Braintree::Transaction->sale({
    amount => "50.00",
    merchant_account_id => "sandbox_sub_merchant_account",
    credit_card => {
      number => "5431111111111111",
      expiration_date => "05/12"
    },
    service_fee_amount => "10.00",
    options => {
      hold_in_escrow => "true"
    }
  });
  my $http       = Net::Braintree::HTTP->new(config => Net::Braintree->configuration);
  my $settlement = $http->put("/transactions/" . $sale->transaction->id . "/settle");
  my $escrow     = $http->put("/transactions/" . $sale->transaction->id . "/escrow");

  return Net::Braintree::Result->new(response => $escrow);
}

sub create_3ds_verification {
  my ($merchant_account_id, $params) = @_;
  my $http = Net::Braintree::HTTP->new(config => Net::Braintree->configuration);
  my $response = $http->post("/three_d_secure/create_verification/$merchant_account_id", {
    three_d_secure_verification => $params
  });
  return $response->{three_d_secure_verification}->{three_d_secure_token};
}

sub simulate_form_post_for_tr {
  my ($tr_string, $form_params) = @_;
  my $escaped_tr_string = CGI::escape($tr_string);
  my $tr_data = {tr_data => $escaped_tr_string, %$form_params};

  my $request = HTTP::Request->new(POST => Net::Braintree->configuration->base_merchant_url .
    "/transparent_redirect_requests");

  $request->content_type("application/x-www-form-urlencoded");
  $request->content(hash_to_query_string($tr_data));

  my $agent = LWP::UserAgent->new;
  my $response = $agent->request($request);
  my @url_and_query = split(/\?/, $response->header("location"), 2);
  return $url_and_query[1];
}

sub make_subscription_past_due {
  my $subscription_id = shift;

  my $request = Net::Braintree->configuration->gateway->http->put(
    "/subscriptions/$subscription_id/make_past_due?days_past_due=1");
}

sub now_in_eastern {
  return DateTime->now(time_zone => "America/New_York")->strftime("%Y-%m-%d");
}

sub parse_datetime {
  my $date_string = shift;
  my $parser = DateTime::Format::Strptime->new(
      pattern => "%F %T"
  );
  my $dt = $parser->parse_datetime($date_string);
}

sub get_new_http_client {
  my $config = Net::Braintree::Configuration->new(environment => "integration");
  my $customer = Net::Braintree::Customer->create()->customer;
  my $raw_client_token = Net::Braintree::TestHelper::generate_decoded_client_token();
  my $client_token = decode_json($raw_client_token);

  my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};
  return Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $authorization_fingerprint,
    shared_customer_identifier => "fake_identifier",
    shared_customer_identifier_type => "testing"
  );
}

sub get_nonce_for_new_card {
  my ($credit_card_number, $customer_id) = @_;

  my $raw_client_token = "";
  if ($customer_id eq '') {
    $raw_client_token = generate_decoded_client_token();
  } else {
    $raw_client_token = generate_decoded_client_token({customer_id => $customer_id});
  }
  my $client_token = decode_json($raw_client_token);
  my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};

  my $config = Net::Braintree::Configuration->new();
  $config->environment("integration");

  my $http = Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $authorization_fingerprint,
    shared_customer_identifier => "fake_identifier",
    shared_customer_identifier_type => "testing"
  );

  return $http->get_nonce_for_new_card($credit_card_number, $customer_id);
}

sub generate_unlocked_nonce {
  my ($credit_card_number, $customer_id) = @_;
  my $raw_client_token = "";
  if (!defined($customer_id) || $customer_id eq '') {
    $raw_client_token = generate_decoded_client_token();
  } else {
    $raw_client_token = generate_decoded_client_token({customer_id => $customer_id});
  }

  my $client_token = decode_json($raw_client_token);

  my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};
  my $config = Net::Braintree::Configuration->new(environment => "integration");
  my $http = Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $authorization_fingerprint,
    shared_customer_identifier => "test-identifier",
    shared_customer_identifier_type => "testing"
  );

  return $http->get_nonce_for_new_card('4111111111111111');
}

sub generate_one_time_paypal_nonce {
  my $customer_id = shift;
  my $raw_client_token = "";
  if (!defined($customer_id) || $customer_id eq '') {
    $raw_client_token = generate_decoded_client_token();
  } else {
    $raw_client_token = generate_decoded_client_token({customer_id => $customer_id});
  }

  my $client_token = decode_json($raw_client_token);

  my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};
  my $config = Net::Braintree::Configuration->new(environment => "integration");
  my $http = Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $authorization_fingerprint,
    shared_customer_identifier => "test-identifier",
    shared_customer_identifier_type => "testing"
  );

  return $http->get_one_time_nonce_for_paypal();
}

sub generate_future_payment_paypal_nonce {
  my $customer_id = shift;
  my $raw_client_token = "";
  if (!defined($customer_id) || $customer_id eq '') {
    $raw_client_token = generate_decoded_client_token();
  } else {
    $raw_client_token = generate_decoded_client_token({customer_id => $customer_id});
  }

  my $client_token = decode_json($raw_client_token);

  my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};
  my $config = Net::Braintree::Configuration->new(environment => "integration");
  my $http = Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $authorization_fingerprint,
    shared_customer_identifier => "test-identifier",
    shared_customer_identifier_type => "testing"
  );

  return $http->get_future_payment_nonce_for_paypal();
}

sub _nonce_from_response {
  my $response = shift;
  my $body = decode_json($response->content);

  if (defined($body->{'paypalAccounts'})) {
    return $body->{'paypalAccounts'}->[0]->{'nonce'};
  } else {
    return $body->{'creditCards'}->[0]->{'nonce'};
  }
}

sub nonce_for_new_payment_method {
  my $params = shift;
  my $raw_client_token = generate_decoded_client_token();
  my $client_token = decode_json($raw_client_token);
  my $config = Net::Braintree::Configuration->new(environment => "integration");
  my $http = Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $client_token->{'authorizationFingerprint'},
    shared_customer_identifier => "fake_identifier",
    shared_customer_identifier_type => "testing"
  );

  my $response = $http->add_payment_method($params);
  return _nonce_from_response($response);
}

sub nonce_for_new_credit_card {
  my $params = shift;
  my $http = get_new_http_client();
  return $http->get_nonce_for_new_card_with_params($params);
}

sub nonce_for_paypal_account {
  my $paypal_account_details = shift;
  my $raw_client_token = generate_decoded_client_token();
  my $client_token = decode_json($raw_client_token);
  my $config = Net::Braintree::Configuration->new(environment => "integration");
  my $http = Net::Braintree::ClientApiHTTP->new(
    config => $config,
    fingerprint => $client_token->{'authorizationFingerprint'}
  );

  my $response = $http->create_paypal_account($paypal_account_details);
  my $body = decode_json($response->content);
  return $body->{'paypalAccounts'}->[0]->{'nonce'};
}

sub generate_decoded_client_token {
  my $params = shift;
  my $encoded_client_token = Net::Braintree::ClientToken->generate($params);
  my $decoded_client_token = decode_base64($encoded_client_token);

  $decoded_client_token;
}

1;
