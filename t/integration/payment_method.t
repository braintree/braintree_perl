use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::ErrorCodes;
use Net::Braintree::Nonce;
use Net::Braintree::SandboxValues::CreditCardNumber;
use Net::Braintree::TestHelper;
use Net::Braintree::Test;
use Net::Braintree::Xml;
use Data::GUID;
use JSON;

subtest "Create" => sub {
  subtest "it creates a paypal account method with a future payment nonce" => sub {
    my $nonce = Net::Braintree::TestHelper::generate_future_payment_paypal_nonce('');
    my $customer_result = Net::Braintree::Customer->create();

    ok $customer_result->is_success;
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => $nonce
    });

    ok $payment_method_result->is_success;
    isnt($payment_method_result->paypal_account->token, undef);
    isnt($payment_method_result->paypal_account->image_url, undef);
    is($payment_method_result->paypal_account->meta->name, "Net::Braintree::PayPalAccount");
  };

  subtest "it creates a credit card payment method with a nonce" => sub {
    my $nonce = Net::Braintree::TestHelper::generate_unlocked_nonce();
    my $customer_result = Net::Braintree::Customer->create();

    ok $customer_result->is_success;
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => $nonce
    });

    ok $payment_method_result->is_success;
    isnt($payment_method_result->credit_card->token, undef);
    is($payment_method_result->credit_card->meta->name, "Net::Braintree::CreditCard");
  };

  subtest "create paypal account with one-time nonce fails" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    ok $customer_result->is_success;

    my $nonce = Net::Braintree::TestHelper::generate_one_time_paypal_nonce();
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => $nonce
    });

    isnt($payment_method_result->is_success, 1);
    ok($payment_method_result->errors->for("paypal_account")->on("base")->[0]->code ==
       Net::Braintree::ErrorCodes::AltPay::PayPalAccountCannotVaultOneTimeUsePayPalAccount);
  };

  subtest "create can make default and set token" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    ok $customer_result->is_success;
    my $credit_card_result = Net::Braintree::CreditCard->create({
      customer_id => $customer_result->customer->id,
      number => "5105105105105100",
      expiration_date => "05/12"
    });

    ok $credit_card_result->is_success;
    my $nonce = Net::Braintree::TestHelper::generate_unlocked_nonce();
    my $token = Data::GUID->new->as_string;
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => $nonce,
      token => $token,
      options => {
        make_default => true
      }
    });

    ok $payment_method_result->is_success;
    ok $payment_method_result->payment_method->default;
    ok($token eq $payment_method_result->payment_method->token);
  };

  subtest "it doesn't return an error if credit card options are present for a paypal nonce" => sub {
    my $customer = Net::Braintree::Customer->create()->customer;
    my $original_token = "paypal-account-" . int(rand(10000));
    my $nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({
      consent_code => "consent-code",
      token => $original_token
    });

    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      options => {
        verify_card => true,
        fail_on_duplicate_payment_method => true,
        verification_merchant_account_id => "not_a_real_merchant_account_id"
      }
    });

    ok $result->is_success;
  };

  subtest "it respects verify_card and verification_merchant_account_id when included outside of the nonce" => sub {
    my $nonce = Net::Braintree::TestHelper::nonce_for_new_payment_method({
      credit_card => {
        number => "4000111111111115",
        expiration_month => "11",
        expiration_year => "2009"
      }
    });


    my $customer = Net::Braintree::Customer->create()->customer;
    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      options => {
        verify_card => true,
        verification_merchant_account_id => Net::Braintree::TestHelper::NON_DEFAULT_MERCHANT_ACCOUNT_ID
      }
    });

    ok !$result->is_success;
    ok($result->credit_card_verification->status eq Net::Braintree::Transaction::Status::ProcessorDeclined);
    is($result->credit_card_verification->processor_response_code, "2000");
    is($result->credit_card_verification->processor_response_text, "Do Not Honor");
    ok($result->credit_card_verification->merchant_account_id eq Net::Braintree::TestHelper::NON_DEFAULT_MERCHANT_ACCOUNT_ID);
  };

  subtest "it respects fail_on_duplicate_payment_method when included outside of the nonce" => sub {
    my $customer = Net::Braintree::Customer->create()->customer;
    my $result = Net::Braintree::CreditCard->create({
      customer_id => $customer->id,
      number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
      expiration_date => "05/2012"
    });

    ok $result->is_success;
    my $nonce = Net::Braintree::TestHelper::nonce_for_new_payment_method({
      credit_card => {
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012"
      }
    });

    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      options => {
        fail_on_duplicate_payment_method => true
      }
    });

    ok !$result->is_success;
    is($result->errors->deep_errors()->[0]->code, "81724");
  };

  subtest "it allows passing the billing address outside of the nonce" => sub {
    my $customer = Net::Braintree::Customer->create()->customer;
    my $nonce = Net::Braintree::TestHelper::nonce_for_new_credit_card({
      number => "4111111111111111",
      expirationMonth => "12",
      expirationYear => "2020",
      options => {
        validate => false
      }
    });

    isnt($nonce, undef);
    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      billing_address => {
        street_address => "123 Abc Way"
      }
    });

    ok $result->is_success;
    isnt($result->payment_method, undef);
    ok $result->payment_method->isa('Net::Braintree::CreditCard');

    my $token = $result->payment_method->token;
    my $found_credit_card = Net::Braintree::CreditCard->find($token);
    isnt($found_credit_card, undef);
    is($found_credit_card->billing_address->street_address, "123 Abc Way");
  };

  subtest "it overrides the billing address in the nonce" => sub {
    my $customer = Net::Braintree::Customer->create()->customer;
    my $nonce = Net::Braintree::TestHelper::nonce_for_new_credit_card({
      number => "4111111111111111",
      expirationMonth => "12",
      expirationYear => "2020",
      options => {
        validate => false
      },
      billing_address => {
        street_address => "456 Xyz Way"
      }
    });

    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      billing_address => {
        street_address => "123 Abc Way"
      }
    });

    ok $result->is_success;
    ok $result->payment_method->isa('Net::Braintree::CreditCard');

    my $token = $result->payment_method->token;
    my $found_credit_card = Net::Braintree::CreditCard->find($token);
    isnt($found_credit_card, undef);
    is($found_credit_card->billing_address->street_address, "123 Abc Way");
  };

  subtest "it does not override the billing address for a vaulted credit card" => sub {
    my $customer = Net::Braintree::Customer->create()->customer;
    my $config = Net::Braintree::Configuration->new(environment => "integration");
    my $customer = Net::Braintree::Customer->create()->customer;
    my $raw_client_token = Net::Braintree::TestHelper::generate_decoded_client_token({ customer_id => $customer->id });
    my $client_token = decode_json($raw_client_token);

    my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};
    my $http = Net::Braintree::ClientApiHTTP->new(
      config => $config,
      fingerprint => $authorization_fingerprint,
      shared_customer_identifier => "fake_identifier",
      shared_customer_identifier_type => "testing"
    );

    my $nonce = $http->get_nonce_for_new_card_with_params({
      number => "4111111111111111",
      expirationMonth => "12",
      expirationYear => "2020",
      billing_address => {
        street_address => "456 Xyz Way"
      }
    });

    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      billing_address => {
        street_address => "123 Abc Way"
      }
    });

    ok $result->is_success;
    ok $result->payment_method->isa('Net::Braintree::CreditCard');
    my $token = $result->payment_method->token;
    my $found_credit_card = Net::Braintree::CreditCard->find($token);
    isnt($found_credit_card, undef);
    is($found_credit_card->billing_address->street_address, "456 Xyz Way");
  };

  subtest "it ignores passed billing address params" => sub {
    my $nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({
      consent_code => "PAYPAL_CONSENT_CODE"
    });

    my $customer = Net::Braintree::Customer->create()->customer;
    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      billing_address => {
        street_address => "123 Abc Way"
      }
    });

    ok $result->is_success;
    ok $result->payment_method->isa('Net::Braintree::PayPalAccount');
    isnt($result->payment_method->image_url, undef);

    my $token = $result->payment_method->token;
    my $found_paypal_account = Net::Braintree::PayPalAccount->find($token);
    isnt($found_paypal_account, undef);
  };

  subtest "it allows passing a billing address id outside of the nonce" => sub {
    my $customer = Net::Braintree::Customer->create()->customer;
    my $config = Net::Braintree::Configuration->new(environment => "integration");
    my $customer = Net::Braintree::Customer->create()->customer;
    my $raw_client_token = Net::Braintree::TestHelper::generate_decoded_client_token({ customer_id => $customer->id });
    my $client_token = decode_json($raw_client_token);

    my $authorization_fingerprint = $client_token->{'authorizationFingerprint'};
    my $http = Net::Braintree::ClientApiHTTP->new(
      config => $config,
      fingerprint => $authorization_fingerprint,
      shared_customer_identifier => "fake_identifier",
      shared_customer_identifier_type => "testing"
    );

    my $nonce = $http->get_nonce_for_new_card_with_params({
      number => "4111111111111111",
      expirationMonth => "12",
      expirationYear => "2020",
      options => {
        validate => false
      }
    });

    my $address = Net::Braintree::Address->create({
      customer_id => $customer->id,
      first_name => "Bobby",
      last_name => "Tables"
    })->address;

    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      billing_address_id => $address->id
    });

    ok $result->is_success;
    ok $result->payment_method->isa('Net::Braintree::CreditCard');

    my $token = $result->payment_method->token;
    my $found_credit_card = Net::Braintree::CreditCard->find($token);
    isnt($found_credit_card, undef);
    is($found_credit_card->billing_address->first_name, "Bobby");
    is($found_credit_card->billing_address->last_name, "Tables");
  };

  subtest "it ignores passed billing address id" => sub {
    my $nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({
      consent_code => "PAYPAL_CONSENT_CODE"
    });

    my $customer = Net::Braintree::Customer->create()->customer;
    my $result = Net::Braintree::PaymentMethod->create({
      payment_method_nonce => $nonce,
      customer_id => $customer->id,
      billing_address_id => "address_id"
    });

    ok $result->is_success;
    ok $result->payment_method->isa('Net::Braintree::PayPalAccount');
    isnt($result->payment_method->image_url, undef);

    my $token = $result->payment_method->token;
    my $found_paypal_account = Net::Braintree::PayPalAccount->find($token);
    isnt($found_paypal_account, undef);
  };
};

