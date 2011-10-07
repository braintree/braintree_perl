use lib qw(lib t/lib);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Test::More;

subtest "params tests" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::Transaction->sale({"foo" => "Bar"}); });
};

subtest "validates clone_transaction params"  => sub {
  should_throw("ArgumentError", sub {
    Net::Braintree::Transaction->clone_transaction("foo", { invalid_param => "something"});
  });
};

done_testing();
