use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::CreditCardNumbers::CardTypeIndicators;
use Net::Braintree::CreditCardDefaults;

my $transaction_params = {
  amount => "50.00",
  credit_card => {
    number => "5431111111111111",
    expiration_date => "05/12"
  }
};

subtest "Successful Transactions" => sub {
  @examples = ("credit", "sale");

  foreach (@examples) {
    my ($method) = $_;
    my $result = Net::Braintree::Transaction->$method($transaction_params);

    ok $result->is_success;
    is($result->message, "", "$method result has errors: " . $result->message);
    is($result->transaction->credit_card->last_4, "1111");
  }
};

subtest "Custom Fields" => sub {
  my $result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    credit_card => {
      number => "5431111111111111",
      expiration_date => "05/12"
    },
    custom_fields => {
      store_me => "please!"
    }
  });
  ok $result->is_success;
  is $result->transaction->custom_fields->store_me, "please!", "stores custom field value";
};

subtest "Submit for Settlement" => sub {

  my $sale = Net::Braintree::Transaction->sale($transaction_params);
  my $result = Net::Braintree::Transaction->submit_for_settlement($sale->transaction->id);

  ok $result->is_success;
  is($result->transaction->amount, "50.00", "settlement amount");
  is($result->transaction->status, "submitted_for_settlement", "transaction submitted for settlement");

};

subtest "Refund" => sub {
  subtest "successful w/ partial refund amount" => sub {
    my $settled = create_settled_transaction($transaction_params);
    my $result  = Net::Braintree::Transaction->refund($settled->transaction->id, "20.00");

    ok $result->is_success;
    is($result->transaction->type, 'credit', 'Refund result type is credit');
    is($result->transaction->amount, "20.00", "refund amount responds correctly");
  };

  subtest "unsuccessful if transaction has not been settled" => sub {
    my $sale       = Net::Braintree::Transaction->sale($transaction_params);
    my $result     = Net::Braintree::Transaction->refund($sale->transaction->id);

    not_ok $result->is_success;
    is($result->message, "Cannot refund a transaction unless it is settled.", "Errors on unsettled transaction");
  };
};

subtest "Void" => sub {
  subtest "successful" => sub {
    my $sale = Net::Braintree::Transaction->sale($transaction_params);
    my $void = Net::Braintree::Transaction->void($sale->transaction->id);

    ok $void->is_success;
    is($void->transaction->id, $sale->transaction->id, "Void tied to sale");
  };

  subtest "unsuccessful" => sub {
    my $settled = create_settled_transaction($transaction_params);
    my $void    = Net::Braintree::Transaction->void($settled->transaction->id);

    not_ok $void->is_success;
    is($void->message, "Transaction can only be voided if status is authorized or submitted_for_settlement.");
  };
};

subtest "Find" => sub {
  subtest "successful" => sub {
    my $sale_result = Net::Braintree::Transaction->sale($transaction_params);
    $find_result = Net::Braintree::Transaction->find($sale_result->transaction->id);
    is $find_result->transaction->id, $sale_result->transaction->id, "should find existing transaction";
    is $find_result->transaction->amount, "50.00", "should find correct amount";
  };

  subtest "unsuccessful" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::Transaction->find('foo') }, "Not Foound");
  };
};

subtest "Options" => sub {
  subtest "submit for settlement" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      credit_card => {
        number => "5431111111111111",
        expiration_date  => "05/12",
      },
      options  => { submit_for_settlement  => 'true'}
    });
    is $result->transaction->status, "submitted_for_settlement", "should have correct status";
  };

  subtest "store_in_vault" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      credit_card => {
        number => "5431111111111111",
        expiration_date  => "05/12",
      },
      customer => {first_name => "Dan", last_name => "Smith"},
      billing => { street_address => "123 45 6" },
      shipping => { street_address => "789 10 11" },
      options  => { store_in_vault  => 'true', add_billing_address_to_payment_method => 'true', store_shipping_address_in_vault => 'true' }
    });

    my $customer_result = Net::Braintree::Customer->find($result->transaction->customer->id);

    like $result->transaction->credit_card->token, qr/[\d\w]{4,}/, "it sets the token";
  };
};