subtest "Update" => sub {
  subtest "credit cards" => sub {
    subtest "it updates the credit card" => sub {
      my $customer_result = Net::Braintree::Customer->create();
      my $customer = $customer_result->customer;
      my $credit_card_result = Net::Braintree::CreditCard->create({
        cardholder_name => "Original Holder",
        customer_id => $customer->id,
        cvv => "123",
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012"
      });

      my $credit_card = $credit_card_result->credit_card;
      my $update_result = Net::Braintree::PaymentMethod->update(
        $credit_card->token,
        {
          cardholder_name => "New Holder",
          cvv => "456",
          number => Net::Braintree::SandboxValues::CreditCardNumber::MASTER_CARD,
          expiration_date => "06/2013"
        });

      my $mastercard = Net::Braintree::SandboxValues::CreditCardNumber::MASTER_CARD;
      my $mastercard_length = length($mastercard);

      ok $update_result->is_success;
      my $updated_credit_card = $update_result->payment_method;
      ok($updated_credit_card->token eq $credit_card->token);
      is($updated_credit_card->cardholder_name, "New Holder");
      is($updated_credit_card->bin, substr($mastercard, 0, 6));
      is($updated_credit_card->last_4, substr($mastercard, $mastercard_length - 4, 4));
      is($updated_credit_card->expiration_date, "06/2013");
    };

    subtest "billing address" => sub {
      subtest "it creates a new billing address by default" => sub {
        my $customer_result = Net::Braintree::Customer->create();
        my $customer = $customer_result->customer;
        my $credit_card_result = Net::Braintree::CreditCard->create({
          customer_id => $customer->id,
          number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
          expiration_date => "05/2012",
          billing_address => {
            street_address => "123 Nigeria Ave"
          }
        });

        ok $credit_card_result->is_success;
        my $credit_card = $credit_card_result->credit_card;
        my $update_result = Net::Braintree::PaymentMethod->update(
          $credit_card->token,
          {
            billing_address => {
              region => "IL"
            }
          });

        ok $update_result->is_success;
        my $updated_credit_card = $update_result->payment_method;
        is($updated_credit_card->billing_address->region, "IL");
        is($updated_credit_card->billing_address->street_address, undef);
        ok($updated_credit_card->billing_address->id ne $credit_card->billing_address->id);
      };

      subtest "it updates the billing address if option is specified" => sub {
        my $customer_result = Net::Braintree::Customer->create();
        my $customer = $customer_result->customer;
        my $credit_card_result = Net::Braintree::CreditCard->create({
          customer_id => $customer->id,
          number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
          expiration_date => "05/2012",
          billing_address => {
            street_address => "123 Nigeria Ave"
          }
        });

        ok $credit_card_result->is_success;
        my $credit_card = $credit_card_result->credit_card;
        my $update_result = Net::Braintree::PaymentMethod->update(
          $credit_card->token,
          {
            billing_address => {
              region => "IL",
              options => {
                update_existing => true
              }
            }
          });

        ok $update_result->is_success;
        my $updated_credit_card = $update_result->payment_method;
        is($updated_credit_card->billing_address->region, "IL");
        is($updated_credit_card->billing_address->street_address, "123 Nigeria Ave");
        ok($updated_credit_card->billing_address->id eq $credit_card->billing_address->id);
      };

      subtest "it updates the country via codes" => sub {
        my $customer_result = Net::Braintree::Customer->create();
        my $customer = $customer_result->customer;
        my $credit_card_result = Net::Braintree::CreditCard->create({
          customer_id => $customer->id,
          number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
          expiration_date => "05/2012",
          billing_address => {
            street_address => "123 Nigeria Ave"
          }
        });

        ok $credit_card_result->is_success;
        my $credit_card = $credit_card_result->credit_card;
        my $update_result = Net::Braintree::PaymentMethod->update(
          $credit_card->token,
          {
            billing_address => {
              country_name => "American Samoa",
              country_code_alpha2 => "AS",
              country_code_alpha3 => "ASM",
              country_code_numeric => "016",
              options => {
                update_existing => true
              }
            }
          });

        ok $update_result->is_success;
        my $updated_credit_card = $update_result->payment_method;
        is($updated_credit_card->billing_address->country_name, "American Samoa");
        is($updated_credit_card->billing_address->country_code_alpha2, "AS");
        is($updated_credit_card->billing_address->country_code_alpha3, "ASM");
        is($updated_credit_card->billing_address->country_code_numeric, "016");
      };
    };

    subtest "it can pass expiration_month and expiration_year" => sub {
      my $customer_result = Net::Braintree::Customer->create();
      my $customer = $customer_result->customer;
      my $credit_card_result = Net::Braintree::CreditCard->create({
        customer_id => $customer->id,
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012",
      });

      ok $credit_card_result->is_success;
      my $credit_card = $credit_card_result->credit_card;
      my $update_result = Net::Braintree::PaymentMethod->update(
        $credit_card->token,
        {
          number => Net::Braintree::SandboxValues::CreditCardNumber::MASTER_CARD,
          expiration_month => "07",
          expiration_year => "2011"
        });

      ok $update_result->is_success;
      my $updated_credit_card = $update_result->payment_method;
      ok($updated_credit_card->token eq $credit_card->token);
      is($updated_credit_card->expiration_month, "07");
      is($updated_credit_card->expiration_year, "2011");
      is($updated_credit_card->expiration_date, "07/2011");
    };

    subtest "it verifies the update if options[verify_card]=true" => sub {
      my $customer_result = Net::Braintree::Customer->create();
      my $customer = $customer_result->customer;
      my $credit_card_result = Net::Braintree::CreditCard->create({
        cardholder_name => "Original Holder",
        customer_id => $customer->id,
        cvv => "123",
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012",
      });

      ok $credit_card_result->is_success;
      my $credit_card = $credit_card_result->credit_card;
      my $update_result = Net::Braintree::PaymentMethod->update(
        $credit_card->token,
        {
          cardholder_name => "New Holder",
          cvv => "456",
          number => Net::Braintree::SandboxValues::CreditCardNumber::FAILS_VERIFICATION_MASTER_CARD,
          expiration_date => "06/2013",
          options => {
            verify_card => true
          }
        });

      ok !$update_result->is_success;
      ok($update_result->credit_card_verification->status, Net::Braintree::Transaction::Status::ProcessorDeclined);
      is($update_result->credit_card_verification->gateway_rejection_reason, undef);
    };

    subtest "it can update the billing address" => sub {
      my $customer_result = Net::Braintree::Customer->create();
      my $customer = $customer_result->customer;
      my $credit_card_result = Net::Braintree::CreditCard->create({
        cardholder_name => "Original Holder",
        customer_id => $customer->id,
        cvv => "123",
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012",
        billing_address => {
          first_name => "Old First Name",
          last_name => "Old Last Name",
          company => "Old Company",
          street_address => "123 Old St",
          extended_address => "Apt Old",
          locality => "Old City",
          region => "Old State",
          postal_code => "12345",
          country_name => "Canada"
        }
      });

      ok $credit_card_result->is_success;
      my $credit_card = $credit_card_result->credit_card;
      my $result = Net::Braintree::PaymentMethod->update(
        $credit_card->token,
        {
          options => {
            verify_card => false
          },
          billing_address => {
            first_name => "New First Name",
            last_name => "New Last Name",
            company => "New Company",
            street_address => "123 New St",
            extended_address => "Apt New",
            locality => "New City",
            region => "New State",
            postal_code => "56789",
            country_name => "United States of America"
          }
        });

      ok $result->is_success;
      my $address = $result->payment_method->billing_address;
      is($address->first_name, "New First Name");
      is($address->last_name, "New Last Name");
      is($address->company, "New Company");
      is($address->street_address, "123 New St");
      is($address->extended_address, "Apt New");
      is($address->locality, "New City");
      is($address->region, "New State");
      is($address->postal_code, "56789");
      is($address->country_name, "United States of America");
    };

    subtest "it returns an error response if invalid" => sub {
      my $customer_result = Net::Braintree::Customer->create();
      my $customer = $customer_result->customer;
      my $credit_card_result = Net::Braintree::CreditCard->create({
        cardholder_name => "Original Holder",
        customer_id => $customer->id,
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012",
      });

      ok $credit_card_result->is_success;
      my $credit_card = $credit_card_result->credit_card;
      my $result = Net::Braintree::PaymentMethod->update(
        $credit_card->token,
        {
          cardholder_name => "New Holder",
          number => "invalid",
          expiration_date => "05/2014"
        });

      ok !$result->is_success;
      is($result->errors->for("credit_card")->on("number")->[0]->message, "Credit card number must be 12-19 digits.");
    };

    subtest "it can update the default" => sub {
      my $customer_result = Net::Braintree::Customer->create();
      my $customer = $customer_result->customer;
      my $card1 = Net::Braintree::CreditCard->create({
        customer_id => $customer->id,
        cardholder_name => "Original Holder",
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2009",
      })->credit_card;

      my $card2 = Net::Braintree::CreditCard->create({
        customer_id => $customer->id,
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2012",
      })->credit_card;

      ok $card1->is_default;
      ok !$card2->is_default;

      my $result = Net::Braintree::PaymentMethod->update(
        $card2->token,
        {
          options => {
            make_default => true
          }
        });

      ok $result->is_success;
      ok(!Net::Braintree::CreditCard->find($card1->token)->is_default);
      ok(Net::Braintree::CreditCard->find($card2->token)->is_default);
    };
  };

  subtest "paypal accounts" => sub {
    subtest "it updates a paypal account's token" => sub {
      my $customer = Net::Braintree::Customer->create()->customer;
      my $original_token = "paypal-account-" . int(rand(10000));
      my $nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({
        consent_code => "consent-code",
        token => $original_token
      });

      my $original_result = Net::Braintree::PaymentMethod->create({
        payment_method_nonce => $nonce,
        customer_id => $customer->id
      });

      my $updated_token = "UPDATED_TOKEN-" . int(rand(10000));
      my $updated_result = Net::Braintree::PaymentMethod->update(
        $original_token,
        {
          token => $updated_token
        }
      );

      my $updated_paypal_account = Net::Braintree::PayPalAccount->find($updated_token);
      ok($updated_paypal_account->email eq $original_result->payment_method->email);
      should_throw("NotFoundError", sub {
        Net::Braintree::PayPalAccount->find($original_token);
      });
    };

    subtest "it can make a paypal account the default payment method" => sub {
      my $customer = Net::Braintree::Customer->create()->customer;
      my $result = Net::Braintree::CreditCard->create({
        customer_id => $customer->id,
        number => Net::Braintree::SandboxValues::CreditCardNumber::VISA,
        expiration_date => "05/2009",
        options => {
          make_default => true
        }
      });

      ok $result->is_success;
      my $nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({ consent_code => "consent-code" });
      my $original_token = Net::Braintree::PaymentMethod->create({
        payment_method_nonce => $nonce,
        customer_id => $customer->id
      })->payment_method->token;

      my $updated_result = Net::Braintree::PaymentMethod->update(
        $original_token,
        {
          options => {
            make_default => true
          }
        });

      my $updated_paypal_account = Net::Braintree::PayPalAccount->find($original_token);
      ok $updated_paypal_account->default;
    };

    subtest "it returns an error if a token for account is used to attempt an update" => sub {
      my $customer = Net::Braintree::Customer->create()->customer;
      my $first_token = "paypal-account-" . int(rand(10000));
      my $second_token = "paypal-account-" . int(rand(10000));
      my $first_nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({
        consent_code => "consent-code",
        token => $first_token
      });

      my $first_result = Net::Braintree::PaymentMethod->create({
        payment_method_nonce => $first_nonce,
        customer_id => $customer->id
      });

      my $second_nonce = Net::Braintree::TestHelper::nonce_for_paypal_account({
        consent_code => "consent-code",
        token => $second_token
      });

      my $second_result = Net::Braintree::PaymentMethod->create({
        payment_method_nonce => $second_nonce,
        customer_id => $customer->id
      });

      my $updated_result = Net::Braintree::PaymentMethod->update(
        $first_token,
        {
          token => $second_token
        });

      ok !$updated_result->is_success;
      is($updated_result->errors->deep_errors()->[0]->code, "92906")
    };
  };
};

