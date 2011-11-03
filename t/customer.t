use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

subtest "validate params" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::Customer->create({invalid_param => "value"}) });
};

subtest "throws notFoundError if find is passed an empty string" => sub {
  should_throw("NotFoundError", sub { Net::Braintree::Customer->find("") });
  should_throw("NotFoundError", sub { Net::Braintree::Customer->find("  ") });
};

done_testing();
