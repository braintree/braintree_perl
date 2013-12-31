use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::ErrorCodes::MerchantAccount;
use Net::Braintree::ErrorCodes::MerchantAccount::Individual;
use Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address;
use Net::Braintree::ErrorCodes::MerchantAccount::Funding;
use Net::Braintree::ErrorCodes::MerchantAccount::Business;
use Net::Braintree::ErrorCodes::MerchantAccount::Business::Address;
use Net::Braintree::TestHelper;
use Net::Braintree::Test;

my $deprecated_application_params = {
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
    ssn => "123-00-1234",
    tax_id => "123456789",
    routing_number => "122100024",
    account_number => "43759348798"
  },
  tos_accepted => "true",
  master_merchant_account_id => "sandbox_master_merchant_account"
};

my $valid_application_params = {
  individual => {
    first_name => "Job",
    last_name => "Leoggs",
    email => 'job@leoggs.com',
    phone => '555-555-1212',
    address => {
      street_address => "193 Credibility St.",
      postal_code => "60647",
      locality => "Avondale",
      region => "IN",
    },
    date_of_birth => "10/9/1985",
    ssn => "123-00-1235",
	},
	business => {
    dba_name => "In good company",
    legal_name => "In good company",
    tax_id => "123456780",
    address => {
      street_address => "193 Credibility St.",
      postal_code => "60647",
      locality => "Avondale",
      region => "IN",
    },
	},
	funding => {
    destination => Net::Braintree::MerchantAccount::FundingDestination::Email,
    email => 'job@leoggs.com',
    mobile_phone => "3125551212",
    routing_number => "122100024",
    account_number => "43759348799"
  },
  tos_accepted => "true",
  master_merchant_account_id => "sandbox_master_merchant_account"
};

subtest "Successful Create with deprecated parameters" => sub {
  local $SIG{__WARN__} = sub { };
  my $result = Net::Braintree::MerchantAccount->create($deprecated_application_params);
  ok $result->is_success;
  is($result->merchant_account->status, Net::Braintree::MerchantAccount::Status::Pending);
  is($result->merchant_account->master_merchant_account->id, "sandbox_master_merchant_account");
};

subtest "Successful Create" => sub {
  my $result = Net::Braintree::MerchantAccount->create($valid_application_params);
  ok $result->is_success;
  is($result->merchant_account->status, Net::Braintree::MerchantAccount::Status::Pending);
  is($result->merchant_account->master_merchant_account->id, "sandbox_master_merchant_account");
};