subtest "Delete" => sub {
  subtest "delete deletes credit card" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    my $nonce = Net::Braintree::Nonce::transactable();
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => $nonce
    });

    ok $payment_method_result->is_success;
    isnt($payment_method_result->credit_card->token, undef);
    Net::Braintree::PaymentMethod->delete($payment_method_result->credit_card->token);
  };

  subtest "delete deletes paypal account" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce::paypal_future_payment()
    });

    ok $payment_method_result->is_success;
    Net::Braintree::PaymentMethod->delete($payment_method_result->paypal_account->token);
  };

  subtest "delete raises a NotFoundError when token doesn't exist" => sub {
    should_throw("NotFoundError", sub {
      Net::Braintree::PaymentMethod->delete(" ");
    });
  };
};

subtest "Find" => sub {
  subtest "find finds a credit card" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce::transactable()
    });

    ok $payment_method_result->is_success;
    my $payment_method_found = Net::Braintree::PaymentMethod->find($payment_method_result->credit_card->token);
    ok($payment_method_result->credit_card->token eq $payment_method_found->token);
  };

  subtest "find finds a paypal account" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce::paypal_future_payment()
    });

    ok $payment_method_result->is_success;
    my $payment_method_found = Net::Braintree::PaymentMethod->find($payment_method_result->paypal_account->token);
    ok($payment_method_result->paypal_account->token eq $payment_method_found->token);
  };

  subtest "find raises a NotFoundError when the token is blank" => sub {
    should_throw("NotFoundError", sub {
      Net::Braintree::PaymentMethod->find(" ");
    });
  };

  subtest "find raises a NotFoundError when the token doesn't exist" => sub {
    should_throw("NotFoundError", sub {
      Net::Braintree::PaymentMethod->find("missing");
    });
  };
};

done_testing();
