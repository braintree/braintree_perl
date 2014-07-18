use lib qw(lib test/lib);
use Net::Braintree;
use Test::More;
use Test::Warn;

$config = Net::Braintree->configuration;

$config->environment("sandbox");
$config->public_key("integration_public_key");
$config->merchant_id("integration_merchant_id");
$config->private_key("integration_private_key");

$config = Net::Braintree->configuration;

subtest "Configuration instance" => sub {
  is $config->environment, "sandbox", "Config environment";
  is $config->public_key , "integration_public_key", "Config public key";
  is $config->merchant_id, "integration_merchant_id", "Config merch id";
  is $config->private_key, "integration_private_key", "Config private key";
  is $config->base_merchant_path, "/merchants/integration_merchant_id", "generates base merchant path based on merchant id";
};

my @examples = (
  ['sandbox', "https://api.sandbox.braintreegateway.com:443/merchants/integration_merchant_id"],
  ['production', "https://api.braintreegateway.com:443/merchants/integration_merchant_id"],
  ['qa', "https://qa-master.braintreegateway.com:443/merchants/integration_merchant_id"]
);

foreach(@examples) {
  my($environment, $url) = @$_;
  $config->environment($environment);
  is $config->base_merchant_url, $url, "$environment base merchant url";
}

my @examples = (
  ['development', "http://auth.venmo.dev:9292"],
  ['sandbox', "https://auth.sandbox.venmo.com"],
  ['production', "https://auth.venmo.com"],
  ['qa', "https://auth.qa.venmo.com"]
);

foreach(@examples) {
  my($environment, $url) = @$_;
  $config->environment($environment);
  is $config->auth_url, $url, "$environment auth_url";
}
subtest "setting configuration attributes with hash constructor" => sub {
  my $configuration = Net::Braintree::Configuration->new(
      merchant_id => "integration_merchant_id",
      public_key => "integration_public_key",
      private_key => "integration_private_key",
      environment => "development"
  );

  is $configuration->merchant_id, "integration_merchant_id";
  is $configuration->public_key, "integration_public_key";
  is $configuration->private_key, "integration_private_key";
  is $configuration->environment, "development";
};

warning_is {$config->environment("not_valid")} "Assigned invalid value to Net::Braintree::Configuration::environment",
  "Bad environment gives a warning";

$config->environment("integration");
$ENV{'GATEWAY_PORT'} = "8104";
is $config->port, "8104";
done_testing();
