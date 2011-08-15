use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

subtest "validate params" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::Customer->create({invalid_param => "value"}) });
};

done_testing();
