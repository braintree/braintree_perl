use lib qw(lib t/lib);
use Test::More;
use Net::Braintree;
use Net::Braintree::TestHelper;
use Net::Braintree::Test;

my $disbursement_params = {
  id => "123456",
  merchant_account => {
    id => "sandbox_sub_merchant_account",
    master_merchant_account => {
      id => "sandbox_master_merchant_account",
      status => "active"
    },
    status => "active"
  },
  transaction_ids => ["sub_merchant_transaction"],
  amount => "100.00",
  disbursement_date => Net::Braintree::TestHelper::parse_datetime("2014-04-10 00:00:00"),
  exception_message => "invalid_account_number",
  follow_up_action => "update",
  retry => "false",
  success => "false"
};

subtest "Transactions" => sub {
  subtest "retrieves transactions associated with the disbursement" => sub {
    my $disbursement = Net::Braintree::Disbursement->new($disbursement_params);
    my $transactions = $disbursement->transactions();
    isnt $transactions, undef;
    is($transactions->first()->id(), "sub_merchant_transaction");
  };
};

done_testing();
