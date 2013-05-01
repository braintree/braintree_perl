use lib qw(lib t/lib);
use Test::More;
use Time::HiRes qw(gettimeofday);
use Net::Braintree;
use Net::Braintree::Util;
use Net::Braintree::TestHelper;

my $credit_card_number = "5431111111111111";

subtest "doesn't return duplicate ids in paginated searches" => sub {
  my $name = "Fairley" . generate_unique_integer();
  for (my $count = 0; $count < 51; $count++) {
    Net::Braintree::Transaction->sale({
      amount => '50',
      credit_card => {
        number => $credit_card_number,
        expiration_date => "01/2000",
      },
      customer => {
        first_name => "FirstName_" . $name,
      }
    });
  };
  my $criteria = make_search_criteria($name);
  my $results = perform_search($criteria);
  my $result_count = $results->maximum_size;
  my $counter = 0;
  $results->each(sub { $counter += 1; });
  is $counter, $result_count;
};

subtest "find transaction with all matching equality fields" => sub {
  my $unique = generate_unique_integer() . "find_all_ids";
  my ($search_result, $transaction) = find_one_result($unique);
  not_ok $search_result->is_empty;
  is_deeply $search_result->ids, [$transaction->id];
};

subtest "results 'first'" => sub {
  subtest "when empty" => sub {
    my $finds_nothing = make_search_criteria("invalid_unique_thing");
    my $empty_result = perform_search($finds_nothing);

    is_deeply $empty_result->ids, [];
    is $empty_result->first(), undef;
    ok $empty_result->is_empty;
  };

  subtest "one result" => sub {
    my $unique = generate_unique_integer() . "one_result";
    my ($search_result, $transaction) = find_one_result($unique);
    is $search_result->first->customer->first_name, "FirstName_$unique";
  };

  subtest "multiple results" => sub {
    my $unique = generate_unique_integer() . "multiple_results";
    my $sale1 = create_sale($unique);
    my $sale2 = create_sale($unique);

    my $criteria = make_search_criteria($unique);
    my $search_result = perform_search($criteria);

    is scalar @{$search_result->ids}, 2;
    ok contains($sale1->transaction->id, $search_result->ids);
    ok contains($sale2->transaction->id, $search_result->ids);
    ok contains($search_result->first->id, [$sale2->transaction->id, $sale1->transaction->id]);
    is $search_result->first->amount, '5.00';
  };
};

subtest "result 'each'" => sub {
  subtest "when empty" => sub {
    my $finds_nothing = make_search_criteria("invalid_unique_thing");
    my $empty_result = perform_search($finds_nothing);

    is_deeply $empty_result->ids, [];
    ok $empty_result->is_empty;
    @results = ();
    $empty_result->each(sub { push(@results, shift); });
    is_deeply \@results, [];
  };

  subtest "when one" => sub {
    my $unique = generate_unique_integer() . "each::one_result";
    my ($search_result, $transaction) = find_one_result($unique);
    @results = ();
    $search_result->each(sub { push(@results, shift); });
    is_deeply \@results, [$transaction];
  };

  subtest "multiple results" => sub {
    my $unique = generate_unique_integer() . "each::multiple_results";
    my $sale1 = create_sale($unique);
    my $sale2 = create_sale($unique);

    my $criteria = make_search_criteria($unique);
    my $search_result = perform_search($criteria);

    is scalar @{$search_result->ids}, 2;
    my @results = ();
    $search_result->each(sub { push(@results, shift->id); });

    ok contains($sale1->transaction->id, \@results);
    ok contains($sale2->transaction->id, \@results);
  };
};

subtest "credit_card_card_type - multiple value field" => sub {
  my $unique = generate_unique_integer() . "status";
  my $sale1 = create_sale($unique);

  my $find = Net::Braintree::Transaction->find($sale1->transaction->id)->transaction;

  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->credit_card_card_type->is(Net::Braintree::CreditCard::CardType::MasterCard);
  });

  ok contains($find->id, $search_result->ids);
  my @results = ();
  $search_result->each(sub { push(@results, shift->id); });
  ok contains($find->id, \@results);
};

subtest "credit_card_card_type - multiple value field - passing invalid credit_card_card_type" => sub {
  should_throw "Invalid Argument\\(s\\) for credit_card_card_type: invalid credit_card_card_type", sub {
    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->credit_card_card_type->is("invalid credit_card_card_type");
    });
  }
};

subtest "status - multiple value field - passing invalid status" => sub {
  should_throw "Invalid Argument\\(s\\) for status: invalid status", sub {
    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->status->is("invalid status");
    });
  }
};

subtest "status - multiple value field" => sub {
  my $unique = generate_unique_integer() . "status";
  my $sale1 = create_sale($unique);

  my $find = Net::Braintree::Transaction->find($sale1->transaction->id)->transaction;

  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->status->is($find->status);
  });

  ok contains($find->id, $search_result->ids);
  my @results = ();
  $search_result->each(sub { push(@results, shift->id); });
  ok contains($find->id, \@results);
};

subtest "source - multiple value field - passing invalid source" => sub {
  should_throw "Invalid Argument\\(s\\) for source: invalid source", sub {
    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->source->is("invalid source");
    });
  }
};

subtest "source - multiple value field" => sub {
  my $unique = generate_unique_integer() . "status";
  my $sale1 = create_sale($unique);

  my $find = Net::Braintree::Transaction->find($sale1->transaction->id)->transaction;
  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->source->is(Net::Braintree::Transaction::Source::Api);
  });

  ok contains($find->id, $search_result->ids);
  my @results = ();
  $search_result->each(sub { push(@results, shift->id); });
  ok contains($find->id, \@results);
};