subtest "Accepts ID" => sub {
  my $params_with_id = $valid_application_params;
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

subtest "Works with FundingDestination::Bank" => sub {
  my $params = $valid_application_params;
  my $rand = int(rand(1000));
  $params->{"id"} = "sub_merchant_account_id" . $rand;
  $params->{funding}->{destination} = Net::Braintree::MerchantAccount::FundingDestination::Bank;
  my $result = Net::Braintree::MerchantAccount->create($params);

  ok $result->is_success;
};

subtest "Works with FundingDestination::Email" => sub {
  my $params = $valid_application_params;
  my $rand = int(rand(1000));
  $params->{"id"} = "sub_merchant_account_id" . $rand;
  $params->{funding}->{destination} = Net::Braintree::MerchantAccount::FundingDestination::Email;
  my $result = Net::Braintree::MerchantAccount->create($params);

  ok $result->is_success;
};

subtest "Works with FundingDestination::MobilePhone" => sub {
  my $params = $valid_application_params;
  my $rand = int(rand(1000));
  $params->{"id"} = "sub_merchant_account_id" . $rand;
  $params->{funding}->{destination} = Net::Braintree::MerchantAccount::FundingDestination::MobilePhone;
  my $result = Net::Braintree::MerchantAccount->create($params);

  ok $result->is_success;
};

subtest "Update updates all fields" => sub {
  local $SIG{__WARN__} = sub { };
  my $result = Net::Braintree::MerchantAccount->create($deprecated_application_params);
  ok $result->is_success;
  my $update_params = {
    individual => {
      first_name => "Job",
      last_name => "Leoggs",
      email => 'job@leoggs.com',
      phone => '555-555-1212',
      address => {
        street_address => "193 Credibility St.",
        postal_code => "60647",
        locality => "Avondale",
        region => "IN",
      },
      date_of_birth => "10/9/1985",
      ssn => "123-00-1235",
    },
    business => {
      dba_name => "In good company",
      legal_name => "In good company",
      tax_id => "123456780",
      address => {
        street_address => "193 Credibility St.",
        postal_code => "60647",
        locality => "Avondale",
        region => "IN",
      },
    },
    funding => {
      destination => Net::Braintree::MerchantAccount::FundingDestination::Email,
      email => 'job@leoggs.com',
      mobile_phone => "3125551212",
      routing_number => "122100024",
      account_number => "43759348799"
    },
  };
  $result = Net::Braintree::MerchantAccount->update($result->merchant_account->id, $update_params);
  ok $result->is_success;
  is($result->merchant_account->individual_details->first_name, "Job");
  is($result->merchant_account->individual_details->last_name, "Leoggs");
  is($result->merchant_account->individual_details->email, 'job@leoggs.com');
  is($result->merchant_account->individual_details->phone, "5555551212");
  is($result->merchant_account->individual_details->address_details->street_address, "193 Credibility St.");
  is($result->merchant_account->individual_details->address_details->postal_code, "60647");
  is($result->merchant_account->individual_details->address_details->locality, "Avondale");
  is($result->merchant_account->individual_details->address_details->region, "IN");
  is($result->merchant_account->individual_details->date_of_birth, "1985-09-10");
  is($result->merchant_account->business_details->dba_name, "In good company");
  is($result->merchant_account->business_details->legal_name, "In good company");
  is($result->merchant_account->business_details->tax_id, "123456780");
  is($result->merchant_account->business_details->address_details->street_address, "193 Credibility St.");
  is($result->merchant_account->business_details->address_details->postal_code, "60647");
  is($result->merchant_account->business_details->address_details->locality, "Avondale");
  is($result->merchant_account->business_details->address_details->region, "IN");
  is($result->merchant_account->funding_details->destination, Net::Braintree::MerchantAccount::FundingDestination::Email);
  is($result->merchant_account->funding_details->destination, Net::Braintree::MerchantAccount::FundingDestination::Email);
  is($result->merchant_account->funding_details->email, 'job@leoggs.com');
  is($result->merchant_account->funding_details->mobile_phone, "3125551212");
  is($result->merchant_account->funding_details->routing_number, "122100024");
  is($result->merchant_account->funding_details->account_number_last_4, "8799");
};

subtest "Create handles required validation errors" => sub {
  my $params = {
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  };
  my $result = Net::Braintree::MerchantAccount->create($params);
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("individual")->on("first_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::FirstNameIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->on("last_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::LastNameIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->on("date_of_birth")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::DateOfBirthIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->on("email")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::EmailIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("street_address")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::StreetAddressIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("postal_code")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::PostalCodeIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("locality")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::LocalityIsRequired);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("region")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::RegionIsRequired);
  is($result->errors->for("merchant_account")->for("funding")->on("destination")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::DestinationIsRequired);

};

