use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::ErrorCodes;
use Net::Braintree::Nonce;
use Net::Braintree::TestHelper;
use Net::Braintree::Test;
use Net::Braintree::Xml;
use Data::GUID;

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
