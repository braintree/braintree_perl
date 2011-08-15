use lib qw(lib t/lib);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Test::More;
use Data::Dumper;

subtest "params tests" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::Transaction->sale({"foo" => "Bar"}); });
};

done_testing();
