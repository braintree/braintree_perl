use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;

my $customer_attributes = {
  first_name => "Johnny",
  last_name => "Doe",
  company => "Braintree",
  email => 'johnny@example.com',
  phone  => "312.555.0123",
  website => "www.example.com"
};

my $customer_with_cc_and_billing = {
  first_name => "Johnny",
  last_name => "Doe",
  company => "Braintree",
  credit_card => {
    number => "5431111111111111",
    expiration_date => "08/2012",
    billing_address => {
      street_address => "2 E Main St",
      extended_address => "Apt 4",
      locality => "Chicago",
      region => "Illinois",
      postal_code => "60647",
      country_code_alpha2 => "US"
    }
  }
};

subtest "Create:S2S" => sub {
  subtest "simple" => sub {
    my $result = Net::Braintree::Customer->create($customer_attributes);
    ok($result->is_success, "customer s2s create successful");
    is($result->customer->first_name, "Johnny", "sets customer attributes (first name)");
    isnt($result->customer->id, undef, "customer id != blank");
  };

  subtest "with CC and billing address" => sub {
    my $result = Net::Braintree::Customer->create($customer_with_cc_and_billing);
    ok $result->is_success, "customer s2s complex create successful";
    is($result->customer->first_name, "Johnny", "sets customer attributes (first name)");
    is($result->customer->addresses->[0]->street_address, "2 E Main St", "sets deeply nested attributes");
    is($result->customer->credit_cards->[0]->last_4, "1111");
    ok $result->customer->credit_cards->[0]->unique_number_identifier =~ /\A\w{32}\z/;
  };

  subtest "with invalid attributes" => sub {
    plan skip_all => 'pending';
  };
};

subtest "delete" => sub {
  subtest "existing customer" => sub {
    my $create = Net::Braintree::Customer->create($customer_attributes);
    my $delete = Net::Braintree::Customer->delete($create->customer->id);
    ok $delete->is_success, "customer delete success";
  };

  subtest "customer doesn't exist" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::Customer->delete("foo") }, "throws NotFoundError if customer doesn't exist");
  };
};

subtest "find" => sub {
  subtest "existing customer" => sub {
    my $create = Net::Braintree::Customer->create($customer_attributes);
    my $customer = Net::Braintree::Customer->find($create->customer->id);
    is $customer->id, $create->customer->id, "finds the correct customer";
    is $customer->first_name, "Johnny", "gets customer details (First name)";
  };

  subtest "doesn't exist" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::Customer->find("foo") }, "throws NotFoundError if customer doesn't exist");
  };
};

subtest "update" => sub {
  subtest "existing simple customer" => sub {
    my $create = Net::Braintree::Customer->create($customer_attributes);
    my $update = Net::Braintree::Customer->update($create->customer->id, {first_name => "Timmy"});

    ok $update->is_success;
    is $update->customer->first_name, "Timmy", "updates attribute correctly";
  };

  subtest "add CC/address details existing simple customer" => sub {
    my $create = Net::Braintree::Customer->create($customer_attributes);
    my $update = Net::Braintree::Customer->update($create->customer->id, $customer_with_cc_and_billing);

    ok $update->is_success;
    is $update->customer->addresses->[0]->street_address, "2 E Main St", "sets deeply nested attributes";
  };

  subtest "update existing customer CC/Address details" => sub {
    my $create = Net::Braintree::Customer->create($customer_with_cc_and_billing);

    my $update = Net::Braintree::Customer->update($create->customer->id, {
      credit_card => {
        number => "4009348888881881",
        expiration_date => "09/2013",
        options => { update_existing_token => $create->customer->credit_cards->[0]->token }
      }
    });

    ok $update->is_success;
    is $update->customer->credit_cards->[0]->last_4, "1881", "set credit card properly";
  };

  subtest "update existing customer billing address details" => sub {
    my $create = Net::Braintree::Customer->create($customer_with_cc_and_billing);
    my $update = Net::Braintree::Customer->update($create->customer->id, {
        credit_card => {
          number => "4009348888881881",
          options => {update_existing_token => $create->customer->credit_cards->[0]->token },
          billing_address => {
            street_address => "4 E Main St",
            options => { update_existing => "true" }
          }
        }
      }
    );

    ok $update->is_success, "update billing address";
    is $update->customer->addresses->[0]->street_address, "4 E Main St", "update billing street address";
  };

  subtest "doesn't exist" => sub {
    should_throw("NotFoundError", sub { Net::Braintree::Customer->update("baz", {first_name => "Timmy"}) }, "throws error if customer doesn't exist");
  };

  subtest "invalid params" => sub {
    should_throw("ArgumentError", sub { Net::Braintree::Customer->update('foo', {"invalid_param" => "1"})}, "throws arg error");
  };
};

done_testing();
