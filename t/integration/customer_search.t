use lib qw(lib t/lib);
use Test::More;
use Time::HiRes qw(gettimeofday);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::Util;
use DateTime;
use DateTime::Duration;

my $unique_company = "company" . generate_unique_integer();
my $unique_token = "token" . generate_unique_integer();
my $result = create_customer($unique_company, $unique_token);
ok($result->is_success, "customer created successfully");
my $customer = Net::Braintree::Customer->find($result->customer->id);

subtest "find customer with all matching fields" => sub {
  my $criteria = make_search_criteria($unique_company, $unique_token);
  my $search_result = perform_search($criteria);
  ok $search_result->is_success;
  not_ok $search_result->is_empty;
  is substr($search_result->first->credit_cards->[0]->last_4, 0, 4), 1111;
};

subtest "can find duplicate credit cards given payment method token" => sub {
  my $unique_company1 = "company" . generate_unique_integer();
  my $unique_token1 = "token" . generate_unique_integer();
  my $customer1 = create_customer($unique_company1, $unique_token1)->customer;

  my $unique_company2 = "company" . generate_unique_integer();
  my $unique_token2 = "token" . generate_unique_integer();
  my $customer2 = create_customer($unique_company2, $unique_token2)->customer;

  my $search_result = Net::Braintree::Customer->search(sub {
    my $search = shift;
    $search->payment_method_token_with_duplicates->is($customer1->credit_cards->[0]->token);
  });

  not_ok $search_result->is_empty;
  ok contains($customer1->id, $search_result->ids);
  ok contains($customer2->id, $search_result->ids);
};

subtest "can search on text fields" => sub {
  my $search_result = Net::Braintree::Customer->search(sub {
    my $search = shift;
    $search->first_name->contains("Tim")
  });

  not_ok $search_result->is_empty;
  is $search_result->first->first_name, $customer->first_name;
};

subtest "can search on credit card number (partial match)" => sub {
  my $search_result = Net::Braintree::Customer->search(sub {
    my $search = shift;
    $search->credit_card_number->ends_with(1111);
  });

  not_ok $search_result->is_empty;

  ok contains("1111", [map { $_->last_4 } @{$search_result->first->credit_cards}]);
};

subtest "can search on ids (multiple values)" => sub {
  my $search_result = Net::Braintree::Customer->search(sub {
    my $search = shift;
    $search->ids->in([$customer->id]);
  });

  not_ok $search_result->is_empty;
  is $search_result->first->id, $customer->id;
};

subtest "can search on created_at (range field)" => sub {
  my $unique_company = "company" . generate_unique_integer();
  my $unique_token = "token" . generate_unique_integer();
  my $result = create_customer($unique_company, $unique_token);
  ok $result->is_success;
  my $new_customer = Net::Braintree::Customer->find($result->customer->id);
  my $search_result = Net::Braintree::Customer->search(sub {
    my $search = shift;
    my $one_minute = DateTime::Duration->new(minutes => 1);
    $search->created_at->min($new_customer->created_at - $one_minute);
  });

  not_ok $search_result->is_empty;
  ok contains($new_customer->id, $search_result->ids);
};

subtest "can search on address (text field)" => sub {
  my $unique_company = "company" . generate_unique_integer();
  my $unique_token = "token" . generate_unique_integer();
  my $result = create_customer($unique_company, $unique_token);
  ok $result->is_success;
  my $new_customer = Net::Braintree::Customer->find($result->customer->id);
  my $search_result = Net::Braintree::Customer->search(sub {
    my $search = shift;
    $search->address_street_address->is("1 E Main St");
    $search->address_first_name->is("Thomas");
    $search->address_last_name->is("Otool");
    $search->address_extended_address->is("Suite 3");
    $search->address_locality->is("Chicago");
    $search->address_region->is("Illinois");
    $search->address_postal_code->is("60622");
    $search->address_country_name->is("United States of America");
  });

  not_ok $search_result->is_empty;
  ok contains($new_customer->id, $search_result->ids);
};

subtest "gets all customers" => sub {
  my $customers = Net::Braintree::Customer->all;
  ok scalar @{$customers->ids} > 1;
};

sub create_customer {
  my $customer_attributes = {
    first_name => "Timmy",
    last_name => "O'Toole",
    company => shift,
    email => "timmy\@example.com",
    fax => "3145551234",
    phone => "5551231234",
    website => "http://example.com",
    credit_card => {
      cardholder_name => "Tim Tool",
      number => "5431111111111111",
      expiration_date => "05/2010",
      token => shift,
      billing_address => {
        first_name => "Thomas",
        last_name => "Otool",
        street_address => "1 E Main St",
        extended_address => "Suite 3",
        locality => "Chicago",
        region => "Illinois",
        postal_code => "60622",
        country_name => "United States of America"
      }
    }
  };
  return Net::Braintree::Customer->create($customer_attributes);
}

sub perform_search {
  my($criteria) = @_;
  Net::Braintree::Customer->search(sub {
    my $search = shift;
    while(my($key, $value) = each(%$criteria)) {
      $search->$key->is($value);
    }
    return $search;
  });
}

sub make_search_criteria {
  return {
    first_name => "Timmy",
    last_name => "O'Toole",
    company => shift,
    email => "timmy\@example.com",
    phone => "5551231234",
    fax => "3145551234",
    website => "http://example.com",
    address_first_name => "Thomas",
    address_last_name => "Otool",
    address_street_address => "1 E Main St",
    address_postal_code => "60622",
    address_extended_address => "Suite 3",
    address_locality => "Chicago",
    address_region => "Illinois",
    address_country_name => "United States of America",
    payment_method_token => shift,
    cardholder_name => "Tim Tool",
    credit_card_expiration_date => "05/2010",
    credit_card_number => "5431111111111111",
  };
}

sub generate_unique_integer {
  return int(gettimeofday * 1000);
}

done_testing();
