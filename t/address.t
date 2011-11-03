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

subtest "throws error on find if passed empty string for customer or address id" => sub {
  should_throw("NotFoundError", sub { Net::Braintree::Address->find("", "adfs671") });
  should_throw("NotFoundError", sub { Net::Braintree::Address->find("   ", "asdf") });
  should_throw("NotFoundError", sub { Net::Braintree::Address->find("iaddf", "") });
  should_throw("NotFoundError", sub { Net::Braintree::Address->find("iaddf", "  ") });
};

done_testing();
