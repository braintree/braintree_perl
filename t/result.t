use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::TestHelper;
use Net::Braintree::Result;

subtest "multiple errors" => sub {
  my $response = {
    'api_error_response' => {
      "message" => "Customer ID is invalid.\nCredit card number is invalid."
    }
  };

  my $result = Net::Braintree::Result->new(response => $response);
  not_ok $result->is_success;
  is ($result->message, "Customer ID is invalid.\nCredit card number is invalid.");

};

subtest "allow access to relevant objects on response" => sub {
  my $response = {
    transaction => {
      amount => "44.00",
      type => "sale"
    }
  };

  my $result = Net::Braintree::Result->new(response => $response);
  is($result->transaction->amount, "44.00");
  should_throw("Can't locate object method", sub { $result->customer->id });
};

done_testing();
