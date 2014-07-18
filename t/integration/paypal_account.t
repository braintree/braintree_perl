use lib qw(lib t/lib);
use Test::More;
use Data::GUID;
use Net::Braintree;
use Net::Braintree::Nonce;
use Net::Braintree::TestHelper;
use Net::Braintree::Test;
use Net::Braintree::Xml;

subtest "Find" => sub {
  subtest "it returns paypal accounts by token" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    ok $customer_result->is_success;

    my $result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce->paypal_future_payment
    });

    ok $result->is_success;
    isnt($result->paypal_account->image_url, undef);

    my $found = Net::Braintree::PayPalAccount->find($result->paypal_account->token);
    isnt($found, undef);
    isnt($found->email, undef);
    isnt($found->image_url, undef);
    isnt($found->created_at, undef);
    isnt($found->updated_at, undef);
    ok($found->email eq $result->paypal_account->email);
  };

  subtest "it raises a not-found error for an unknown token" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::PayPalAccount->find(" ") });
  };

  subtest "it raises a not-found error for a credit card token" => sub {
    my $customer_result = Net::Braintree::Customer->create({
      credit_card => {
        number => "5105105105105100",
        expiration_date => "05/12",
        cvv => "123"
      }
    });

    should_throw("NotFoundError", sub {
      Net::Braintree::PayPalAccount->find($customer_result->customer->credit_cards->[0]->token);
    });
  };
};

subtest "Delete" => sub {
  subtest "returns paypal account by token" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    ok $customer_result->is_success;

    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce::paypal_future_payment
    });

    ok $payment_method_result->is_success;
    Net::Braintree::PayPalAccount->delete($payment_method_result->paypal_account->token);
  };

  subtest "raises a NotFoundError for unknown token" => sub {
    should_throw("NotFoundError", sub {
      Net::Braintree::PayPalAccount->delete(" ");
    });
  };
};

subtest "Update" => sub {
  subtest "can update token" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    ok $customer_result->is_success;

    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce::paypal_future_payment
    });

    ok $payment_method_result->is_success;
    my $new_token = Data::GUID->new->as_string;
    my $update_result = Net::Braintree::PayPalAccount->update(
      $payment_method_result->paypal_account->token,
      {
        token => $new_token
      });

    ok $update_result->is_success;
    ok($new_token eq $update_result->paypal_account->token);
  };

  subtest "can make default" => sub {
    my $customer_result = Net::Braintree::Customer->create();
    ok $customer_result->is_success;

    my $credit_card_result = Net::Braintree::CreditCard->create({
      customer_id => $customer_result->customer->id,
      number => "5105105105105100",
      expiration_date => "05/12"
    });

    ok $credit_card_result->credit_card->default;
    my $payment_method_result = Net::Braintree::PaymentMethod->create({
      customer_id => $customer_result->customer->id,
      payment_method_nonce => Net::Braintree::Nonce::paypal_future_payment
    });

    ok $payment_method_result->is_success;
    my $update_result = Net::Braintree::PayPalAccount->update(
      $payment_method_result->payment_method->token,
      {
        options => {
          make_default => true
        }
      });

    ok $update_result->is_success;
    ok $update_result->payment_method->default;
  };
};

done_testing();
