use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::CreditCardNumbers::CardTypeIndicators;
use Net::Braintree::ErrorCodes::Transaction;
use Net::Braintree::CreditCardDefaults;
use Net::Braintree::Test;

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
    is($result->transaction->voice_referral_number, undef);
  }
};

subtest "Fraud rejections" => sub {
  my $result = Net::Braintree::Transaction->sale({
      amount => "5.00",
      credit_card => {
        number => "4000111111111511",
        expiration_date => "05/16"
      }
  });
  not_ok $result->is_success;
  is($result->message, "Gateway Rejected: fraud");
  is($result->transaction->gateway_rejection_reason, "fraud");
};

subtest "Processor declined rejection" => sub {
  my $result = Net::Braintree::Transaction->sale({
      amount => "2001.00",
      credit_card => {
        number => "4111111111111111",
        expiration_date => "05/16"
      }
  });
  not_ok $result->is_success;
  is($result->message, "Insufficient Funds");
  is($result->transaction->processor_response_code, "2001");
  is($result->transaction->processor_response_text, "Insufficient Funds");
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

subtest "billing_address_id" => sub {
  my $customer_result = Net::Braintree::Customer->create();
  my $address_result = Net::Braintree::Address->create({
      customer_id => $customer_result->customer->id,
      first_name => 'Jenna',
    });
  my $result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    customer_id => $customer_result->customer->id,
    billing_address_id => $address_result->address->id,
    credit_card => {
      number => "5431111111111111",
      expiration_date => "05/12"
    },
  });
  ok $result->is_success;
  is $result->transaction->billing_details->first_name, "Jenna";
};

subtest "Service Fee" => sub {
  subtest "can create a transaction" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      merchant_account_id => "sandbox_sub_merchant_account",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      },
      service_fee_amount => "10.00"
    });
    ok $result->is_success;
    is($result->transaction->service_fee_amount, "10.00");
  };

  subtest "master merchant account does not support service fee" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      merchant_account_id => "sandbox_credit_card",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      },
      service_fee_amount => "10.00"
    });
    not_ok $result->is_success;
    my $expected_error_code = Net::Braintree::ErrorCodes::Transaction::ServiceFeeAmountNotAllowedOnMasterMerchantAccount;
    is($result->errors->for("transaction")->on("service_fee_amount")->[0]->code, $expected_error_code);
  };

  subtest "sub merchant account requires service fee" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      merchant_account_id => "sandbox_sub_merchant_account",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      }
    });
    not_ok $result->is_success;
    my $expected_error_code = Net::Braintree::ErrorCodes::Transaction::SubMerchantAccountRequiresServiceFeeAmount;
    is($result->errors->for("transaction")->on("merchant_account_id")->[0]->code, $expected_error_code);
  };

  subtest "not allowed on credits" => sub {
    my $result = Net::Braintree::Transaction->credit({
      amount => "50.00",
      merchant_account_id => "sandbox_sub_merchant_account",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      },
      service_fee_amount => "10.00"
    });
    not_ok $result->is_success;
    my $expected_error_code = Net::Braintree::ErrorCodes::Transaction::ServiceFeeIsNotAllowedOnCredits;
    is($result->errors->for("transaction")->on("base")->[0]->code, $expected_error_code);
  };
};

subtest "create with hold in escrow" => sub {
  subtest "can successfully create new transcation with hold in escrow option" => sub {
    my $result = Net::Braintree::Transaction->sale({
        amount => "50.00",
        merchant_account_id => "sandbox_sub_merchant_account",
        credit_card => {
          number => "5431111111111111",
          expiration_date => "05/12"
        },
        service_fee_amount => "10.00",
        options => {
          hold_in_escrow => 'true'
        }
    });
    ok $result->is_success;
    is($result->transaction->escrow_status, Net::Braintree::Transaction::EscrowStatus::HoldPending);
  };

  subtest "fails to create new transaction with hold in escrow if merchant account is not submerchant"  => sub {
    my $result = Net::Braintree::Transaction->sale({
        amount => "50.00",
        merchant_account_id => "sandbox_credit_card",
        credit_card => {
          number => "5431111111111111",
          expiration_date => "05/12"
        },
        service_fee_amount => "10.00",
        options => {
          hold_in_escrow => 'true'
        }
    });
    not_ok $result->is_success;
    is($result->errors->for("transaction")->on("base")->[0]->code,
      Net::Braintree::ErrorCodes::Transaction::CannotHoldInEscrow
    );
  }
};

subtest "Hold for escrow"  => sub {
  subtest "can hold a submerchant's authorized transaction for escrow" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      merchant_account_id => "sandbox_sub_merchant_account",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      },
      service_fee_amount => "10.00"
    });
    my $hold_result = Net::Braintree::Transaction->hold_in_escrow($result->transaction->id);
    ok $hold_result->is_success;
    is($hold_result->transaction->escrow_status, Net::Braintree::Transaction::EscrowStatus::HoldPending);
  };
  subtest "fails with an error when holding non submerchant account transactions for error" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      merchant_account_id => "sandbox_credit_card",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      }
    });
    my $hold_result = Net::Braintree::Transaction->hold_in_escrow($result->transaction->id);
    not_ok $hold_result->is_success;
    is($hold_result->errors->for("transaction")->on("base")->[0]->code,
      Net::Braintree::ErrorCodes::Transaction::CannotHoldInEscrow
    );
  };
};

