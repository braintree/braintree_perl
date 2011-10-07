use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

subtest "gets the right transaction data" => sub {
  my $tr_params = {
    redirect_url => "http://example.com",
    transaction => {type => "sale", amount => "50.00"}
  };

  my $transaction_params = {
    transaction => {
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/2012"
      }
    }
  };

  my $tr_data = Net::Braintree::TransparentRedirect->transaction_data($tr_params);
  my $query_string_response = simulate_form_post_for_tr($tr_data, $transaction_params);
  my $result = Net::Braintree::TransparentRedirect->confirm($query_string_response);

  ok($result->is_success);
  my $transaction = $result->transaction;
  is ($transaction->type, "sale", "type should be sale");
  is ($transaction->amount, "50.00", "amount should be 50.00");
};


subtest "create customer data" => sub {
  my $customer_create_tr_params = {redirect_url => "http://example.com"};
  my $customer_params = {customer => {first_name => "Sally", last_name  => "Sitwell"}};

  my $tr_data = Net::Braintree::TransparentRedirect->create_customer_data($customer_create_tr_params);
  my $query_string_response = simulate_form_post_for_tr($tr_data, $customer_params);
  my $result = Net::Braintree::TransparentRedirect->confirm($query_string_response);

  ok $result->is_success;
  isnt($result->customer->id, undef);
  is($result->customer->first_name, "Sally", "First name is accepted");
  is($result->customer->last_name, "Sitwell", "Last name is accepted");
};


subtest "update customer" => sub {
  my $customer = Net::Braintree::Customer->new();
  my $create = $customer->create({first_name => "Gob", last_name => "Bluth"});
  my $customer_update_tr_params = {redirect_url => "http://example.com", customer_id => $create->customer->id};
  my $customer_update_params = {customer => {first_name => "Steve", last_name => "Holt"}};

  my $tr_data = Net::Braintree::TransparentRedirect->update_customer_data($customer_update_tr_params);
  my $query_string_response = simulate_form_post_for_tr($tr_data, $customer_update_params);
  my $result = Net::Braintree::TransparentRedirect->confirm($query_string_response);

  ok $result->is_success;
  is $result->customer->first_name, "Steve", "changes customer first name";
  is $result->customer->last_name, "Holt", "changes customer last name";
};

my $customer = Net::Braintree::Customer->new();
my $create_customer = $customer->create({first_name => "Judge", last_name => "Reinhold"});

subtest "credit card data" => sub {
  my $credit_card_create_tr_params = { redirect_url => "http://example.com", credit_card => {customer_id => $create_customer->customer->id }};
  my $credit_card_create_params = {credit_card => {number => "5431111111111111", expiration_date => "05/12" }};

  my $tr_data = Net::Braintree::TransparentRedirect->create_credit_card_data($credit_card_create_tr_params);
  my $query_string_response = simulate_form_post_for_tr($tr_data, $credit_card_create_params);
  my $result = Net::Braintree::TransparentRedirect->confirm($query_string_response);

  subtest "results" => sub {
    ok $result->is_success;
    is $result->credit_card->last_4, "1111", "sets card #";
    is $result->credit_card->expiration_month, "05", "sets expiration date";
  };

  subtest "update existing" => sub {
    my $credit_card_update_tr_params = { redirect_url => "http://example.com", payment_method_token => $result->credit_card->token };
    my $credit_card_create_params = {credit_card => {number => "4009348888881881", expiration_date => "09/2013"}};

    my $update_tr_data = Net::Braintree::TransparentRedirect->update_credit_card_data($credit_card_update_tr_params);
    my $update_response = simulate_form_post_for_tr($update_tr_data, $credit_card_create_params);
    my $update_result = Net::Braintree::TransparentRedirect->confirm($update_response);

    ok $update_result->is_success;
    is $update_result->credit_card->last_4, "1881", "Card number was updated";
    is $update_result->credit_card->expiration_month, "09", "Card exp month was updated";
  };
};


done_testing();
