use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

my $customer_instance = Net::Braintree::Customer->new;
my $customer = $customer_instance->create({first_name => "Walter", last_name => "Weatherman"});

subtest "create" => sub {
  $result = Net::Braintree::Address->create({
    customer_id => $customer->customer->id,
    first_name => "Walter",
    last_name => "Weatherman",
    company => "The Bluth Company",
    street_address => "123 Fake St",
    extended_address => "Suite 403",
    locality => "Chicago",
    region => "Illinois",
    postal_code => "60622",
    country_code_alpha2 => "US"
  });

  ok $result->is_success;
  is $result->address->street_address, "123 Fake St";
  is $result->address->full_name, "Walter Weatherman";
};

subtest "Create without customer ID" => sub {
  should_throw("NotFoundError", sub { Net::Braintree::Address->create({ customer_id => "foo", first_name => "walter" }) });
};

subtest "Create without any fields"  => sub {
  my $result = Net::Braintree::Address->create({
      customer_id => $customer->customer->id,
    });
  not_ok $result->is_success;
  ok(scalar @{$result->errors->for('address')->deep_errors} > 0, "has at least one error on address");
  is($result->message, "Addresses must have at least one field filled in.", "Address error");
};

subtest "with a customer" => sub {
  my $create_result = Net::Braintree::Address->create({
      customer_id => $customer->customer->id,
      first_name => "Walter"
    });

  subtest "find" => sub {
    $address = Net::Braintree::Address->find($customer->customer->id, $create_result->address->id);
    is $address->first_name, "Walter";
  };

  subtest "not found" =>  sub {
    should_throw("NotFoundError", sub {Net::Braintree::Address->find("not_found", "dne")}, "Catches Not Found");
  };

  subtest "Update" => sub {
   my $result = Net::Braintree::Address->update($customer->customer->id, $create_result->address->id,
     {first_name => "Ivar"});
   ok $result->is_success;
   is $result->address->first_name, "Ivar";
  };

  subtest "Update non-existant" => sub {
    should_throw "NotFoundError", sub { Net::Braintree::Address->update("abc", "123") };
  };

  subtest "delete existing" => sub {
    my $create = Net::Braintree::Address->create({customer_id => $customer->customer->id, first_name => "Ivar", last_name => "Jacobson"});
    my $result = Net::Braintree::Address->delete($customer->customer->id, $create->address->id);

    ok $result->is_success;

    should_throw "NotFoundError", sub { Net::Braintree::Address->update($customer->customer->id, $create->address->id) };
  };

};


done_testing();
