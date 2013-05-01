use lib qw(lib t/lib);
use Test::More;
use Time::HiRes qw(gettimeofday);
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::CreditCardNumbers::CardTypeIndicators;

my $customer_create = Net::Braintree::Customer->create({first_name => "Walter", last_name => "Weatherman"});

subtest "card verification is returned by result objects" => sub {
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => "4000111111111115",
    expiration_date => "12/15",
    options => {
      verify_card => 1
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  my $verification = $result->credit_card_verification;

  is $verification->credit_card->{'last_4'}, "1115";
  is $verification->status, "processor_declined";
};

subtest "finds credit card verification" => sub {
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => "4000111111111115",
    expiration_date => "12/15",
    options => {
      verify_card => 1
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);
  my $verification = $result->credit_card_verification;

  my $find_result = Net::Braintree::CreditCardVerification->find($verification->id);

  is $find_result->id, $verification->id;
};

subtest "Card Type Indicators" => sub {
  my $cardholder_name = "Tom Smith" . gettimeofday;
  my $credit_card_params = {
    customer_id => $customer_create->customer->id,
    number => Net::Braintree::CreditCardNumbers::CardTypeIndicators::Unknown,
    expiration_date => "12/15",
    cardholder_name => $cardholder_name,
    options => {
      verify_card => 1
    }
  };

  my $result = Net::Braintree::CreditCard->create($credit_card_params);

  my $search_results = Net::Braintree::CreditCardVerification->search( sub {
      my $search = shift;
      $search->credit_card_cardholder_name->is($cardholder_name);
    });

  is $search_results->maximum_size, 1;
  my $credit_card = $search_results->first->credit_card;

  is($credit_card->{'prepaid'}, Net::Braintree::CreditCard::Prepaid::Unknown);
  is($credit_card->{'commercial'}, Net::Braintree::CreditCard::Commercial::Unknown);
  is($credit_card->{'debit'}, Net::Braintree::CreditCard::Debit::Unknown);
  is($credit_card->{'payroll'}, Net::Braintree::CreditCard::Payroll::Unknown);
  is($credit_card->{'healthcare'}, Net::Braintree::CreditCard::Healthcare::Unknown);
  is($credit_card->{'durbin_regulated'}, Net::Braintree::CreditCard::DurbinRegulated::Unknown);
  is($credit_card->{'issuing_bank'}, Net::Braintree::CreditCard::IssuingBank::Unknown);
  is($credit_card->{'country_of_issuance'}, Net::Braintree::CreditCard::CountryOfIssuance::Unknown);
};

done_testing();