subtest "type - multiple value field - passing invalid type" => sub {
  should_throw "Invalid Argument\\(s\\) for type: invalid type", sub {
    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->type->is("invalid type");
    });
  }
};

subtest "type - multiple value field" => sub {
  my $unique = generate_unique_integer() . "status";
  my $sale1 = create_sale($unique);

  my $find = Net::Braintree::Transaction->find($sale1->transaction->id)->transaction;
  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->type->is(Net::Braintree::Transaction::Type::Sale);
  });

  ok contains($find->id, $search_result->ids);
  my @results = ();
  $search_result->each(sub { push(@results, shift->id); });
  ok contains($find->id, \@results);
};

subtest "credit card number - partial match" => sub {
  my $unique = generate_unique_integer() . "ccnum";
  my $sale1 = create_sale($unique);

  my $find = Net::Braintree::Transaction->find($sale1->transaction->id)->transaction;

  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->credit_card_number->ends_with($find->credit_card->last_4);
  });

  ok contains($find->id, $search_result->ids);
};

subtest "amount - range" => sub {
  my $unique = generate_unique_integer() . "range";
  my $sale1 = create_sale($unique);

  my $sale2 = Net::Braintree::Transaction->sale({
    amount => "4.00",
    credit_card => {
      number => $credit_card_number,
      expiration_date => "01/2000",
      cardholder_name => "Name"
    }
  })->transaction;

  my $find = Net::Braintree::Transaction->find($sale1->transaction->id)->transaction;
  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->amount->max("5.50");
    $search->amount->min("4.50");
  });

  ok contains($find->id, $search_result->ids);
  not_ok contains($sale2->id, $search_result->ids);
};

subtest "disbursement_date - range - max and min" => sub {
  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->id->is("deposittransaction");
    $search->disbursement_date->max(Net::Braintree::TestHelper::parse_datetime("2014-01-01 00:00:00"));
    $search->disbursement_date->min(Net::Braintree::TestHelper::parse_datetime("2012-01-01 00:00:00"));
  });

  ok contains("deposittransaction", $search_result->ids);
  is scalar @{$search_result->ids}, 1;
};

subtest "disbursement_date - range - is" => sub {
  my $search_result = Net::Braintree::Transaction->search(sub {
    my $search = shift;
    $search->id->is("deposittransaction");
    $search->disbursement_date->is(Net::Braintree::TestHelper::parse_datetime("2013-04-09 00:00:00"));
  });

  ok contains("deposittransaction", $search_result->ids);
  is scalar @{$search_result->ids}, 1;
};

subtest "merchant_account_id" => sub {
  subtest "bogus id" => sub {
    my $unique = generate_unique_integer() . "range";
    my $transaction = create_sale($unique)->transaction;

    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->merchant_account_id->is("obvious_junk");
      $search->id->is($transaction->id);
    });

    is scalar @{$search_result->ids}, 0;
  };

  subtest "valid id" => sub {
    my $unique = generate_unique_integer() . "range";
    my $transaction = create_sale($unique)->transaction;

    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->merchant_account_id->is($transaction->merchant_account_id);
      $search->id->is($transaction->id);
    });

    is scalar @{$search_result->ids}, 1;
  };

  subtest "mix of valid and invalid ids" => sub {
    my $unique = generate_unique_integer() . "range";
    my $transaction = create_sale($unique)->transaction;

    my $search_result = Net::Braintree::Transaction->search(sub {
      my $search = shift;
      $search->merchant_account_id->in("bogus_merchant_account_id", $transaction->merchant_account_id);
      $search->id->is($transaction->id);
    });

    is scalar @{$search_result->ids}, 1;
  };
};

subtest "all" => sub {
  my $transactions = Net::Braintree::Transaction->all;
  ok scalar @{$transactions->ids} > 1;
};


sub find_one_result {
  my $unique = shift;
  my $transaction = Net::Braintree::Transaction->find(create_sale($unique)->transaction->id)->transaction;

  my $criteria = make_search_criteria($unique);
  my $search_result = perform_search($criteria);

  ok $search_result->is_success;
  return ($search_result, $transaction);
}

sub generate_unique_integer {
  return int(gettimeofday * 1000);
}

sub create_sale {
  my $name = "FirstName_" . shift;

  my $sale = Net::Braintree::Transaction->sale({
    amount => "5.00",
    credit_card => {
      number => $credit_card_number,
      expiration_date => "01/2000",
      cardholder_name => "Name",
    },
    billing => {
      company => "Company",
      country_name => "United States of America",
      extended_address => "Address",
      first_name => "FirstName",
      last_name => "LastName",
      locality => "Locality",
      postal_code => "12345",
      region => "IL",
      street_address => "Street"
    },
    customer => {
      company => "Company",
      email => "smith\@example.com",
      fax => "1111111111",
      first_name => $name,
      last_name => "LastName",
      phone => "1111111111",
      website => "http://example.com",
    },
    options => {
      store_in_vault => "true",
      submit_for_settlement => "true"
    },
    order_id => "myorder",
    shipping => {
      company => "Company P.S.",
      country_name => "Mexico",
      extended_address => "ExtendedAddress",
      first_name => "FirstName",
      last_name => "LastName",
      locality => "Company",
      postal_code => "54321",
      region => "IL",
      street_address => "Address"
    }
  });

  return $sale;
}

sub perform_search {
  my($criteria) = @_;
  Net::Braintree::Transaction->search( sub {
    my $search = shift;
    while(my($key, $value) = each(%$criteria)) {
      $search->$key->is($value);
    }

    return $search;
  });
}

sub make_search_criteria {
  return {
    customer_first_name => "FirstName_" . shift,
  };
}
done_testing();
