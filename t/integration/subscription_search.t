use lib qw(lib t/lib);
use Test::More;
use Time::HiRes qw(gettimeofday);
use Net::Braintree;
use Net::Braintree::TestHelper;

my $customer = Net::Braintree::Customer->create({first_name => "Fred", last_name => "Fredson"});
my $card = Net::Braintree::CreditCard->create({number => "5431111111111111", expiration_date => "05/12", customer_id => $customer->customer->id});

subtest "id (equality)" => sub {
  my $id = generate_unique_integer() . "123";
  my $subscription1 = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription1_$id"
  })->subscription;

  my $subscription2 = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription2_$id"
  })->subscription;

  my $search_result = Net::Braintree::Subscription->search(sub {
    my $search = shift;
    $search->id->is("subscription1_$id");
  });

  ok $subscription1->id ~~ $search_result->ids;
  not_ok $subscription2->id ~~ $search_result->ids;
};

subtest "price (range)" => sub {
  my $id = generate_unique_integer() . "223";

  my $subscription1 = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription1_$id",
    price => "5.00"
  })->subscription;

  my $subscription2 = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription2_$id",
    price => "6.00"
  })->subscription;

  my $search_result = Net::Braintree::Subscription->search(sub {
    my $search = shift;
    $search->price->max("5.50");
  });

  ok $subscription1->id ~~ $search_result->ids;
  not_ok $subscription2->id ~~ $search_result->ids;
};

subtest "price (is)"  => sub {
  my $id = generate_unique_integer() . "223";

  my $subscription1 = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription1_$id",
    price => "5.00"
  })->subscription;

  my $subscription2 = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription2_$id",
    price => "6.00"
  })->subscription;

  my $search_result = Net::Braintree::Subscription->search(sub {
    my $search = shift;
    $search->price->is("5.00");
  });

  ok $subscription1->id ~~ $search_result->ids;
  not_ok $subscription2->id ~~ $search_result->ids;
};

subtest "status (multiple value)" => sub {
  my $id = generate_unique_integer() . "222";

  my $subscription_active = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription1_$id"
  })->subscription;

  my $subscription_past_due = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription2_$id"
  })->subscription;

  make_subscription_past_due($subscription_past_due->id);

  my $search_result = Net::Braintree::Subscription->search(sub {
    my $search = shift;
    $search->status->is("Active");
  });

  ok $subscription_active->id ~~ $search_result->ids;
  not_ok $subscription_past_due->id ~~ $search_result->ids;
};

subtest "each (single value)" => sub {
  my $id = generate_unique_integer() . "single_value";

  my $subscription_active = Net::Braintree::Subscription->create({
    payment_method_token => $card->credit_card->token,
    plan_id => "integration_trialless_plan",
    id => "subscription1_$id"
  })->subscription;

  my $search_result = Net::Braintree::Subscription->search(sub{
    shift->id->is("subscription1_$id");
  });

  my @subscriptions = ();
  $search_result->each(sub {
    push(@subscriptions, shift);
  });

  is_deeply \@subscriptions, [$subscription_active];

};

subtest "all" => sub {
  my $subscriptions = Net::Braintree::Subscription->all;
  ok scalar @{$subscriptions->ids} > 1;
};

sub generate_unique_integer {
  return int(gettimeofday * 1000);
}

done_testing();
