use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::ErrorCodes::MerchantAccount;
use Net::Braintree::TestHelper;
use Net::Braintree::Test;

my $valid_params = {
  applicant_details => {
    company_name => "In good company",
    first_name => "Joe",
    last_name => "Bloggs",
    email => 'joe@bloggs.com',
    phone => '555-555-5555',
    address => {
      street_address => "123 Credibility St.",
      postal_code => "60606",
      locality => "Chicago",
      region => "IL",
    },
    date_of_birth => "10/9/1980",
    ssn => "123-000-1234",
    tax_id => "123456789",
    routing_number => "122100024",
    account_number => "43759348798"
  },
  tos_accepted => "true",
  master_merchant_account_id => "sandbox_master_merchant_account"
};

subtest "Successful Create" => sub {
  my $result = Net::Braintree::MerchantAccount->create($valid_params);
  ok $result->is_success;
  is($result->merchant_account->status, Net::Braintree::MerchantAccount::Status::Pending);
  is($result->merchant_account->master_merchant_account->id, "sandbox_master_merchant_account");
};

subtest "Accepts ID" => sub {
  my $params_with_id = $valid_params;
  my $rand = int(rand(1000));
  $params_with_id->{"id"} = "sub_merchant_account_id" . $rand;
  my $result = Net::Braintree::MerchantAccount->create($params_with_id);

  ok $result->is_success;
  is($result->merchant_account->status, Net::Braintree::MerchantAccount::Status::Pending);
  is($result->merchant_account->master_merchant_account->id, "sandbox_master_merchant_account");
  is($result->merchant_account->id, "sub_merchant_account_id" . $rand);
};

subtest "Handles Unsuccessful Result" => sub {
  my $result = Net::Braintree::MerchantAccount->create({});
  not_ok $result->is_success;
  my $expected_error_code = Net::Braintree::ErrorCodes::MerchantAccount::MasterMerchantAccountIdIsRequired;
  is($result->errors->for("merchant_account")->on("master_merchant_account_id")->[0]->code, $expected_error_code);
};

done_testing();
