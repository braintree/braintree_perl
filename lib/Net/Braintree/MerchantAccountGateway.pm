package Net::Braintree::MerchantAccountGateway;
use Moose;
use Carp qw(confess);
use Net::Braintree::Validations qw(verify_params merchant_account_signature);
use Net::Braintree::Util qw(validate_id);
use Net::Braintree::Result;

has 'gateway' => (is => 'ro');

sub create {
  my ($self, $params) = @_;
  confess "ArgumentError" unless verify_params($params, merchant_account_signature);
  $self->_make_request("/merchant_accounts/create_via_api", "post", {merchant_account => $params});
}

sub _make_request {
  my($self, $path, $verb, $params) = @_;
  my $response = $self->gateway->http->$verb($path, $params);
  my $result = Net::Braintree::Result->new(response => $response);
  return $result;
}

1;
