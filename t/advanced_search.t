use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::TestHelper;

{
package Net::Braintree::AdvancedSearchTest;
use Moose;
use Net::Braintree::AdvancedSearch qw(search_to_hash);
my $meta = __PACKAGE__->meta();

my $field = Net::Braintree::AdvancedSearchFields->new(metaclass => $meta);
$field->text("billing_company");
$field->equality("credit_card_expiration_date");
$field->range("amount");
$field->text("order_id");
$field->multiple_values("created_using", "full_information", "token");
$field->multiple_values("ids");
$field->key_value("refund");



__PACKAGE__->meta->make_immutable;
1;
}

subtest "search_to_hash" => sub {
  subtest "empty if search is empty" => sub {
    my $search = Net::Braintree::AdvancedSearchTest->new;
    is_deeply(Net::Braintree::AdvancedSearch->search_to_hash($search), {});
  };

  subtest "is method" => sub {
    my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->credit_card_expiration_date->is("foo");
    is_deeply(Net::Braintree::AdvancedSearch->search_to_hash($search), {credit_card_expiration_date => {is => "foo"}});
  };
};
subtest "Equality Nodes" => sub {
  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->order_id->is("2132");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'order_id'}->{'is'}, "2132";
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->credit_card_expiration_date->is_not("12/11");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'credit_card_expiration_date'}->{'is_not'}, "12/11";
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    should_throw("Can't locate object method \"starts_with\"", sub {
      $search->credit_card_expiration_date->starts_with("12");
    })
  }

  subtest "Overrides is with new value" => sub {
    my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->order_id->is("2132");
    $search->order_id->is("4376");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'order_id'}->{'is'}, "4376";
  }
};

subtest "Partial Matches" => sub {
  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->billing_company->starts_with("Brain");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'billing_company'}->{'starts_with'}, "Brain";
  }
};

subtest "Text" => sub {
  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->billing_company->contains("12345");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'billing_company'}->{'contains'}, "12345";
  }
};

subtest "Range Nodes" => sub {
  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->amount >= ("10.01");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'amount'}->{'min'}, "10.01", "Minimum"
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->amount <= ("10.01");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'amount'}->{'max'}, "10.01", "Maximum";
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->amount->between("10.00", "10.02");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'amount'}->{'min'}, "10.00", "Between Min";
    is $result_hash->{'amount'}->{'max'}, "10.02", "Between Max";
  }
};

subtest "Key Value Nodes" => sub {
  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->refund->is("10.00");;
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is $result_hash->{'refund'}, "10.00";
  }
};

subtest "Multiple Values Nodes" => sub {
  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->created_using->is("token");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is_deeply $result_hash->{'created_using'}, ["token"];
  }

  {
    my $ids = [1, 2, 3];
    my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->ids->in($ids);
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is_deeply $result_hash->{'ids'}, [1, 2, 3];
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    $search->created_using->in("token", "full_information");
    $result_hash = Net::Braintree::AdvancedSearch->search_to_hash($search);
    is_deeply $result_hash->{'created_using'}, ["token", "full_information"];
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    should_throw "Invalid Argument\\(s\\) for created_using: invalid value", sub {
      $search->created_using->in("token", "invalid value");
    }
  }

  { my $search = Net::Braintree::AdvancedSearchTest->new;
    should_throw "Invalid Argument\\(s\\) for created_using: invalid value, foobar", sub {
      $search->created_using->is("invalid value", "foobar");
    }
  }
};

done_testing();
