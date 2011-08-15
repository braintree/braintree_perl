use lib qw(lib t/lib);
use Test::More;

my $query_string = "one=1&two=2&http_status=200";
my $private_key = "integration_private_key";
my $expected_hash = "3970ae558c51cf6f54340b5b1842d47ba1f5a19e";

use Net::Braintree::Digest qw(hexdigest);
is(hexdigest($private_key, $query_string), $expected_hash, "Braintree digest works");

done_testing();
