use lib qw(lib t/lib);
use Test::More;
use Net::Braintree::TestHelper;
use Net::Braintree::TransparentRedirect::QueryString;
use Net::Braintree::Digest qw(hexdigest);
use Net::Braintree::Configuration;

my $config = Net::Braintree::Configuration->new({environment => "integration"});

my $tr = Net::Braintree::TransparentRedirect::QueryString->new(config => $config);
my $query_string = "one=1&two=2&http_status=200";
my $hash = hexdigest($config->private_key, $query_string);
my $complete_query_string = with_hash($query_string);
my %query_as_hash = (one => 1, two => 2, http_status=>200, hash=>$hash);

subtest "check query string for forgery" => sub {
  ok($tr->validate($complete_query_string), "Query String is valid");
  should_throw("ForgedQueryString", sub {$tr->validate($query_string)}, "Query String is invalid without hash");
  should_throw("ForgedQueryString", sub {$tr->validate("$query_string&hash=wrong_hash")}, "Query string has wrong hash.");

  should_throw("UnexpectedError: expected query string to have an http_status param",
    sub { $tr->validate(with_hash("one=1&two=2")) }, "Query String invalid without http_status");
};

subtest "parse to hash" => sub {
  my $actual_hash = $tr->parse($complete_query_string);
  is_deeply($actual_hash, \%query_as_hash, "parses query string to hash");
};

subtest "HTTP Status codes" => sub {
  my @error_types = (
    ["AuthenticationError",  "401"],
    ["AuthorizationError",   "403"],
    ["ServerError",          "500"],
    ["DownForMaintenance",   "503"],
    ["UnexpectedError",      "600"]
  );

  foreach(@error_types) {
    my($error, $code) = @$_;
    should_throw($error, sub { $tr->validate(with_hash("http_status=$code")) }, "Raises $error if status is $code");
  }
};

sub with_hash {
  my $query_string = shift;
  my $hash = hexdigest($config->private_key, $query_string);
  return "$query_string&hash=$hash";
}

done_testing();
