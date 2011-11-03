use lib qw(lib t/lib);
use Net::Braintree;
use Test::More;
use Test::Moose;
use Net::Braintree::TestHelper;


subtest "does have correct attributes" => sub {
  my $subscription = Net::Braintree::Subscription->new(balance => "12.00");

  is $subscription->balance, "12.00";
  has_attribute_ok $subscription, "balance";
};

subtest "throws NotFoundError if find is given empty string" => sub {
  should_throw("NotFoundError", sub { Net::Braintree::Subscription->find("") });
  should_throw("NotFoundError", sub { Net::Braintree::Subscription->find("  ") });
};

done_testing();
