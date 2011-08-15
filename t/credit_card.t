use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

subtest "validate params" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::CreditCard->create({check_it => "out"}) }) ;
};

subtest "builds attributes from build args" => sub {
  my $cc = Net::Braintree::CreditCard->new(bin => "123456", last_4 => "7890");

  is $cc->bin, "123456";
  is $cc->last_4, "7890";
};

subtest "instance methods" => sub {
  my $cc = Net::Braintree::CreditCard->new(bin => "123456", last_4 => "7890", default => "0");
  is $cc->masked_number, "123456******7890";
  not_ok $cc->is_default;

  $default = Net::Braintree::CreditCard->new(default => 1);
  ok $default->is_default;
};

done_testing();