subtest "Create from payment method token" => sub {
  my $sale_result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    credit_card => {
      number => "5431111111111111",
      expiration_date  => "05/12",
    },
    customer => {first_name => "Dan", last_name => "Smith"},
    options  => { store_in_vault  => 'true' }
  });

  my $create_from_token = Net::Braintree::Transaction->sale({customer_id => $sale_result->transaction->customer->id, payment_method_token => $sale_result->transaction->credit_card->token, amount => "10.00"});

  ok $create_from_token->is_success;
  is $create_from_token->transaction->customer->id, $sale_result->transaction->customer->id, "ties sale to existing customer";
  is $create_from_token->transaction->credit_card->token, $sale_result->transaction->credit_card->token, "ties sale to existing customer card";

};

subtest "Clone transaction" => sub {
  my $sale_result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    credit_card => {
      number => "5431111111111111",
      expiration_date  => "05/12",
    },
    customer => {first_name => "Dan"},
    billing => {first_name => "Jim"},
    shipping => {first_name => "John"}
  });

  my $clone_result = Net::Braintree::Transaction->clone_transaction($sale_result->transaction->id, {
      amount => "123.45",
      channel => "MyShoppingCartProvider",
      options => { submit_for_settlement => "false" }
  });
  ok $clone_result->is_success;
  my $clone_transaction = $clone_result->transaction;

  isnt $clone_transaction->id, $sale_result->transaction->id;
  is $clone_transaction->amount, "123.45";
  is $clone_transaction->channel, "MyShoppingCartProvider";
  is $clone_transaction->credit_card->bin, "543111";
  is $clone_transaction->credit_card->expiration_year, "2012";
  is $clone_transaction->credit_card->expiration_month, "05";
  is $clone_transaction->customer->first_name, "Dan";
  is $clone_transaction->billing->first_name, "Jim";
  is $clone_transaction->shipping->first_name, "John";
  is $clone_transaction->status, "authorized";
};


subtest "Clone transaction and submit for settlement" => sub {
  my $sale_result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    credit_card => {
      number => "5431111111111111",
      expiration_date  => "05/12"
    }
  });

  my $clone_result = Net::Braintree::Transaction->clone_transaction($sale_result->transaction->id, {
      amount => "123.45",
      options => { submit_for_settlement => "true" }
  });
  ok $clone_result->is_success;
  my $clone_transaction = $clone_result->transaction;

  is $clone_transaction->status, "submitted_for_settlement";
};

subtest "Clone transaction with validation error" => sub {
  my $credit_result = Net::Braintree::Transaction->credit({
    amount => "50.00",
    credit_card => {
      number => "5431111111111111",
      expiration_date  => "05/12",
    }
  });

  my $clone_result = Net::Braintree::Transaction->clone_transaction($credit_result->transaction->id, {amount => "123.45"});
  my $expected_error_code = 91543;

  not_ok $clone_result->is_success;
  is($clone_result->errors->for("transaction")->on("base")->[0]->code, $expected_error_code);
};

subtest "Recurring" => sub {
  my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      recurring => "true",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      }
  });

  ok $result->is_success;
  is($result->transaction->recurring, 1);
};

subtest "Card Type Indicators" => sub {
  my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      credit_card => {
        number => Net::Braintree::CreditCardNumbers::CardTypeIndicators::Unknown,
        expiration_date => "05/12",
      }
  });

  ok $result->is_success;
  is($result->transaction->credit_card->prepaid, Net::Braintree::CreditCard::Prepaid::Unknown);
  is($result->transaction->credit_card->commercial, Net::Braintree::CreditCard::Commercial::Unknown);
  is($result->transaction->credit_card->debit, Net::Braintree::CreditCard::Debit::Unknown);
  is($result->transaction->credit_card->payroll, Net::Braintree::CreditCard::Payroll::Unknown);
  is($result->transaction->credit_card->healthcare, Net::Braintree::CreditCard::Healthcare::Unknown);
  is($result->transaction->credit_card->durbin_regulated, Net::Braintree::CreditCard::DurbinRegulated::Unknown);
  is($result->transaction->credit_card->issuing_bank, Net::Braintree::CreditCard::IssuingBank::Unknown);
  is($result->transaction->credit_card->country_of_issuance, Net::Braintree::CreditCard::CountryOfIssuance::Unknown);
};


done_testing();
