use lib qw(lib t/lib);
use Test::More;
use Test::Moose;
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::MerchantAccount;

subtest 'create new merchant account with all params', sub {
	my $params = {
		id => "sub_merchant_account",
		status => "active",
		master_merchant_account => {
			id => "master_merchant_account",
			status => "active"
		},
		individual => {
			first_name => "John",
			last_name => "Doe",
			email => "john.doe\@example.com",
			date_of_birth => "1970-01-01",
			phone => "3125551234",
			ssn_last_4 => "6789",
			address => {
				street_address => "123 Fake St",
				locality => "Chicago",
				region => "IL",
				postal_code => "60622",
			}
		},
		business => {
			dba_name => "James's Bloggs",
			tax_id => "123456789",
		},
		funding => {
			account_number_last_4 => "8798",
			routing_number => "071000013",
		}
	};

	my $merchant_account = Net::Braintree::MerchantAccount->new($params);
	is $merchant_account->status, "active";
	is $merchant_account->id, "sub_merchant_account";
	is $merchant_account->master_merchant_account->id, "master_merchant_account";
	is $merchant_account->master_merchant_account->status, "active";
	is $merchant_account->individual_details->first_name, "John";
	is $merchant_account->individual_details->last_name, "Doe";
	is $merchant_account->individual_details->email, "john.doe\@example.com";
	is $merchant_account->individual_details->date_of_birth, "1970-01-01";
	is $merchant_account->individual_details->phone, "3125551234";
	is $merchant_account->individual_details->ssn_last_4, "6789";
	is $merchant_account->individual_details->address_details->street_address, "123 Fake St";
	is $merchant_account->individual_details->address_details->locality, "Chicago";
	is $merchant_account->individual_details->address_details->region, "IL";
	is $merchant_account->individual_details->address_details->postal_code, "60622";
	is $merchant_account->business_details->dba_name, "James's Bloggs";
	is $merchant_account->business_details->tax_id, "123456789";
	is $merchant_account->funding_details->account_number_last_4, "8798";
	is $merchant_account->funding_details->routing_number, "071000013";
};

done_testing();
