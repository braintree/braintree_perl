use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::TestHelper;

subtest "validation" => sub {
  should_throw("ArgumentError", sub { Net::Braintree::Address->create({customer_id => "cutomer_id", invalid_key => "foo"}) });
};

subtest "instance methods" => sub {
  my $address = Net::Braintree::Address->new(first_name => "Walter", last_name => "Weatherman");
  is $address->full_name, "Walter Weatherman";
};

done_testing();