subtest "Submit For Release" => sub {
  subtest "can submit a escrowed transaction for release" => sub {
    my $response = create_escrowed_transaction();
    my $result = Net::Braintree::Transaction->release_from_escrow($response->transaction->id);
    ok $result->is_success;
    is($result->transaction->escrow_status,
      Net::Braintree::Transaction::EscrowStatus::ReleasePending
    );
  };

  subtest "cannot submit non-escrowed transaction for release" => sub {
    my $sale = Net::Braintree::Transaction->sale({
      amount => "50.00",
      merchant_account_id => "sandbox_credit_card",
      credit_card => {
        number => "5431111111111111",
        expiration_date => "05/12"
      }
    });
    my $result = Net::Braintree::Transaction->release_from_escrow($sale->transaction->id);
    not_ok $result->is_success;
    is($result->errors->for("transaction")->on("base")->[0]->code,
      Net::Braintree::ErrorCodes::Transaction::CannotReleaseFromEscrow
    );
  };
};

subtest "Cancel Release" => sub {
  subtest "can cancel release for a transaction which has been submitted" => sub {
    my $escrow = create_escrowed_transaction();
    my $submit = Net::Braintree::Transaction->release_from_escrow($escrow->transaction->id);
    my $result = Net::Braintree::Transaction->cancel_release($submit->transaction->id);
    ok $result->is_success;
    is($result->transaction->escrow_status, Net::Braintree::Transaction::EscrowStatus::Held);
  };

  subtest "cannot cancel release of already released transactions" => sub {
    my $escrowed = create_escrowed_transaction();
    my $result = Net::Braintree::Transaction->cancel_release($escrowed->transaction->id);
    not_ok $result->is_success;
    is($result->errors->for("transaction")->on("base")->[0]->code,
      Net::Braintree::ErrorCodes::Transaction::CannotCancelRelease
    );
  };
};

subtest "Security parameters" => sub {
  my $result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    device_session_id => "abc123",
    fraud_merchant_id => "456",
    credit_card => {
      number => "5431111111111111",
      expiration_date => "05/12"
    },
  });
  ok $result->is_success;
};

subtest "Disbursement Details" => sub {
  subtest "disbursement_details for disbursed transactions" => sub {
    my $result = Net::Braintree::Transaction->find("deposittransaction");

    is $result->transaction->is_disbursed, 1;

    my $disbursement_details = $result->transaction->disbursement_details;
    is $disbursement_details->funds_held, 0;
    is $disbursement_details->disbursement_date, "2013-04-10T00:00:00Z";
    is $disbursement_details->success, 1;
    is $disbursement_details->settlement_amount, "100.00";
    is $disbursement_details->settlement_currency_iso_code, "USD";
    is $disbursement_details->settlement_currency_exchange_rate, "1";
  };

  subtest "is_disbursed false for non-disbursed transactions" => sub {
    my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      credit_card => {
        number => "5431111111111111",
        expiration_date  => "05/12",
      }
    });

    is $result->transaction->is_disbursed, 0;
  };
};

subtest "Disputes" => sub {
  subtest "exposes disputes for disputed transactions" => sub {
    my $result = Net::Braintree::Transaction->find("disputedtransaction");

    ok $result->is_success;

    my $disputes = $result->transaction->disputes;
    my $dispute = shift(@$disputes);

    is $dispute->amount, '250.00';
    is $dispute->received_date, "2014-03-01T00:00:00Z";
    is $dispute->reply_by_date, "2014-03-21T00:00:00Z";
    is $dispute->reason, Net::Braintree::Dispute::Reason::Fraud;
    is $dispute->status, Net::Braintree::Dispute::Status::Won;
    is $dispute->currency_iso_code, "USD";
  };
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

subtest "Venmo Sdk Payment Method Code" => sub {
  my $result = Net::Braintree::Transaction->sale({
      amount => "50.00",
      venmo_sdk_payment_method_code => Net::Braintree::Test::VenmoSdk::VisaPaymentMethodCode
  });

  ok $result->is_success;
  is($result->transaction->credit_card->bin, "411111");
  is($result->transaction->credit_card->last_4, "1111");
};

subtest "Venmo Sdk Session" => sub {
  my $result = Net::Braintree::Transaction->sale({
    amount => "50.00",
    credit_card => {
      number => "5431111111111111",
      expiration_date => "08/2012"
    },
    options => {
      venmo_sdk_session => Net::Braintree::Test::VenmoSdk::Session
    }
  });

  ok $result->is_success;
  ok $result->transaction->credit_card->venmo_sdk;
};


done_testing();
