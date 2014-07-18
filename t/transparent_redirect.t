use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::Digest qw(hexdigest);
use Net::Braintree::TestHelper;

subtest "validate transaction params" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->transaction_data({redirect_url => "http"})}, "Raises ArgumentError if no type");

  should_throw("ArgumentError: Transaction type must be credit or sale", sub {
    Net::Braintree::TransparentRedirect->transaction_data({redirect_url => "http://www.example.com", transaction => {type => "blah"}})},
    "Raises ArgumentError if type is not credit/sale");

  should_throw("ArgumentError", sub {Net::Braintree::TransparentRedirect->transaction_data({transaction => {type=>"credit"}})}, "raises argument error without redirect_url");
};

subtest "url" => sub {
  is(Net::Braintree::TransparentRedirect->url, (Net::Braintree->configuration->base_merchant_url . "/transparent_redirect_requests"));
};

subtest "confirm raises exception if HTTP Status is not 200" => sub {
  my $query_string_response = "http_status=403";
  should_throw "AuthorizationError", sub { Net::Braintree::TransparentRedirect->confirm($query_string_response) }, "throws exception";
};

subtest "create customer data" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->create_customer_data({})}, "raise ArgumentError if no redirect_url");
  my $tr_hash = {redirect_url => "http://example.com"};
  my $tr_data = Net::Braintree::TransparentRedirect->create_customer_data($tr_hash);
  tr_data_ok($tr_data, qr/api_version=4&kind=create_customer&public_key=integration_public_key&redirect_url=http%3A%2F%2Fexample\.com&time=\d{14,}/);
};

subtest "update customer data" => sub {
  subtest "succesful creation of TR data" => sub {
    my $tr_hash = {redirect_url => "http://example.com", customer_id => 132};
    my $tr_data = Net::Braintree::TransparentRedirect->update_customer_data($tr_hash);
    tr_data_ok($tr_data, qr/api_version=4&customer_id=132&kind=update_customer&public_key=integration_public_key&redirect_url=http%3A%2F%2Fexample\.com&time=\d{14,}/);
  };

  subtest "validate arguments" => sub {
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->update_customer_data({customer_id => 132}) }, "requires redirect_url");
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->update_customer_data({redirect_url => "http://example.com"}) }, "requires customer_id");
  };
};

subtest "create credit card data" => sub {
  subtest "successful creation of data" => sub {
    my $tr_hash = {redirect_url => "http://example.com", credit_card => {customer_id => "543"}};
    my $tr_data = Net::Braintree::TransparentRedirect->create_credit_card_data($tr_hash);
    tr_data_ok($tr_data, qr/api_version=4&credit_card%5Bcustomer_id%5D=543&kind=create_payment_method&public_key=integration_public_key&redirect_url=http%3A%2F%2Fexample\.com&time=\d{14,}/);
  };

  subtest "validate arguments" => sub {
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->create_credit_card_data({credit_card => {customer_id => 132}}) }, "requires redirect_url");
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->create_credit_card_data({redirect_url => "http://example.com"}) }, "required credit card");
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->create_credit_card_data({redirect_url => "http://example.com", credit_card => {}}) });
  };
};

subtest "update credit card data" => sub {
  subtest "successful creation of data" => sub {
    my $tr_hash = {redirect_url => "http://example.com", payment_method_token => "llll", credit_card => {customer_id => "543"}};
    my $tr_data = Net::Braintree::TransparentRedirect->update_credit_card_data($tr_hash);
    tr_data_ok($tr_data, qr/api_version=4&credit_card%5Bcustomer_id%5D=543&kind=update_payment_method&payment_method_token=llll&public_key=integration_public_key&redirect_url=http%3A%2F%2Fexample\.com&time=\d{14,}/);
  };

  subtest "validate arguments" => sub {
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->update_credit_card_data({payment_method_token => "affd"}) }, "requires redirect_url");
    should_throw("ArgumentError", sub { Net::Braintree::TransparentRedirect->update_credit_card_data({redirect_url => "http://example.com"}) }, "requires payment method token");
  };
};

sub tr_data_ok {
  my ($tr_data, $expected_tr_params) = @_;
  my @tr_params = split(/\|/, $tr_data);
  like($tr_params[1], $expected_tr_params, "tr data is similar");
}

done_testing();
