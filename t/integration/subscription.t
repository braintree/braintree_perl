use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::TestHelper;
use Net::Braintree;

my $customer = Net::Braintree::Customer->create({first_name => "Fred", last_name => "Fredson"});
my $card     = Net::Braintree::CreditCard->create({number => "5431111111111111", expiration_date => "05/12", customer_id => $customer->customer->id});

subtest "create without trial" => sub {
  my $result = Net::Braintree::Subscription->create({payment_method_token => $card->credit_card->token, plan_id => "integration_trialless_plan"});
  ok $result->is_success;
  like $result->subscription->id, qr/^\w{6}$/;
  is $result->subscription->status, 'Active';
  is $result->subscription->plan_id, "integration_trialless_plan";

  isnt $result->subscription->transactions->[0], undef;

  is $result->subscription->failure_count,  0;
  is $result->subscription->next_bill_amount,  "12.34";
  is $result->subscription->next_billing_period_amount,  "12.34";
  is $result->subscription->payment_method_token,  $card->credit_card->token;
  print "_-_-_-_-_-_-\n";
  use Data::Dumper;
  print Dumper($result->subscription->transactions);
  my $transaction = $result->subscription->transactions->[0];
  print "_-_-_-_-_-_-\n";

  is_deeply $transaction->subscription->billing_period_start_date, $result->subscription->billing_period_start_date;
  is_deeply $transaction->subscription->billing_period_end_date, $result->subscription->billing_period_end_date;

  is $result->subscription->trial_period, 0;
  is $result->subscription->trial_duration, undef;
  is $result->subscription->trial_duration_unit, undef;
};

subtest "create with trial, add-ons, discounts" => sub {
  my $result = Net::Braintree::Subscription->create({
      payment_method_token => $card->credit_card->token,
      plan_id => "integration_plan_with_add_ons_and_discounts",
      discounts => {
          add => [{ inherited_from_id => "discount_15"}]
      },
      add_ons => {
          add => [{ inherited_from_id => "increase_30" }],
      }
    });

  ok $result->is_success;
  is $result->subscription->discounts->[0]->amount, '7.00';
  is $result->subscription->add_ons->[0]->amount, '10.00';
};

subtest "retry charge" => sub {
  my $subscription = Net::Braintree::Subscription->create({
    plan_id => "integration_trialless_plan",
    payment_method_token => $card->credit_card->token
  })->subscription;

  make_subscription_past_due($subscription->id);

  my $retry = Net::Braintree::Subscription->retry_charge($subscription->id);

  ok $retry->is_success;
  is $retry->transaction->amount, $subscription->price;
};

subtest "if transaction fails, no subscription gets returned" => sub {
  my $result = Net::Braintree::Subscription->create({
      payment_method_token => $card->credit_card->token,
      plan_id => "integration_trialless_plan",
      price => "2000.00"
    });

  not_ok $result->is_success;
  is $result->message, "Do Not Honor";
};
subtest "with a subscription" => sub {
  my $create = Net::Braintree::Subscription->create({
      payment_method_token => $card->credit_card->token,
      plan_id => "integration_trialless_plan"
    });

  subtest "find" => sub {
    my $result = Net::Braintree::Subscription->find($create->subscription->id);

    is $result->trial_period, 0;
    is $result->plan_id, "integration_trialless_plan";

    should_throw("NotFoundError", sub { Net::Braintree::Subscription->find("asdlkfj") });
  };

  subtest "update" => sub {
    my $result = Net::Braintree::Subscription->update($create->subscription->id, {price => "50.00"});

    ok $result->is_success;
    is $result->subscription->price, "50.00";

    should_throw("NotFoundError", sub { Net::Braintree::Subscription->update("asdlkfj", {price => "50.00"}) });
  };

  subtest "cancel" => sub {
    my $result = Net::Braintree::Subscription->cancel($create->subscription->id);
    ok $result->is_success;

    $result = Net::Braintree::Subscription->cancel($create->subscription->id);
    not_ok $result->is_success;
    is $result->message, "Subscription has already been canceled."
  };
};
done_testing();
