use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

my $customer_create = Net::Braintree::Customer->create({first_name => "Walter", last_name => "Weatherman"});

subtest "Create with S2S" => sub {
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => "5431111111111111",
    expiration_date => "12/15"
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  ok $result->is_success, "result returns no errors";
  is $result->credit_card->last_4, "1111", "sets credit card number";
  ok $result->credit_card->unique_number_identifier =~ /\A\w{32}\z/;
};

subtest "Failure Cases" => sub {
  my $result = Net::Braintree::CreditCard->create({customer_id => "dne",
    number => '5431111111111111',
    expiration_date => "12/15"});

  not_ok $result->is_success;
  is $result->message, "Customer ID is invalid.", "Customer not found";
};

subtest "Create with Fail on Duplicate Payment Method" => sub {
  my $customer_id = $customer_create->customer->id;

  my $credit_card_params =  {
    customer_id => $customer_id,
    number => "5431111111111111",
    expiration_date => "12/15",
    options => {
      fail_on_duplicate_payment_method => 1
    }
  };

  Net::Braintree::CreditCard->create($credit_card_params);
  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  not_ok $result->is_success;
  is $result->message, "Duplicate card exists in the vault.";
};

subtest "Create with Billing Address" => sub {
  my $credit_card_params =  {
    customer_id => $customer_create->customer->id,
    number => "5431111111111111",
    expiration_date => "12/15",
    billing_address => {
      first_name => "Barry",
      last_name => "Zuckercorn",
      street_address => "123 Fake St",
      locality => "Chicago",
      region => "Illinois",
      postal_code => "60647",
      country_code_alpha2 => "US"
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  ok $result->is_success, "result returns no errors";
  is $result->credit_card->billing_address->first_name, "Barry", "sets address attributes";
  is $result->credit_card->billing_address->last_name, "Zuckercorn";
  is $result->credit_card->billing_address->street_address, "123 Fake St";
};

subtest "delete" => sub {

  subtest "existing card" => sub {
    my $card = Net::Braintree::CreditCard->create({number => "5431111111111111", expiration_date => "12/15", customer_id => $customer_create->customer->id});
    my $result = Net::Braintree::CreditCard->delete($card->credit_card->token);
    ok $result->is_success;
  };

  subtest "not found" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::CreditCard->delete("notAToken") });
  };

};

subtest "find" => sub {
  subtest "card exists" => sub {
    my $card = Net::Braintree::CreditCard->create({number => "5431111111111111", expiration_date => "12/15", customer_id => $customer_create->customer->id});
    my $result = Net::Braintree::CreditCard->find($card->credit_card->token);
    is $result->last_4, "1111";
    is $result->expiration_month, "12";
  };

  subtest "card does not exist" => sub { should_throw("NotFoundError", sub { Net::Braintree::CreditCard->find("notAToken") }); };
};

subtest "update" => sub {

  subtest "existing card" => sub {
    my $card = Net::Braintree::CreditCard->create({number => "5431111111111111", expiration_date => "12/15", customer_id => $customer_create->customer->id});
    my $result = Net::Braintree::CreditCard->update($card->credit_card->token, {
      number => "4009348888881881",
      expiration_date => "03/15"
    });

    ok $result->is_success, "returns no errors";
    is $result->credit_card->last_4, "1881", "sets new credit card number";
  };

  subtest "not found" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::CreditCard->update("notAToken", {number => "1234567890123456"})});
  };

};

subtest "prepaid" => sub {
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => "4500600000000061",
    expiration_date => "12/15",
    options => {
      verify_card => 1
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  is $result->credit_card->prepaid, Net::Braintree::CreditCard::Prepaid::Yes
};


subtest "card with negative card type indentifiers" => sub {
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => "4111111111111111",
    expiration_date => "12/15",
    options => {
      verify_card => 1
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  is $result->credit_card->prepaid, Net::Braintree::CreditCard::Prepaid::No
};


subtest "card without card type identifiers" => sub {
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => "5555555555554444",
    expiration_date => "12/15",
    options => {
      verify_card => 1
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  is $result->credit_card->prepaid, Net::Braintree::CreditCard::Prepaid::Unknown
};

done_testing();
