use lib qw(lib t/lib);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Test::More;

BEGIN { use_ok('Net::Braintree::ValidationError') };

subtest "initialize" => sub {
  my $error = Net::Braintree::ValidationError->new(attribute => "some model attribute", code => 1, message => "bad juju");
  is($error->attribute, "some model attribute");
  is($error->code, 1);
  is($error->message, "bad juju");
};

done_testing();
