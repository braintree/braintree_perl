use lib qw(lib t/lib);
use Test::More;
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

done_testing();