subtest "Create handles invalid validation errors" => sub {
  my $params = {
    "individual" => {
      "first_name" => "<>",
      "last_name" => "<>",
      "email" => "bad",
      "phone" => "999",
      "address" => {
        "street_address" => "nope",
        "postal_code" => "1",
        "region" => "QQ",
      },
      "date_of_birth" => "hah",
      "ssn" => "12345",
    },
    "business" => {
      "legal_name" => "``{}",
      "dba_name" => "{}``",
      "tax_id" => "bad",
      "address" => {
        "street_address" => "nope",
        "postal_code" => "1",
        "region" => "QQ",
      },
    },
    "funding" => {
      "destination" => "MY WALLET",
      "routing_number" => "LEATHER",
      "account_number" => "BACK POCKET",
      "email" => "BILLFOLD",
      "mobile_phone" => "TRIFOLD"
    },
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  };
  my $result = Net::Braintree::MerchantAccount->create($params);
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("individual")->on("first_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::FirstNameIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->on("last_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::LastNameIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->on("email")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::EmailIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->on("phone")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::PhoneIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("street_address")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::StreetAddressIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("postal_code")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::PostalCodeIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->for("address")->on("region")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::Address::RegionIsInvalid);
  is($result->errors->for("merchant_account")->for("individual")->on("ssn")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Individual::SsnIsInvalid);
  is($result->errors->for("merchant_account")->for("business")->on("legal_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::LegalNameIsInvalid);
  is($result->errors->for("merchant_account")->for("business")->on("dba_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::DbaNameIsInvalid);
  is($result->errors->for("merchant_account")->for("business")->on("tax_id")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::TaxIdIsInvalid);
  is($result->errors->for("merchant_account")->for("business")->for("address")->on("street_address")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::Address::StreetAddressIsInvalid);
  is($result->errors->for("merchant_account")->for("business")->for("address")->on("postal_code")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::Address::PostalCodeIsInvalid);
  is($result->errors->for("merchant_account")->for("business")->for("address")->on("region")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::Address::RegionIsInvalid);
  is($result->errors->for("merchant_account")->for("funding")->on("destination")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::DestinationIsInvalid);
  is($result->errors->for("merchant_account")->for("funding")->on("routing_number")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::RoutingNumberIsInvalid);
  is($result->errors->for("merchant_account")->for("funding")->on("account_number")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::AccountNumberIsInvalid);
  is($result->errors->for("merchant_account")->for("funding")->on("email")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::EmailIsInvalid);
  is($result->errors->for("merchant_account")->for("funding")->on("mobile_phone")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::MobilePhoneIsInvalid);
};

subtest "Handles tax id and legal name mutual requirement errors" => sub {
  my $result = Net::Braintree::MerchantAccount->create({
    "business" => {"tax_id" => "1234567890"},
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  });
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("business")->on("legal_name")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::LegalNameIsRequiredWithTaxId);
  is($result->errors->for("merchant_account")->for("business")->on("tax_id")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::TaxIdMustBeBlank);

  my $result = Net::Braintree::MerchantAccount->create({
    "business" => {"legal_name" => "foogurt"},
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  });
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("business")->on("tax_id")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Business::TaxIdIsRequiredWithLegalName);
};

subtest "Handles funding destination requirement errors" => sub {
  my $result = Net::Braintree::MerchantAccount->create({
    funding => {destination => Net::Braintree::MerchantAccount::FundingDestination::Bank},
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  });
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("funding")->on("account_number")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::AccountNumberIsRequired);
  is($result->errors->for("merchant_account")->for("funding")->on("routing_number")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::RoutingNumberIsRequired);

  my $result = Net::Braintree::MerchantAccount->create({
    funding => {destination => Net::Braintree::MerchantAccount::FundingDestination::MobilePhone},
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  });
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("funding")->on("mobile_phone")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::MobilePhoneIsRequired);

  my $result = Net::Braintree::MerchantAccount->create({
    funding => {destination => Net::Braintree::MerchantAccount::FundingDestination::Email},
    tos_accepted => "true",
    master_merchant_account_id => "sandbox_master_merchant_account"
  });
  not_ok $result->is_success;
  is($result->errors->for("merchant_account")->for("funding")->on("email")->[0]->code, Net::Braintree::ErrorCodes::MerchantAccount::Funding::EmailIsRequired);
};

subtest "Can find a merchant account by ID" => sub {
  my $params_with_id = $valid_application_params;
  my $rand = int(rand(1000));
  $params_with_id->{"id"} = "sub_merchant_account_id" . $rand;
  my $result = Net::Braintree::MerchantAccount->create($params_with_id);
  ok $result->is_success;
  my $merchant_account = Net::Braintree::MerchantAccount->find("sub_merchant_account_id" . $rand);
};

subtest "Calling find with a nonexistant ID returns a NotFoundError" => sub {
  should_throw("NotFoundError", sub { Net::Braintree::MerchantAccount->find("asdlkfj") });
};

done_testing();
